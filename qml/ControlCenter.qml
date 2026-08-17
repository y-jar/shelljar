import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications

// Right-side control center: user, audio, notifications, session.
Rectangle {
  id: root

  property bool open: false
  width: Config.controlCenterWidth
  height: 420
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Qt.rgba(1,1,1,0.08)

  property color textColor: Config.text
  property color subColor: Config.subtext

  // wired up by shell.qml
  property var notificationServer: null

  ScrollView {
    anchors.fill: parent
    anchors.margins: 14
    clip: true

    ColumnLayout {
      width: parent.width
      spacing: 12

      // user row
      RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
          width: Math.round(42 * Config.uiScale); height: Math.round(42 * Config.uiScale); radius: 21
          color: Config.surface
          border.color: Qt.rgba(1,1,1,0.08)
          ShellText {
            anchors.centerIn: parent
            text: "👤"
            font.pixelSize: Config.fsLarge
          }
        }

        ColumnLayout {
          spacing: 2
          ShellText {
            id: userLabel
            text: user()
            color: root.textColor
            font.pixelSize: Config.fsMedium
            font.weight: Font.DemiBold
          }
          ShellText {
            text: "mouse-friendly shell"
            color: root.subColor
            font.pixelSize: Config.fsTiny
          }
        }

        Item { Layout.fillWidth: true }
      }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Qt.rgba(1,1,1,0.06)
      }

      ShellText { text: "Audio"; color: root.subColor; font.pixelSize: Config.fsTiny }
      AudioWidget { }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Qt.rgba(1,1,1,0.06)
      }

      NotificationsList {
        id: notifList
        Layout.fillWidth: true
        Layout.fillHeight: true
        server: root.notificationServer
      }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Qt.rgba(1,1,1,0.06)
      }

      PowerWidget { Layout.fillWidth: true }
    }
  }

function user() {
    const u = Quickshell.env("USER")
    return u != null && u !== "" ? u : "jar"
  }
}