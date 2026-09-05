/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   NotificationsPanel
 *
 *   A popout panel opened from the bar bell. It holds the list of notifications
 *   the shell has tracked, offers a button to clear them all, and can be closed
 *   with its own close mark.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root

  property bool open: false
  property var notificationServer: null
  signal closeRequested

  width: Config.notificationsWidth
  height: Config.notificationsHeight
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Config.borderStrong

  function clearAll() {
    const srv = root.notificationServer
    if (!srv || !srv.trackedNotifications) return
    for (const n of srv.trackedNotifications.values) { if (n && n.dismiss) n.dismiss() }
  }

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
        text: "Clear"
        visible: root.notificationServer !== null && root.notificationServer.trackedNotifications.count > 0
        color: Config.subtext
        font.pixelSize: Config.fsTiny
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.clearAll()
        }
      }
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
      color: Config.borderSoft
    }

    NotificationsList {
      Layout.fillWidth: true
      Layout.fillHeight: true
      server: root.notificationServer
    }
  }
}
