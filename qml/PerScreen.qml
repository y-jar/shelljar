/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   PerScreen
 *
 *   One full screen window per monitor. It hosts that monitor's bar, its
 *   islands and every popout panel, plus the launcher, control center, session
 *   menu, wallpaper pickers and toast column. Opening anything closes the rest
 *   through one shared closeAll so popups never stack on top of each other.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

PanelWindow {
  id: root

  required property var modelData
  screen: modelData // the screen Variants passes in

  readonly property string ns: screen ? "shelljar-" + screen.name : "shelljar"
  WlrLayershell.namespace: ns
  WlrLayershell.exclusionMode: ExclusionMode.Ignore // overlay: no reserved space
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: root.grabKeys
    ? WlrKeyboardFocus.Exclusive
    : (root.popupOpen || root.islandActive) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
  color: "transparent"

  anchors.top: true
  anchors.bottom: true
  anchors.left: true
  anchors.right: true

  // shared from shell.qml
  property var notificationServer: null
  property var toastsModel: null

  property bool launcherOpen: false
  property bool controlsOpen: false
  property bool sessionOpen: false
  property bool pickerOpen: false
  readonly property bool popupOpen: launcherOpen || controlsOpen || sessionOpen || pickerOpen || notificationsPanel.open || volumePanel.open || batteryPanel.open || brightnessPanel.open || networkPanel.open || calendarPanel.open || wallCarousel.open || wallGrid.open
  readonly property bool barActive: bar.barOpen
  readonly property bool leftActive: leftIsland.open
  readonly property bool rightActive: rightIsland.open
  readonly property bool islandActive: barActive || leftActive || rightActive
  // key-driven overlays grab keyboard focus; mouse popups stay hands-off
  readonly property bool grabKeys: launcherOpen || pickerOpen || sessionOpen || (polkitDialog !== null && polkitDialog.active)

  // clickthrough: full screen while a popup or any island is open, otherwise
  // only the three islands' rects pass clicks.
  mask: Region {
    x: (root.popupOpen || root.islandActive) ? 0 : bar.x
    y: (root.popupOpen || root.islandActive) ? 0 : bar.y
    width: (root.popupOpen || root.islandActive) ? root.width : bar.width
    height: (root.popupOpen || root.islandActive) ? root.height : bar.height

    Region {
      x: leftIsland.x
      y: leftIsland.y
      width: (!root.popupOpen && !root.islandActive) ? leftIsland.width : 0
      height: (!root.popupOpen && !root.islandActive) ? leftIsland.height : 0
    }
    Region {
      x: rightIsland.x
      y: rightIsland.y
      width: (!root.popupOpen && !root.islandActive) ? rightIsland.width : 0
      height: (!root.popupOpen && !root.islandActive) ? rightIsland.height : 0
    }
    Region {
      x: toasts.x
      y: toasts.y
      width: (!root.popupOpen && toasts.visible) ? toasts.width : 0
      height: (!root.popupOpen && toasts.visible) ? toasts.height : 0
    }
  }

  // dim scrim behind open popups
  Rectangle {
    id: scrim
    anchors.fill: parent
    color: Config.scrim
    visible: root.popupOpen
    opacity: root.popupOpen ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 120 } }
    MouseArea { anchors.fill: parent; onClicked: root.closeAll() }
  }

  // transparent click catcher: clicking away from the open islands closes them
  MouseArea {
    anchors.fill: parent
    visible: root.islandActive && !root.popupOpen
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: root.closeAll()
  }

  // ---- middle island (profile / centered clock / notifications + sound) ----
  Bar {
    id: bar
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    notificationServer: root.notificationServer
    onControlClicked: { root.closeAll(); root.controlsOpen = true }
    onNotificationsRequested: root.togglePanel(notificationsPanel)
    onWallpaperOpenRequested: dir => { root.closeAll(); wallCarousel.open = true; wallCarousel.nudge(dir) }
    onWallpaperGridRequested: { root.closeAll(); wallGrid.open = true }
    onWallpaperPickerRequested: root.openWallPicker()
    onOsdHoverRequested: { osd.showVolume(); osd.hover() }
    onOsdValueChanged: osd.showVolume()
    onVolumePanelRequested: root.togglePanel(volumePanel)
    onClockClicked: root.togglePanel(calendarPanel)
  }

  // ---- left island (network / power / tray / media), top-left edge ----
  LeftIsland {
    id: leftIsland
    anchors.left: parent.left
    anchors.leftMargin: 8
    anchors.top: parent.top
    anchors.topMargin: 0
    onNetworkClicked: root.togglePanel(networkPanel)
    onPowerClicked: { root.closeAll(); root.sessionOpen = true }
  }

  // ---- right island (battery / brightness), top-right edge ----
  RightIsland {
    id: rightIsland
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.top: parent.top
    anchors.topMargin: 0
    onBatteryPanelRequested: { root.closeAll(); batteryPanel.open = true }
    onBrightnessPanelRequested: { root.closeAll(); brightnessPanel.open = true }
    onOsdBrightnessHoverRequested: { osd.showBrightness(BrightnessService.value); osd.hover() }
    onOsdBrightnessValueChanged: osd.showBrightness(BrightnessService.value)
  }

  // ---- volume/brightness OSD (top-right) ----
  Osd { id: osd }

  // ---- volume panel (pop-out, under the bar's volume pill) ----
  VolumePanel {
    id: volumePanel
    anchors.right: bar.right
    anchors.rightMargin: 8
    anchors.top: bar.bottom
    anchors.topMargin: 8
    visible: open
    open: false
    onCloseRequested: open = false
  }

  // ---- battery panel (pop-out, beside the right island) ----
  BatteryPanel {
    id: batteryPanel
    anchors.right: rightIsland.left
    anchors.rightMargin: 8
    anchors.top: rightIsland.top
    visible: open
    open: false
    onCloseRequested: open = false
  }

  // ---- brightness panel (pop-out, beside the right island) ----
  BrightnessPanel {
    id: brightnessPanel
    anchors.right: rightIsland.left
    anchors.rightMargin: 8
    anchors.top: rightIsland.top
    anchors.topMargin: 44
    visible: open
    open: false
    onCloseRequested: open = false
  }

  // ---- network panel (pop-out, beside the left island) ----
  NetworkPanel {
    id: networkPanel
    anchors.left: leftIsland.right
    anchors.leftMargin: 8
    anchors.top: leftIsland.top
    visible: open
    open: false
    onCloseRequested: open = false
  }

  // ---- calendar panel (pop-out, under the clock) ----
  CalendarPanel {
    id: calendarPanel
    anchors.horizontalCenter: bar.horizontalCenter
    anchors.top: bar.bottom
    anchors.topMargin: 8
    visible: open
    open: false
    onCloseRequested: open = false
  }

  // ---- notifications panel (pop-out) ----
  NotificationsPanel {
    id: notificationsPanel
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.top: bar.bottom
    anchors.topMargin: 8
    visible: open
    open: false
    notificationServer: root.notificationServer
    onCloseRequested: open = false
  }

  // ---- wallpaper preview carousel (pop-out) ----
  WallpaperCarousel {
    id: wallCarousel
    anchors.horizontalCenter: bar.horizontalCenter
    anchors.top: bar.bottom
    anchors.topMargin: 8
    visible: open
    open: false
    onCloseRequested: open = false
  }

  // ---- wallpaper picker grid (pop-out) ----
  WallpaperGrid {
    id: wallGrid
    anchors.horizontalCenter: bar.horizontalCenter
    anchors.top: bar.bottom
    anchors.topMargin: 8
    visible: open
    open: false
    onCloseRequested: open = false
  }

  // ---- full-screen calm wallpaper picker (super+w / right-click) ----
  WallpaperPicker {
    id: wallPicker
    anchors.fill: parent
    visible: root.pickerOpen
    open: root.pickerOpen
    onCloseRequested: root.pickerOpen = false
  }

  // ---- launcher (grid) ----
  Launcher {
    id: launcher
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: bar.bottom
    anchors.topMargin: 12
    visible: root.launcherOpen
    open: root.launcherOpen
    onCloseRequested: root.launcherOpen = false
  }

  // ---- control center (profile frame) — opens just below the bar ----
  ControlCenter {
    id: controls
    anchors.left: bar.left
    anchors.leftMargin: 8
    anchors.top: bar.bottom
    anchors.topMargin: 12
    visible: root.controlsOpen
    open: root.controlsOpen
    onOpenSession: {
      root.controlsOpen = false
      root.sessionOpen = true
    }
  }

  // ---- full-screen power menu ----
  SessionMenu {
    anchors.fill: parent
    visible: root.sessionOpen
    open: root.sessionOpen
    onCloseRequested: root.sessionOpen = false
  }

  // ---- privileged action authentication dialog ----
  Polkit {
    id: polkitDialog
    anchors.fill: parent
    enabled: true
  }

  // ---- toast notifications (top-right) ----
  ColumnLayout {
    id: toasts
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.top: bar.bottom
    anchors.topMargin: 12
    width: Config.toastWidth
    spacing: 6
    visible: root.toastsModel ? root.toastsModel.count > 0 : false

    Repeater {
      id: toastRepeater
      model: root.toastsModel

      delegate: Rectangle {
        required property var modelData
        required property int index
        Layout.fillWidth: true
        height: toastText.implicitHeight + 16
        radius: 10
        color: Config.bg
        border.color: Config.borderMid

        RowLayout {
          anchors.fill: parent
          anchors.margins: 10
          spacing: 8
          ShellText {
            text: "▣"
            color: Config.accent
            font.pixelSize: Config.fsMedium
          }
          ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            ShellText {
              text: modelData.appName || ""
              color: Config.accent
              font.pixelSize: Config.fsTiny
            }
            ShellText {
              id: toastText
              text: (modelData.summary || "") + (modelData.body ? "\n" + modelData.body : "")
              color: Config.text
              font.pixelSize: Config.fsSmall
              wrapMode: Text.WordWrap
              Layout.fillWidth: true
            }
          }
          Rectangle {
            width: 16; height: 16; radius: 8; color: "transparent"
            ShellText {
              anchors.centerIn: parent
              text: "✕"
              color: Config.subtext
              font.pixelSize: Config.fsTiny
            }
            MouseArea { anchors.fill: parent; onClicked: root.toastsModel.remove(index) }
          }
        }

        Timer { interval: Config.toastMs; running: true; onTriggered: root.toastsModel.remove(index) }
      }
    }
  }

  // ESC closes the open islands (focus granted while an island is active)
  Item {
    anchors.fill: parent
    focus: root.islandActive && !root.popupOpen
    Keys.onEscapePressed: root.closeAll()
  }

  function closeAll() {
    root.launcherOpen = false
    root.controlsOpen = false
    root.sessionOpen = false
    root.pickerOpen = false
    bar.barOpen = false
    leftIsland.open = false
    rightIsland.open = false
    batteryPanel.open = false
    brightnessPanel.open = false
    volumePanel.open = false
    notificationsPanel.open = false
    networkPanel.open = false
    wallCarousel.open = false
    wallGrid.open = false
    calendarPanel.open = false
  }

  // close everything, then toggle just the given panel open or closed
  function togglePanel(panel) {
    const alreadyOpen = panel.open
    root.closeAll()
    panel.open = !alreadyOpen
  }

  function toggleLauncher() {
    const wasOpen = root.launcherOpen
    root.closeAll()
    root.launcherOpen = !wasOpen
  }

  function toggleControlCenter() {
    const wasOpen = root.controlsOpen
    root.closeAll()
    root.controlsOpen = !wasOpen
  }

  function toggleSession() {
    const wasOpen = root.sessionOpen
    root.closeAll()
    root.sessionOpen = !wasOpen
  }

  // open the full-screen picker alone (right-click on the Walls button)
  function openWallPicker() {
    root.closeAll()
    root.pickerOpen = true
  }

  // keybind-driven cycle: open the full-screen picker and slide one step
  function wallpaperCycle(dir) {
    if (!root.pickerOpen) root.openWallPicker()
    wallPicker.nudge(dir)
  }
}