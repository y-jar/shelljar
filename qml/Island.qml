import qs.components
import QtQuick
import QtQuick.Layouts

// Top-center island card, hosted inside RootWindow.
// Collapsed = a small always-visible ⏻ power pill. Clicking it opens the power
// menu (reliable, no hover needed); hovering the island expands it into the full
// bar (tray + stats + clock + wallpaper + user) and collapses on leave.
Item {
  id: root

  width: (expanded || pinned) ? Math.max(Config.minIslandWidth, root.contentWidth) : Config.stripPillWidth
  height: (expanded || pinned) ? Config.islandHeight : Config.pillHeight

  readonly property real contentWidth: row ? (Config.stripPillWidth + 6 + row.implicitWidth) : Config.islandWidth

  property bool expanded: false
  property bool pinned: false // kept expanded by an open popup
  property color textColor: Config.text
  property color subColor: Config.subtext
  signal userClicked
  signal powerClicked

  Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
  Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

  function wallpaperCycle(dir) {
    if (wallStrip) wallStrip.cycle(dir)
  }

  Rectangle {
    id: islandCard
    anchors.fill: parent
    radius: Config.cornerRadius
    color: Config.bg
    border.color: Qt.rgba(1,1,1,0.08)
    clip: true

    // whole-card hover: expand on enter, collapse on leave (unless pinned)
    MouseArea {
      id: hoverArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: { if (!root.pinned) root.expanded = true }
      onExited: { if (!root.pinned) root.expanded = false }
    }

    // ---- power pill (always visible, left-anchored: stays put on expand) ----
    Rectangle {
      id: powerPill
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: root.expanded ? Config.spacing : 0
      width: Config.stripPillWidth
      height: Config.pillHeight
      radius: height / 2
      color: Config.surface
      border.color: Qt.rgba(1,1,1,0.10)

      ShellText {
        anchors.centerIn: parent
        text: "⏻"
        color: Config.red
        font.pixelSize: Config.fsSmall
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: { if (!root.pinned) root.expanded = true }
        onClicked: root.powerClicked()
      }
    }

    // ---- rest of the bar (only when expanded) ----
    RowLayout {
      id: row
      anchors.left: powerPill.right
      anchors.leftMargin: Config.spacing
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: Config.spacing
      visible: root.expanded

      // left: tray + stats (horizontal)
      RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Tray { }
        Stats { }
      }
      Item { Layout.fillWidth: true }

      // center: clock + wallpaper
      RowLayout {
        spacing: 12
        Clock { }
        WallpaperStrip { id: wallStrip }
      }

      // right: notifications hint + user
      RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight
        spacing: 8

        Rectangle {
          width: 34; height: 34; radius: 17
          color: Config.surface
          border.color: Qt.rgba(1,1,1,0.08)
          ShellText {
            anchors.centerIn: parent
            text: "👤"
            font.pixelSize: Config.fsMedium
          }
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.color = Config.surfaceAlt
            onExited: parent.color = Config.surface
            onClicked: root.userClicked()
          }
        }

        ShellText {
          text: "◎"
          color: root.subColor
          font.pixelSize: Config.fsSmall
        }
        Item { Layout.fillWidth: true }
      }
    }
  }
}