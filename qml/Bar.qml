/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Bar
 *
 *   The top center island per screen. Collapsed it is a thin strip and a right
 *   click expands it into one row: the profile button and system stats on the
 *   left, the clock and date dead center, and the wallpaper, notifications and
 *   sound controls on the right. With `Config.barEdgeMerge` the card's top
 *   corners are squared and EdgeFillets blend it into the top of the screen.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
  id: root

  readonly property real stripWidth: Math.max(140, Math.round((parent ? parent.width : 1600) * Config.dockWidthRatio))
  readonly property real contentMargin: Math.round(8 * Config.uiScale)
  readonly property real contentGap: Math.round(22 * Config.uiScale)
  // true-centered clock: reserve the wider cluster on both sides
  readonly property real contentWidth: 2 * Math.max(leftCluster.implicitWidth, rightCluster.implicitWidth)
    + clock.width + 2 * root.contentGap
  width: barOpen ? Math.max(Config.minDockWidth, root.contentWidth + 2 * root.contentMargin) : root.stripWidth
  height: barOpen ? Config.barHeight : Config.stripHeight

  property bool barOpen: false
  // wired by PerScreen for the notifications button badge count
  property var notificationServer: null
  signal controlClicked
  signal notificationsRequested
  signal wallpaperOpenRequested(var dir)
  signal wallpaperGridRequested
  signal wallpaperPickerRequested
  signal osdHoverRequested
  signal osdValueChanged
  signal volumePanelRequested
  signal clockClicked

  Behavior on width { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }
  Behavior on height { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

  // concave corners that let the bar flow into the screen's top edge
  EdgeFillet {
    side: "left"
    size: root.merge ? Math.min(Config.edgeFilletRadius, root.height) : 0
    visible: root.merge
    x: -width
    y: 0
    color: Config.surfaceMid
  }
  EdgeFillet {
    side: "right"
    size: root.merge ? Math.min(Config.edgeFilletRadius, root.height) : 0
    visible: root.merge
    x: root.width
    y: 0
    color: Config.surfaceMid
  }

  Surface {
    id: card
    anchors.fill: parent
    radius: Config.cornerRadius
    topLeftRadius: root.merge ? 0 : Config.cornerRadius
    topRightRadius: root.merge ? 0 : Config.cornerRadius
    topEdgeFlush: root.merge
    clip: false

    // right-click on empty bar space toggles the expanded bar
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.RightButton
      onClicked: root.barOpen = !root.barOpen
    }

    // strip hint (visible when collapsed)
    Rectangle {
      anchors.centerIn: parent
      visible: !root.barOpen
      width: Math.round(parent.width * 0.5)
      height: Math.max(3, Math.round(4 * Config.uiScale))
      radius: height / 2
      color: Config.surfaceAlt
    }

    // expanded content (single row)
    Item {
      id: content
      anchors.fill: parent
      anchors.margins: root.contentMargin
      visible: root.barOpen

      // left cluster: profile + stats
      RowLayout {
        id: leftCluster
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Math.round(8 * Config.uiScale)

        IconButton {
          glyph: "menu"
          tooltip: "Control center"
          onClicked: root.controlClicked()
        }

        Divider {
          vertical: true
          Layout.fillHeight: true
          Layout.topMargin: Math.round(7 * Config.uiScale)
          Layout.bottomMargin: Math.round(7 * Config.uiScale)
          Layout.preferredWidth: 1
        }

        Stats { }
      }

      // right cluster: wallpaper + notifications + sound
      RowLayout {
        id: rightCluster
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Math.round(8 * Config.uiScale)

        WallpaperStrip {
          onOpenRequested: dir => root.wallpaperOpenRequested(dir)
          onGridRequested: root.wallpaperGridRequested()
          onPickerRequested: root.wallpaperPickerRequested()
        }

        // notifications with a count badge
        Item {
          implicitWidth: Config.iconButtonSize
          implicitHeight: Config.iconButtonSize

          IconButton {
            anchors.fill: parent
            glyph: "bell"
            tooltip: "Notifications"
            onClicked: root.notificationsRequested()
          }

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

        VolumeWidget {
          onToggleRequested: root.volumePanelRequested()
          onHoverRequested: root.osdHoverRequested()
          onValueChanged: root.osdValueChanged()
        }
      }

      // clock dead center (independent of the clusters' widths)
      Clock {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        onClicked: root.clockClicked()
      }
    }
  }

  readonly property bool merge: Config.barEdgeMerge
}
