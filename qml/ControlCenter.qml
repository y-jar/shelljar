import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

// Right-side control center: user, audio, notifications, session.
Rectangle {
  id: root

  property bool open: false
  width: config.controlCenterWidth
  height: 420
  radius: config.cornerRadius
  color: config.bgAlt
  border.color: Qt.rgba(1,1,1,0.08)

  property color textColor: config.text
  property color subColor: config.subtext

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
          width: 42; height: 42; radius: 21
          color: config.surface
          border.color: Qt.rgba(1,1,1,0.08)
          Text {
            anchors.centerIn: parent
            text: "👤"
            font.pixelSize: 20
          }
        }

        ColumnLayout {
          spacing: 2
          Text {
            id: userLabel
            text: user()
            color: root.textColor
            font.pixelSize: 14
            font.weight: Font.DemiBold
          }
          Text {
            text: "mouse-friendly shell"
            color: root.subColor
            font.pixelSize: 9
          }
        }

        Item { Layout.fillWidth: true }
      }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Qt.rgba(1,1,1,0.06)
      }

      Text { text: "Audio"; color: root.subColor; font.pixelSize: 10 }
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
    const u = config.env("USER")
    return u != null && u !== "" ? u : "jar"
  }
}