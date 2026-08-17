import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

// Notification history list for the control center.
ColumnLayout {
  id: root

  property color textColor: config.text
  property color subColor: config.subtext
  property color itemBg: config.surface

  // Live from the shell's NotificationServer.
  readonly property var server: null // set by shell.qml

  Text {
    Layout.fillWidth: true
    text: "Notifications"
    color: root.textColor
    font.pixelSize: 12
    font.weight: Font.DemiBold
  }

  Repeater {
    id: notifRepeater
    model: root.server !== null ? root.server.trackedNotifications : null

    delegate: Rectangle {
      required property var modelData
      id: notif

      Layout.fillWidth: true
      implicitHeight: notifText.implicitHeight + 16
      radius: 8
      color: root.itemBg
      border.color: Qt.rgba(1,1,1,0.05)

      MouseArea {
        anchors.fill: parent
        onClicked: modelData.dismiss()
      }

      RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text { text: "•"; color: config.accent; font.pixelSize: 12 }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 0
          Text {
            text: modelData.appName || ""
            color: root.subColor
            font.pixelSize: 9
          }
          Text {
            id: notifText
            text: (modelData.summary || "") + (modelData.body ? "\n" + modelData.body : "")
            color: root.textColor
            font.pixelSize: 11
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
          }
        }

        Text {
          text: "✕"
          color: root.subColor
          font.pixelSize: 10
          MouseArea {
            anchors.fill: parent
            onClicked: modelData.dismiss()
          }
        }
      }
    }
  }

  Item { Layout.fillHeight: true; Layout.fillWidth: true }
}