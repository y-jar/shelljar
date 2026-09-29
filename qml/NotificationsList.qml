/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   NotificationsList
 *
 *   A scrolling history of the notifications the shell has received. Each card
 *   shows the app's icon, name, summary, body and any inline action buttons,
 *   and can be dismissed by clicking it or its close glyph. It shows a friendly
 *   note when the history is empty.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

ColumnLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  property color itemBg: Config.surface

  // Live from the shell's NotificationServer.
  property var server: null

  spacing: Math.round(6 * Config.uiScale)

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
      spacing: Math.round(4 * Config.uiScale)

      Layout.fillWidth: true

      Surface {
        id: bodyCard
        Layout.fillWidth: true
        implicitHeight: cardContent.implicitHeight + Math.round(20 * Config.uiScale)
        radius: Config.radiusSm
        interactive: true
        hovered: cardHover.containsMouse
        fillTop: Config.surfaceMid
        fillBot: Config.surfaceLow

        MouseArea {
          id: cardHover
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: modelData.dismiss()
        }

        RowLayout {
          id: cardContent
          anchors.fill: parent
          anchors.margins: Math.round(10 * Config.uiScale)
          spacing: Math.round(9 * Config.uiScale)

          // app icon (falls back to a bell)
          Item {
            Layout.alignment: Qt.AlignTop
            width: Math.round(24 * Config.uiScale)
            height: width

            Rectangle {
              anchors.fill: parent
              radius: Math.round(6 * Config.uiScale)
              color: Config.surfaceHigh
              visible: !(appIconImg.status === Image.Ready && appIconImg.source != "")
            }
            GlyphIcon {
              anchors.centerIn: parent
              width: Math.round(14 * Config.uiScale)
              height: width
              name: "bell"
              color: Config.subtext
              stroke: 1.7
              visible: !(appIconImg.status === Image.Ready && appIconImg.source != "")
            }
            Image {
              id: appIconImg
              anchors.fill: parent
              source: modelData.appIcon ? Quickshell.iconPath(modelData.appIcon, "") : ""
              sourceSize.width: Math.round(48 * Config.uiScale)
              sourceSize.height: Math.round(48 * Config.uiScale)
              fillMode: Image.PreserveAspectFit
              asynchronous: true
              visible: status === Image.Ready && source != ""
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            ShellText {
              Layout.fillWidth: true
              text: modelData.appName || ""
              color: root.subColor
              font.pixelSize: Config.fsTiny
              elide: Text.ElideRight
            }
            ShellText {
              id: notifText
              Layout.fillWidth: true
              text: (modelData.summary || "") + (modelData.body ? "\n" + modelData.body : "")
              color: root.textColor
              font.pixelSize: Config.fsSmall
              wrapMode: Text.WordWrap
            }
          }

          GlyphIcon {
            Layout.alignment: Qt.AlignTop
            width: Math.round(11 * Config.uiScale)
            height: width
            name: "close"
            color: Config.subtext
            stroke: 1.8
            MouseArea {
              anchors.fill: parent
              anchors.margins: -Math.round(6 * Config.uiScale)
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
        spacing: Math.round(6 * Config.uiScale)

        Repeater {
          model: modelData.actions

          delegate: Surface {
            required property var modelData
            property var action: modelData
            Layout.fillWidth: true
            implicitHeight: Math.round(28 * Config.uiScale)
            radius: Config.radiusSm
            interactive: true
            hovered: actionHover.containsMouse
            fillTop: Config.surfaceHigh
            fillBot: Config.surfaceMid

            ShellText {
              anchors.centerIn: parent
              text: action.text
              color: Config.text
              font.pixelSize: Config.fsTiny
              elide: Text.ElideRight
            }
            MouseArea {
              id: actionHover
              anchors.fill: parent
              hoverEnabled: true
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
