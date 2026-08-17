import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Top-center island that auto-hides to a thin hover strip while reserving space.
PanelWindow {
  id: root

  property bool expanded: false
  property bool pinned: false // kept expanded by an open popup

  anchors.top: true
  width: 640
  height: (expanded || pinned) ? Config.islandHeight : 12
  exclusiveZone: height // reserves this many px from the anchored edge
  WlrLayershell.layer: WlrLayer.Overlay // hover strip sits above fullscreen windows
  color: "transparent"

  Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
  Behavior on exclusiveZone { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

  property color textColor: Config.text
  property color subColor: Config.subtext
  signal userClicked

  function wallpaperCycle(dir) {
    if (wallStrip) wallStrip.cycle(dir)
  }

  // hover band + content
  Item {
    id: content
    anchors.fill: parent

    // trigger area to reveal the island
    MouseArea {
      id: hoverArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: { if (!root.pinned) root.expanded = true }
      onExited: { if (!root.pinned) root.expanded = false }
    }

    Rectangle {
      id: islandCard
      anchors.fill: parent
      radius: Config.cornerRadius
      color: Config.bg
      border.color: Qt.rgba(1,1,1,0.08)
      clip: true

      RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: 6
        spacing: Config.spacing
        visible: root.expanded

        // ---- left: tray + stats ----
        RowLayout {
          Layout.fillWidth: true
          spacing: 10
          ColumnLayout {
            spacing: 4
            Tray { }
            Stats {
              Layout.preferredWidth: 170
              Layout.alignment: Qt.AlignLeft
            }
          }
          Item { Layout.fillWidth: true }
        }

        // ---- center: clock + wallpaper ----
        RowLayout {
          spacing: 12
          Clock { }
          WallpaperStrip { id: wallStrip }
        }

        // ---- right: notifications hint + user ----
        RowLayout {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignRight
          spacing: 8

          // user / control-center button
          Rectangle {
            width: 34; height: 34; radius: 17
            color: Config.surface
            border.color: Qt.rgba(1,1,1,0.08)
            Text {
              anchors.centerIn: parent
              text: "👤"
              font.pixelSize: 16
            }
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onEntered: parent.color = Config.surfaceAlt
              onExited: parent.color = Config.surface
              onClicked: root.userClicked()
            }
          }

          Text {
            text: "◎"
            color: root.subColor
            font.pixelSize: 14
          }
          Item { Layout.fillWidth: true }
        }
      }
    }
  }
}