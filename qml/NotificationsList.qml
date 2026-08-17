import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

// Notification history list for the control center.
ColumnLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  property color itemBg: Config.surface

  // Live from the shell's NotificationServer.
  property var server: null // set by shell.qml

  ShellText {
    Layout.fillWidth: true
    text: "Notifications"
    color: root.textColor
    font.pixelSize: Config.fsMedium
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

        ShellText { text: "•"; color: Config.accent; font.pixelSize: Config.fsMedium }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 0
          ShellText {
            text: modelData.appName || ""
            color: root.subColor
            font.pixelSize: Config.fsTiny
          }
          ShellText {
            id: notifText
            text: (modelData.summary || "") + (modelData.body ? "\n" + modelData.body : "")
            color: root.textColor
            font.pixelSize: Config.fsSmall
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
          }
        }

        ShellText {
          text: "✕"
          color: root.subColor
          font.pixelSize: Config.fsTiny
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