import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell

// Left auto-hiding island: [network | power | system tray | media manager].
// Collapsed = a slim horizontal handle on the left edge; right-click expands into
// a single-row card. Mirrors the main Bar's collapse/expand mechanics.
Item {
  id: root

  readonly property real stripW: Math.max(48, Math.round(60 * Config.uiScale))
  width: open ? Math.max(Config.minDockWidth, (content ? content.implicitWidth + 16 : stripW))
              : (Config.stripHeight)
  height: open ? Config.dockHeight : Config.stripHeight

  property bool open: false
  signal networkClicked
  signal powerClicked

  Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
  Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

  Rectangle {
    id: card
    anchors.fill: parent
    radius: Config.cornerRadius
    color: Config.bg
    border.color: Qt.rgba(1, 1, 1, 0.10)

    // right-click toggles the expanded island
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.RightButton
      onClicked: root.open = !root.open
    }

    // strip hint (visible when collapsed)
    Rectangle {
      anchors.centerIn: parent
      visible: !root.open
      width: 4
      height: Math.round(parent.width * 0.4)
      radius: 2
      color: Config.surfaceAlt
    }

    RowLayout {
      id: content
      anchors.fill: parent
      anchors.margins: 8
      spacing: 6
      visible: root.open

      NetworkWidget {
        onNetworkClicked: root.networkClicked()
      }

      // power button (opens the full-screen session menu)
      Rectangle {
        Layout.preferredWidth: Math.round(30 * Config.uiScale)
        Layout.preferredHeight: width
        radius: width / 2
        color: hoverArea.containsMouse ? Config.surfaceAlt : Config.surface
        border.color: Qt.rgba(1, 1, 1, 0.08)
        ShellText {
          anchors.centerIn: parent
          text: "⚡"
          color: Config.red
          font.pixelSize: Config.fsSmall
        }
        MouseArea {
          id: hoverArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.powerClicked()
        }
      }

      Tray { }
      MediaWidget { }
    }
  }
}