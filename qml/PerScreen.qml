import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

// ---- per-screen shell surface ----
// One full-screen window per monitor (caelestia-style). Hosts that screen's
// bar plus launcher, control center, session menu, and toasts.
// The clickthrough `mask` lets the empty desktop receive clicks.
PanelWindow {
  id: root

  required property var modelData
  screen: modelData // the screen Variants passes in

  readonly property string ns: screen ? "shelljar-" + screen.name : "shelljar"
  WlrLayershell.namespace: ns
  WlrLayershell.exclusionMode: ExclusionMode.Ignore // overlay: no reserved space
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: (root.popupOpen || root.barActive) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
  readonly property bool popupOpen: launcherOpen || controlsOpen || sessionOpen || notificationsPanel.open || volumePanel.open
  readonly property bool barActive: bar.barOpen

  // clickthrough: full screen while a popup or the bar is open, otherwise only the bar
  mask: Region {
    x: (root.popupOpen || root.barActive) ? 0 : bar.x
    y: (root.popupOpen || root.barActive) ? 0 : bar.y
    width: (root.popupOpen || root.barActive) ? root.width : bar.width
    height: (root.popupOpen || root.barActive) ? root.height : bar.height

    Region {
      x: toasts.x
      y: toasts.y
      width: (!root.popupOpen && toasts.visible) ? toasts.width : 0
      height: (!root.popupOpen && toasts.visible) ? toasts.height : 0
    }
  }

  // ---- dim scrim behind open popups ----
  Rectangle {
    id: scrim
    anchors.fill: parent
    color: "#00000060"
    visible: root.popupOpen
    opacity: root.popupOpen ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 120 } }
    MouseArea { anchors.fill: parent; onClicked: root.closeAll() }
  }

  // ---- transparent click-catcher: clicking away from the open bar closes it ----
  MouseArea {
    anchors.fill: parent
    visible: root.barActive && !root.popupOpen
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: { bar.barOpen = false; wallCarousel.open = false; wallGrid.open = false; batteryPanel.open = false; brightnessPanel.open = false; notificationsPanel.open = false; volumePanel.open = false }
  }

  // ---- bar (top strip / expanded two rows) ----
  Bar {
    id: bar
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    notificationServer: root.notificationServer
    onPowerClicked: { root.closeAll(); root.sessionOpen = true }
    onControlClicked: { root.closeAll(); root.controlsOpen = true }
    onNotificationsRequested: {
      root.launcherOpen = false
      root.controlsOpen = false
      root.sessionOpen = false
      wallCarousel.open = false
      wallGrid.open = false
      batteryPanel.open = false
      brightnessPanel.open = false
      volumePanel.open = false
      notificationsPanel.open = !notificationsPanel.open
    }
    onWallpaperOpenRequested: dir => {
      root.launcherOpen = false
      root.controlsOpen = false
      root.sessionOpen = false
      wallGrid.open = false
      wallCarousel.open = true
      wallCarousel.nudge(dir)
    }
    onWallpaperGridRequested: {
      root.launcherOpen = false
      root.controlsOpen = false
      root.sessionOpen = false
      wallCarousel.open = false
      wallGrid.open = true
    }
    onOsdHoverRequested: { osd.showVolume(); osd.hover() }
    onOsdValueChanged: osd.showVolume()
    onOsdBrightnessHoverRequested: { osd.showBrightness(BrightnessService.value); osd.hover() }
    onOsdBrightnessValueChanged: osd.showBrightness(BrightnessService.value)
    onVolumePanelRequested: {
      root.launcherOpen = false
      root.controlsOpen = false
      root.sessionOpen = false
      wallCarousel.open = false
      wallGrid.open = false
      batteryPanel.open = false
      brightnessPanel.open = false
      notificationsPanel.open = false
      volumePanel.open = !volumePanel.open
    }
    onBatteryPanelRequested: {
      root.launcherOpen = false
      root.controlsOpen = false
      root.sessionOpen = false
      wallCarousel.open = false
      wallGrid.open = false
      brightnessPanel.open = false
      notificationsPanel.open = false
      volumePanel.open = false
      batteryPanel.open = true
    }
    onBrightnessPanelRequested: {
      root.launcherOpen = false
      root.controlsOpen = false
      root.sessionOpen = false
      wallCarousel.open = false
      wallGrid.open = false
      batteryPanel.open = false
      notificationsPanel.open = false
      volumePanel.open = false
      brightnessPanel.open = true
    }
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

  // ---- battery panel (pop-out) ----
  BatteryPanel {
    id: batteryPanel
    anchors.horizontalCenter: bar.horizontalCenter
    anchors.top: bar.bottom
    anchors.topMargin: 8
    visible: open
    open: false
    onCloseRequested: open = false
  }

  // ---- brightness panel (pop-out) ----
  BrightnessPanel {
    id: brightnessPanel
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

  // ---- launcher (grid) ----
  Launcher {
    id: launcher
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: bar.bottom
    anchors.topMargin: 12
    visible: root.launcherOpen
    open: root.launcherOpen
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

  // ---- toast notifications (top-right) ----
  ColumnLayout {
    id: toasts
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.top: bar.bottom
    anchors.topMargin: 12
    width: 360
    spacing: 6
    visible: root.toastsModel ? root.toastsModel.count > 0 : false

    Repeater {
      id: toastRepeater
      model: root.toastsModel

      delegate: Rectangle {
        required property var modelData
        required property int index
        width: 348
        height: toastText.implicitHeight + 16
        radius: 10
        color: Config.bg
        border.color: Qt.rgba(1,1,1,0.08)

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

        Timer { interval: 6000; running: true; onTriggered: root.toastsModel.remove(index) }
      }
    }
  }

  // ESC closes the open bar (focus granted while the bar is active)
  Item {
    anchors.fill: parent
    focus: root.barActive && !root.popupOpen
    Keys.onEscapePressed: {
      bar.barOpen = false
      wallCarousel.open = false
      wallGrid.open = false
      batteryPanel.open = false
      brightnessPanel.open = false
      notificationsPanel.open = false
      volumePanel.open = false
    }
  }

  function closeAll() {
    root.launcherOpen = false
    root.controlsOpen = false
    root.sessionOpen = false
    bar.barOpen = false
  }

  function toggleLauncher(): void {
    root.launcherOpen = !root.launcherOpen
    if (root.launcherOpen && root.controlsOpen) root.controlsOpen = false
  }

  function toggleControlCenter(): void {
    root.controlsOpen = !root.controlsOpen
    if (root.controlsOpen && root.launcherOpen) root.launcherOpen = false
  }

  function toggleSession(): void {
    root.closeAll()
    root.sessionOpen = !root.sessionOpen
  }
}
