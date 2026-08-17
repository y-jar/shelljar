import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

// ---- shelljar root ----
// Wires surfaces together and exposes IPC under the "shelljar" target:
//   quickshell -p qml ipc call shelljar toggleLauncher
//   quickshell -p qml ipc call shelljar toggleControlCenter
//   quickshell -p qml ipc call shelljar close
Item {
  id: root

  property bool launcherOpen: false
  property bool controlsOpen: false
  property bool pinned: launcherOpen || controlsOpen

  // notification daemon (implements org.freedesktop.Notifications)
  NotificationServer {
    id: notiServer
    onNotification: n => {
      n.tracked = true // keep in history for the control center
      toasts.insert(0, {
        appName: n.appName,
        summary: n.summary,
        body: n.body,
      })
      while (toasts.count > 4) toasts.remove(toasts.count - 1)
    }
  }

  // ---- top-center island ----
  Island {
    id: island
    pinned: root.pinned
    onUserClicked: { root.controlsOpen = !root.controlsOpen }
  }

  // ---- launcher (grid) ----
  PopupWindow {
    id: launcherWin
    anchor.window: island
    anchor.rect.x: island.width / 2 - width / 2
    anchor.rect.y: island.height + 8
    width: config.launcherWidth
    height: config.launcherHeight
    visible: root.launcherOpen

    Launcher {
      id: launcher
      open: root.launcherOpen
    }
  }

  // ---- control center ----
  PopupWindow {
    id: controlsWin
    anchor.window: island
    anchor.rect.x: island.width - config.controlCenterWidth - 10
    anchor.rect.y: island.height + 8
    width: config.controlCenterWidth
    height: 430
    visible: root.controlsOpen

    ControlCenter {
      id: controls
      open: root.controlsOpen
      notificationServer: notiServer
    }
  }

  // ---- toast notifications (top-right) ----
  PopupWindow {
    id: notifyWin
    anchor.window: island
    anchor.rect.x: island.width - 360 - 12
    anchor.rect.y: island.height + 8
    width: 360
    height: 200
    visible: toasts.count > 0
    color: "transparent"

    ColumnLayout {
      anchors.fill: parent
      spacing: 6

      Repeater {
        id: toastRepeater
        model: toasts

        delegate: Rectangle {
          required property var modelData
          required property int index
          width: 348
          height: toastText.implicitHeight + 16
          radius: 10
          color: config.bg
          border.color: Qt.rgba(1,1,1,0.08)

          RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
            Text {
              text: "▣"
              color: config.accent
              font.pixelSize: 16
            }
            ColumnLayout {
              Layout.fillWidth: true
              spacing: 0
              Text {
                text: modelData.appName || ""
                color: config.accent
                font.pixelSize: 10
              }
              Text {
                id: toastText
                text: (modelData.summary || "") + (modelData.body ? "\n" + modelData.body : "")
                color: config.text
                font.pixelSize: 11
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
              }
            }
            Rectangle {
              width: 16; height: 16; radius: 8; color: "transparent"
              Text {
                anchors.centerIn: parent
                text: "✕"
                color: config.subtext
                font.pixelSize: 10
              }
              MouseArea {
                anchors.fill: parent
                onClicked: toasts.remove(index)
              }
            }
          }

          Timer {
            interval: 6000
            running: true
            onTriggered: toasts.remove(index)
          }
        }
      }
    }
  }

  // recent toasts kept for auto-removal; count > 0 shows the window
  ListModel {
    id: toasts
  }

  // ---- IPC ----
  IpcHandler {
    id: ipc
    target: "shelljar"

    function close(): void {
      root.launcherOpen = false
      root.controlsOpen = false
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