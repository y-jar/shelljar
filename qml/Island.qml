import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell

// Top-center island per screen. Collapsed = a thin, long strip (~20% screen
// width). Right-click toggles open the dock: stats + tray + clock + wallpaper
// and action buttons (left-click opens the matching panel / runs the action).
Item {
  id: root

  // collapsed = thin ~20% strip; docked = auto-fit to its content (no cutoff)
  readonly property real stripWidth: Math.max(140, Math.round((parent ? parent.width : 1600) * Config.dockWidthRatio))
  width: dockOpen ? Math.max(Config.minDockWidth, (dockLayout ? dockLayout.implicitWidth + 16 : stripWidth)) : stripWidth
  height: dockOpen ? Config.dockHeight : Config.stripHeight

  // Only the power + control trigger pills remain; the full-screen power menu
  // (opened by the power pill) already contains lock/suspend/logout/etc.
  readonly property var actions: [
    { key: "power", glyph: "⚡" },
    { key: "control", glyph: "☰" },
  ]

  property bool dockOpen: false
  property bool pinned: false // unused; kept for future
  signal powerClicked
  signal controlClicked
  signal wallpaperOpenRequested(var dir)
  signal wallpaperGridRequested
  signal osdHoverRequested
  signal osdValueChanged
  signal batteryPanelRequested

  Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
  Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

  function runAction(key) {
    dockOpen = false
    if (key === "power") powerClicked()
    else if (key === "control") controlClicked()
  }

  Rectangle {
    id: card
    anchors.fill: parent
    radius: Config.cornerRadius
    color: Config.bg
    border.color: Qt.rgba(1,1,1,0.10)

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
      id: dockLayout
      anchors.fill: parent
      anchors.margins: 8
      spacing: Config.spacing
      visible: root.dockOpen

      RowLayout {
        Layout.fillWidth: true
        spacing: 10
        Stats { }
        Item { Layout.fillWidth: true }
        BatteryWidget {
          onBatteryClicked: root.batteryPanelRequested()
        }
        VolumeWidget {
          onHoverRequested: root.osdHoverRequested()
          onValueChanged: root.osdValueChanged()
        }
        MediaWidget { }
        Tray { }
        Clock { }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: 6
        WallpaperStrip {
          onOpenRequested: dir => root.wallpaperOpenRequested(dir)
          onGridRequested: root.wallpaperGridRequested()
        }
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