/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   LeftIsland
 *
 *   The auto hiding island on the left edge of the screen. Collapsed it is a
 *   slim bar and a right click expands it into one row holding the network
 *   icon, the power button, the system tray and the music controls.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  readonly property real stripW: Math.max(120, Math.round(150 * Config.uiScale))
  width: open ? Math.max(Config.minDockWidth, (content ? content.implicitWidth + 16 : stripW))
              : stripW
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
    border.color: Config.borderStrong
    clip: true

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
      width: Math.round(parent.width * 0.5)
      height: 4
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
        Layout.preferredWidth: Config.iconButtonSize
        Layout.preferredHeight: width
        radius: width / 2
        color: hoverArea.containsMouse ? Config.surfaceAlt : Config.surface
        border.color: Config.borderMid
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