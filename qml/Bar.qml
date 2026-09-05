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
 *   click expands it into two rows. Row one holds the profile hamburger and the
 *   centered clock with notifications and volume on the right. Row two holds
 *   the walls button and the system stats.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
  id: root

  // collapsed = thin ~20% strip; expanded = auto-fit to its content (no cutoff)
  readonly property real stripWidth: Math.max(140, Math.round((parent ? parent.width : 1600) * Config.dockWidthRatio))
  width: barOpen ? Math.max(Config.minDockWidth, barLayout.implicitWidth + 16) : stripWidth
  height: barOpen ? Config.dockHeight : Config.stripHeight

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

  Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
  Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

  Rectangle {
    id: card
    anchors.fill: parent
    radius: Config.cornerRadius
    color: Config.bg
    border.color: Config.borderStrong
    clip: true

    // right-click toggles the expanded bar
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
      height: 4
      radius: 2
      color: Config.surfaceAlt
    }

    // expanded content
    ColumnLayout {
      id: barLayout
      anchors.fill: parent
      anchors.margins: 8
      spacing: Config.spacing
      visible: root.barOpen

      // ==== row 1 (clock dead-centered; clusters anchor to the edges) ====
      Item {
        Layout.fillWidth: true
        implicitWidth: Math.round(230 * Config.uiScale)
        implicitHeight: Math.round(30 * Config.uiScale)
        Layout.alignment: Qt.AlignVCenter
        clip: false

        Clock {
          id: clock
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          z: 1
          onClicked: root.clockClicked()
        }

        // left cluster: profile hamburger (opens control center)
        RowLayout {
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          spacing: 0
          Rectangle {
            Layout.preferredWidth: Config.iconButtonSize
            Layout.preferredHeight: width
            radius: width / 2
            color: root.hovered(hamb) ? Config.surfaceAlt : Config.surface
            border.color: Config.borderMid
            ShellText {
              anchors.centerIn: parent
              text: "☰"
              color: Config.text
              font.pixelSize: Config.fsSmall
            }
            MouseArea {
              id: hamb
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.controlClicked()
            }
          }
        }

        // right cluster: notifications + sound
        RowLayout {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8

          Rectangle {
            id: notifBtn
            Layout.preferredWidth: Config.iconButtonSize
            Layout.preferredHeight: width
            radius: width / 2
            color: root.hovered(notifHover) ? Config.surfaceAlt : Config.surface
            border.color: Config.borderMid
            ShellText {
              anchors.centerIn: parent
              text: "🔔"
              font.pixelSize: Config.fsSmall
            }
            Rectangle {
              visible: root.notificationServer && root.notificationServer.trackedNotifications.count > 0
              anchors.top: parent.top
              anchors.right: parent.right
              anchors.margins: 1
              width: Config.eventBadgeSize; height: Config.eventBadgeSize; radius: Config.eventBadgeSize / 2
              color: Config.red
              ShellText {
                anchors.centerIn: parent
                text: String(root.notificationServer ? root.notificationServer.trackedNotifications.count : 0)
                color: Config.white
                font.pixelSize: Config.fsTiny
                font.weight: Font.DemiBold
              }
            }
            MouseArea {
              id: notifHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.notificationsRequested()
            }
          }

          VolumeWidget {
            onToggleRequested: root.volumePanelRequested()
            onHoverRequested: root.osdHoverRequested()
            onValueChanged: root.osdValueChanged()
          }
        }
      }

      // ==== row 2 ====
      RowLayout {
        Layout.fillWidth: true
        implicitHeight: Math.round(34 * Config.uiScale)
        Layout.alignment: Qt.AlignVCenter
        spacing: 6

        WallpaperStrip {
          onOpenRequested: dir => root.wallpaperOpenRequested(dir)
          onGridRequested: root.wallpaperGridRequested()
          onPickerRequested: root.wallpaperPickerRequested()
        }
        Stats { }
        Item { Layout.fillWidth: true }
      }
    }
  }

  // hover helper so pill MouseAreas can share one color transform
  function hovered(m) { return !!m && m.containsMouse }
}
