import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell

// Top-center island per screen. Collapsed = a thin, long strip (~20% screen
// width). Right-click toggles open the dock: stats + tray + clock + wallpaper
// and action buttons (left-click opens the matching panel / runs the action).
Item {
  id: root

  width: Math.max(140, Math.round((parent ? parent.width : 1600) * Config.dockWidthRatio))
  height: dockOpen ? Config.dockHeight : Config.stripHeight

  readonly property var actions: [
    { key: "power", glyph: "⚡" },
    { key: "launcher", glyph: "▦" },
    { key: "control", glyph: "☰" },
    { key: "lock", glyph: "🔒" },
    { key: "suspend", glyph: "⏾" },
    { key: "logout", glyph: "↪" },
  ]

  property bool dockOpen: false
  property bool pinned: false // unused; kept for future
  signal powerClicked
  signal launcherClicked
  signal controlClicked
  signal lockRequested
  signal suspendRequested
  signal logoutRequested

  Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
  Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

  function runAction(key) {
    if (key === "power") { dockOpen = false; powerClicked() }
    else if (key === "launcher") { dockOpen = false; launcherClicked() }
    else if (key === "control") { dockOpen = false; controlClicked() }
    else if (key === "lock") { dockOpen = false; lockRequested() }
    else if (key === "suspend") { dockOpen = false; suspendRequested() }
    else if (key === "logout") { dockOpen = false; logoutRequested() }
  }

  Rectangle {
    id: card
    anchors.fill: parent
    radius: Config.cornerRadius
    color: Config.bg
    border.color: Qt.rgba(1,1,1,0.10)
    clip: true

    // right-click toggles the dock
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.RightButton
      onClicked: root.dockOpen = !root.dockOpen
    }

    // strip hint (visible when collapsed)
    Rectangle {
      anchors.centerIn: parent
      visible: !root.dockOpen
      width: Math.round(parent.width * 0.5)
      height: 4
      radius: 2
      color: Config.surfaceAlt
    }

    // dock content
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 8
      spacing: Config.spacing
      visible: root.dockOpen

      RowLayout {
        Layout.fillWidth: true
        spacing: 10
        Stats { }
        Item { Layout.fillWidth: true }
        Tray { }
        Clock { }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: 6
        WallpaperStrip { }
        Item { Layout.fillWidth: true }

        Repeater {
          model: root.actions
          delegate: Rectangle {
            required property var modelData
            width: Math.round(30 * Config.uiScale)
            height: width
            radius: width / 2
            color: actionHover.containsMouse ? Config.surfaceAlt : Config.surface
            border.color: Qt.rgba(1,1,1,0.08)

            ShellText {
              anchors.centerIn: parent
              text: modelData.glyph
              color: modelData.key === "power" ? Config.red : Config.text
              font.pixelSize: Config.fsSmall
            }
            MouseArea {
              id: actionHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.runAction(modelData.key)
            }
          }
        }
      }
    }
  }

  // keep dock pinned-collapsed collapsed when a popup opens elsewhere
  onDockOpenChanged: {}
}