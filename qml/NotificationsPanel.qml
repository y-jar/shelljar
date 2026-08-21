import qs.components
import QtQuick
import QtQuick.Layouts

// Pop-out notification history panel, opened from a dock button. Holds the
// list of tracked notifications from the shell's NotificationServer.
Rectangle {
  id: root

  property bool open: false
  property var notificationServer: null
  signal closeRequested

  width: Math.round(330 * Config.uiScale)
  height: Math.round(360 * Config.uiScale)
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Qt.rgba(1,1,1,0.10)

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8

    RowLayout {
      Layout.fillWidth: true
      ShellText {
        text: "Notifications"
        color: Config.text
        font.pixelSize: Config.fsMedium
        font.weight: Font.DemiBold
      }
      Item { Layout.fillWidth: true }
      ShellText {
        text: "✕"
        color: Config.subtext
        font.pixelSize: Config.fsSmall
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.closeRequested()
        }
      }
    }

    Rectangle {
      Layout.fillWidth: true
      height: 1
      color: Qt.rgba(1,1,1,0.06)
    }

    NotificationsList {
      Layout.fillWidth: true
      Layout.fillHeight: true
      server: root.notificationServer
    }
  }
}
