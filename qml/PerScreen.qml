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

  readonly property string ns: screen ? "shelljar-" + screen.name : "shelljar"
  WlrLayershell.namespace: ns
  WlrLayershell.exclusionMode: ExclusionMode.Ignore // overlay: no reserved space
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: root.popupOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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

  // clickthrough: full screen while a popup is open, otherwise only the island
  mask: Region {
    x: root.popupOpen ? 0 : island.x
    y: root.popupOpen ? 0 : island.y
    width: root.popupOpen ? root.width : island.width
    height: root.popupOpen ? root.height : island.height

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

  // ---- island strip / dock ----
  Island {
    id: island
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    onPowerClicked: { root.closeAll(); root.sessionOpen = true }
    onLauncherClicked: { root.closeAll(); root.launcherOpen = true }
    onControlClicked: { root.closeAll(); root.controlsOpen = true }
    onLockRequested: Quickshell.execDetached(["sh", "-c", "loginctl lock-session"])
    onSuspendRequested: Quickshell.execDetached(["sh", "-c", "systemctl suspend"])
    onLogoutRequested: Quickshell.execDetached(["sh", "-c", "loginctl terminate-user ${USER}"])
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