import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

// MPRIS media controls: shows the first active player's track.
RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  property int iconSize: 14
  spacing: 6

  // pick the first player that reports a track
  readonly property var players: Mpris.players ? Mpris.players.values : []
  readonly property var player: players.length > 0 ? players[0] : null
  readonly property bool nothingPlaying: player === null || player.trackTitle === ""

  // prev / play-pause / next
  Rectangle {
    width: 24; height: 24; radius: 6; color: "transparent"
    visible: !root.nothingPlaying && player.canGoPrevious
    opacity: 0.9
    MouseArea {
      anchors.fill: parent
      onClicked: root.player.previous()
      Text { anchors.centerIn: parent; text: "⏮"; font.pixelSize: root.iconSize; color: root.textColor }
    }
  }

  Rectangle {
    width: 26; height: 26; radius: 6
    color: Config.surface
    visible: !root.nothingPlaying && player.canTogglePlaying
    MouseArea {
      anchors.fill: parent
      onClicked: root.player.togglePlaying()
      Text {
        anchors.centerIn: parent
        text: root.player.isPlaying ? "⏸" : "▶"
        font.pixelSize: root.iconSize + 2
        color: root.textColor
      }
    }
  }

  Rectangle {
    width: 24; height: 24; radius: 6; color: "transparent"
    visible: !root.nothingPlaying && player.canGoNext
    MouseArea {
      anchors.fill: parent
      onClicked: root.player.next()
      Text { anchors.centerIn: parent; text: "⏭"; font.pixelSize: root.iconSize; color: root.textColor }
    }
  }

  ColumnLayout {
    spacing: 0
    visible: !root.nothingPlaying
    Text {
      text: root.player.trackTitle || ""
      color: root.textColor
      font.pixelSize: 11
      elide: Text.ElideRight
      Layout.preferredWidth: 160
    }
    Text {
      text: root.player.trackArtist || root.player.identity || ""
      color: root.subColor
      font.pixelSize: 9
      elide: Text.ElideRight
      Layout.preferredWidth: 160
    }
  }
}