/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   NotificationsList
 *
 *   A scrolling history of the notifications the shell has received. It shows
 *   each one with its app name, summary, body and any inline action buttons,
 *   and it can be dismissed by clicking the card or its close mark. It shows a
 *   friendly note when the history is empty.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

ColumnLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  property color itemBg: Config.surface

  // Live from the shell's NotificationServer.
  property var server: null // set by shell.qml / NotificationsPanel

  ShellText {
    visible: root.server === null || root.server.trackedNotifications.count === 0
    Layout.alignment: Qt.AlignHCenter
    Layout.fillWidth: true
    text: "Nothing here yet"
    color: root.subColor
    font.pixelSize: Config.fsSmall
    horizontalAlignment: Text.AlignHCenter
  }

  Repeater {
    id: notifRepeater
    model: root.server !== null ? root.server.trackedNotifications : null

    delegate: ColumnLayout {
      required property var modelData
      id: notif
      spacing: 0

      Layout.fillWidth: true
      Layout.preferredHeight: bodyCard.height + (actionRow.visible ? actionRow.height : 0)

      Rectangle {
        id: bodyCard
        Layout.fillWidth: true
        implicitHeight: notifText.implicitHeight + 16
        radius: 8
        color: root.itemBg
        border.color: Config.borderSoft

        MouseArea {
          anchors.fill: parent
          onClicked: modelData.dismiss()
          cursorShape: Qt.PointingHandCursor
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
              cursorShape: Qt.PointingHandCursor
              onClicked: modelData.dismiss()
            }
          }
        }
      }

      // inline action buttons offered by the notification
      RowLayout {
        id: actionRow
        Layout.fillWidth: true
        visible: !!modelData.actions && modelData.actions.length > 0
        Layout.topMargin: 4
        Layout.leftMargin: 8
        spacing: 6

        Repeater {
          model: modelData.actions

          delegate: Rectangle {
            required property var modelData
            property var action: modelData
            Layout.fillWidth: true
            implicitHeight: 26
            radius: 6
            color: Config.surfaceAlt

            ShellText {
              anchors.centerIn: parent
              text: action.text
              color: Config.text
              font.pixelSize: Config.fsTiny
              elide: Text.ElideRight
              Layout.preferredWidth: parent.width - 12
            }
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: { action.invoke(); notif.dismiss() }
            }
          }
        }
      }
    }
  }

  Item { Layout.fillHeight: true; Layout.fillWidth: true }
}