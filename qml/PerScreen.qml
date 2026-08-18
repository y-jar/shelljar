import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

// ---- per-screen shell surface ----
// One full-screen window per monitor (caelestia-style). Hosts that screen's
// island strip/dock plus launcher, control center, session menu, and toasts.
// The clickthrough `mask` lets the empty desktop receive clicks.
PanelWindow {
  id: root

  required property var modelData
  screen: modelData // the screen Variants passes in

  readonly property string ns: screen ? "shelljar-" + screen.name : "shelljar"
  WlrLayershell.namespace: ns
  WlrLayershell.exclusionMode: ExclusionMode.Ignore // overlay: no reserved space
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: (root.popupOpen || root.dockActive) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
  readonly property bool popupOpen: launcherOpen || controlsOpen || sessionOpen
  readonly property bool dockActive: island.dockOpen

  // clickthrough: full screen while a popup or the dock is open, otherwise only the island
  mask: Region {
    x: (root.popupOpen || root.dockActive) ? 0 : island.x
    y: (root.popupOpen || root.dockActive) ? 0 : island.y
    width: (root.popupOpen || root.dockActive) ? root.width : island.width
    height: (root.popupOpen || root.dockActive) ? root.height : island.height

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

  // ---- transparent click-catcher: clicking away from the open dock closes it ----
  MouseArea {
    anchors.fill: parent
    visible: root.dockActive && !root.popupOpen
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: { island.dockOpen = false; wallCarousel.open = false; wallGrid.open = false; batteryPanel.open = false }
  }

  // ---- island strip / dock ----
  Island {
    id: island
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    onPowerClicked: { root.closeAll(); root.sessionOpen = true }
    onControlClicked: { root.closeAll(); root.controlsOpen = true }
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
    onBatteryPanelRequested: {
      root.launcherOpen = false
      root.controlsOpen = false
      root.sessionOpen = false
      wallCarousel.open = false
      wallGrid.open = false
      batteryPanel.open = true
    }
  }

  // ---- volume/brightness OSD (top-right) ----
  Osd { id: osd }

  // ---- battery panel (pop-out) ----
  BatteryPanel {
    id: batteryPanel
    anchors.horizontalCenter: island.horizontalCenter
    anchors.top: island.bottom
    anchors.topMargin: 8
    visible: open
    open: false
    onCloseRequested: open = false
  }

  // ---- wallpaper preview carousel (pop-out) ----
  WallpaperCarousel {
    id: wallCarousel
    anchors.horizontalCenter: island.horizontalCenter
    anchors.top: island.bottom
    anchors.topMargin: 8
    visible: open
    open: false
    onCloseRequested: open = false
  }

  // ---- wallpaper picker grid (pop-out) ----
  WallpaperGrid {
    id: wallGrid
    anchors.horizontalCenter: island.horizontalCenter
    anchors.top: island.bottom
    anchors.topMargin: 8
    visible: open
    open: false
    onCloseRequested: open = false
  }

  // ---- launcher (grid) ----
  Launcher {
    id: launcher
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: island.bottom
    anchors.topMargin: 12
    visible: root.launcherOpen
    open: root.launcherOpen
  }

  // ---- control center ----
  ControlCenter {
    id: controls
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.top: island.bottom
    anchors.topMargin: 12
    visible: root.controlsOpen
    open: root.controlsOpen
    notificationServer: root.notificationServer
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
    anchors.top: island.bottom
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

  // ESC closes the open dock (focus granted while the dock is active)
  Item {
    anchors.fill: parent
    focus: root.dockActive && !root.popupOpen
    Keys.onEscapePressed: {
      island.dockOpen = false
      wallCarousel.open = false
      wallGrid.open = false
      batteryPanel.open = false
    }
  }

  function closeAll() {
    root.launcherOpen = false
    root.controlsOpen = false
    root.sessionOpen = false
    island.dockOpen = false
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