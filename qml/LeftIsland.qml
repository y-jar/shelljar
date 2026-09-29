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
  height: open ? Config.islandHeight : Config.stripHeight

  property bool open: false
  signal networkClicked
  signal powerClicked

  Behavior on width { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }
  Behavior on height { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

  Surface {
    id: card
    anchors.fill: parent
    radius: Config.cornerRadius
    clip: false

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

      NetworkWidget {
        onNetworkClicked: root.networkClicked()
      }

      // power button (opens the full-screen session menu)
      IconButton {
        glyph: "power"
        glyphColor: Config.red
        tooltip: "Power"
        onClicked: root.powerClicked()
      }

      Tray { }
      MediaWidget { }
    }
  }
}