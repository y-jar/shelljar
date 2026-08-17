import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

// ---- shelljar root window ----
// Single full-screen shell surface hosting every surface as an internal item
// (caelestia-style). Clickthrough is controlled by the `mask` Region so the
// empty desktop still receives clicks.
//
// IPC (target "shelljar"):
//   quickshell -p qml ipc call shelljar toggleLauncher
//   quickshell -p qml ipc call shelljar toggleControlCenter
//   quickshell -p qml ipc call shelljar close
PanelWindow {
  id: root

  anchors.top: true
  anchors.bottom: true
  anchors.left: true
  anchors.right: true

  WlrLayershell.exclusionMode: ExclusionMode.Ignore // overlay: no reserved space
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: root.popupOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
  color: "transparent"

  property bool launcherOpen: false
  property bool controlsOpen: false
  readonly property bool popupOpen: launcherOpen || controlsOpen

  // clickthrough: full screen while a popup is open (scrim closes it),
  // otherwise only the island strip + toasts are interactive.
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

  // notification daemon (implements org.freedesktop.Notifications)
  NotificationServer {
    id: notiServer
    onNotification: n => {
      n.tracked = true // keep in history for the control center
      toastsList.insert(0, {
        appName: n.appName,
        summary: n.summary,
        body: n.body,
      })
      while (toastsList.count > 4) toastsList.remove(toastsList.count - 1)
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

    MouseArea {
      anchors.fill: parent
      onClicked: root.closeAll()
    }
  }

  // ---- top-center island (auto-hide card) ----
  Island {
    id: island
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    pinned: root.popupOpen
    onUserClicked: { root.controlsOpen = !root.controlsOpen }
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
    notificationServer: notiServer
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
    visible: toastsList.count > 0

    ListModel {
      id: toastsList
    }

    Repeater {
      id: toastRepeater
      model: toastsList

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
            MouseArea {
              anchors.fill: parent
              onClicked: toastsList.remove(index)
            }
          }
        }

        Timer {
          interval: 6000
          running: true
          onTriggered: toastsList.remove(index)
        }
      }
    }
  }

  function closeAll() {
    root.launcherOpen = false
    root.controlsOpen = false
  }

  // ---- IPC ----
  IpcHandler {
    id: ipc
    target: "shelljar"

    function close(): void {
      root.closeAll()
    }

    function toggleLauncher(): void {
      root.launcherOpen = !root.launcherOpen
      if (root.launcherOpen && root.controlsOpen) root.controlsOpen = false
    }

    function toggleControlCenter(): void {
      root.controlsOpen = !root.controlsOpen
      if (root.controlsOpen && root.launcherOpen) root.launcherOpen = false
    }

    function wallpaperCycle(dir: string): void {
      island.wallpaperCycle(dir)
    }
  }
}