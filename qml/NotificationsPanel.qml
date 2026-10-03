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

Panel {
  id: root
  anchors.fill: parent

  property var notificationServer: null
  signal closeRequested

  function clearAll() {
    const srv = root.notificationServer
    if (!srv || !srv.trackedNotifications) return
    for (const n of srv.trackedNotifications.values) { if (n && n.dismiss) n.dismiss() }
  }

  ColumnLayout {
    anchors.fill: parent
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

      // clear-all pill
      Surface {
        visible: root.notificationServer !== null && root.notificationServer.trackedNotifications.count > 0
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: clearLabel.implicitWidth + Math.round(22 * Config.uiScale)
        implicitHeight: Math.round(26 * Config.uiScale)
        radius: height / 2
        interactive: true
        hovered: clearHover.containsMouse
        fillTop: Config.surfaceHigh
        fillBot: Config.surfaceMid

        ShellText {
          id: clearLabel
          anchors.centerIn: parent
          text: "Clear all"
          color: Config.text
          font.pixelSize: Config.fsTiny
        }
        MouseArea {
          id: clearHover
          anchors.fill: parent
          hoverEnabled: true
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
