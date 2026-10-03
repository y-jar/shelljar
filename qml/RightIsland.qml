/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   RightIsland
 *
 *   The auto hiding island on the right edge of the screen. Collapsed it is a
 *   slim bar and a right click expands it into one row holding the battery pill
 *   and the brightness pill. When the machine has no battery it shows a small
 *   tag from Config instead.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  readonly property real stripW: Math.max(120, Math.round(150 * Config.uiScale))
  width: open ? Math.max(Config.minDockWidth, (content ? content.implicitWidth + 16 : stripW))
              : stripW
  height: open ? Config.islandHeight : Config.stripHeight

  property bool open: false
  property var notificationServer: null
  signal notificationsRequested
  signal batteryPanelRequested
  signal brightnessPanelRequested
  signal osdBrightnessHoverRequested
  signal osdBrightnessValueChanged

  Behavior on width { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }
  Behavior on height { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

  Surface {
    id: card
    anchors.fill: parent
    radius: Config.cornerRadius
    clip: false

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.RightButton
      onClicked: root.open = !root.open
    }

    Rectangle {
      anchors.centerIn: parent
      visible: !root.open
      width: Math.round(parent.width * 0.5)
      height: Math.max(3, Math.round(4 * Config.uiScale))
      radius: height / 2
      color: Config.surfaceAlt
    }

    RowLayout {
      id: content
      anchors.fill: parent
      anchors.margins: 8
      spacing: 6
      visible: root.open

      readonly property real slide: root.open ? 0 : Math.round(5 * Config.uiScale)
      opacity: root.open ? 1 : 0
      transform: Translate {
        y: content.slide
        Behavior on y { NumberAnimation { duration: Motion.glide; easing.type: Motion.easeStandard } }
      }
      Behavior on opacity {
        SequentialAnimation {
          PauseAnimation { duration: 20 }
          NumberAnimation { duration: Motion.glide; easing.type: Motion.easeStandard }
        }
      }

      // When no battery (e.g. a desktop PC) show a small tag instead.
      // BatteryWidget hides itself when it has no battery, so mirror its state.
      ShellText {
        visible: batteryWidget.hasBattery === false
        text: Config.desktopTag
        color: Config.subtext
        font.pixelSize: Config.fsSmall
        elide: Text.ElideRight
      }

      BatteryWidget {
        id: batteryWidget
        onBatteryClicked: root.batteryPanelRequested()
      }
      BrightnessWidget {
        onHoverRequested: root.osdBrightnessHoverRequested()
        onValueChanged: root.osdBrightnessValueChanged()
        onBrightnessPanelRequested: root.brightnessPanelRequested()
      }

      // notifications live here (right island) so the toast, this bell and the
      // history panel all sit in the same top-right zone
      IconButton {
        id: notifButton
        glyph: "bell"
        tooltip: "Notifications"
        onClicked: root.notificationsRequested()

        Rectangle {
          visible: root.notificationServer && root.notificationServer.trackedNotifications.count > 0
          anchors.top: parent.top
          anchors.right: parent.right
          anchors.margins: 1
          width: Config.eventBadgeSize
          height: Config.eventBadgeSize
          radius: Config.eventBadgeSize / 2
          color: Config.red
          ShellText {
            anchors.centerIn: parent
            text: String(root.notificationServer ? root.notificationServer.trackedNotifications.count : 0)
            color: Config.white
            font.pixelSize: Config.fsTiny
            font.weight: Font.DemiBold
          }
        }
      }
    }
  }
}