import qs.components
import QtQuick
import QtQuick.Layouts

// Top-center island card, hosted inside RootWindow.
// Auto-hides to a thin hover strip; hovering (or an open popup) expands it.
Item {
  id: root

  width: (expanded || pinned) ? Math.max(Config.minIslandWidth, root.contentWidth) : Config.stripPillWidth
  height: (expanded || pinned) ? Config.islandHeight : Config.stripHeight

  readonly property real contentWidth: row ? row.implicitWidth + 12 : Config.islandWidth

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

  // hover band to reveal the island
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

    RowLayout {
      id: row
      anchors.fill: parent
      anchors.margins: 6
      spacing: Config.spacing
      visible: root.expanded

      // ---- left: tray + stats (horizontal) ----
      RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Tray { }
        Stats { }
      }
      Item { Layout.fillWidth: true }

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

          // power menu pill opener
          Rectangle {
            width: 40; height: 26; radius: 13
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
              onEntered: parent.color = Config.surfaceAlt
              onExited: parent.color = Config.surface
              onClicked: root.powerClicked()
            }
          }
          Item { Layout.fillWidth: true }
      }
    }
  }
}