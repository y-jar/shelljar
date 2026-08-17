import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

// MPRIS media controls: shows the first active player's track.
RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  property int iconSize: Math.round(14 * Config.uiScale)
  spacing: 6

  // pick the first player that reports a track
  readonly property var players: Mpris.players ? Mpris.players.values : []
  readonly property var player: players.length > 0 ? players[0] : null
  readonly property bool nothingPlaying: player === null || player.trackTitle === ""

  // prev / play-pause / next
  Rectangle {
    width: Math.round(24 * Config.uiScale); height: Math.round(24 * Config.uiScale); radius: 6; color: "transparent"
    visible: !root.nothingPlaying && player.canGoPrevious
    opacity: 0.9
    MouseArea {
      anchors.fill: parent
      onClicked: root.player.previous()
      ShellText { anchors.centerIn: parent; text: "⏮"; font.pixelSize: root.iconSize; color: root.textColor }
    }
  }

  Rectangle {
    width: Math.round(26 * Config.uiScale); height: Math.round(26 * Config.uiScale); radius: 6
    color: Config.surface
    visible: !root.nothingPlaying && player.canTogglePlaying
    MouseArea {
      anchors.fill: parent
      onClicked: root.player.togglePlaying()
      ShellText {
        anchors.centerIn: parent
        text: root.player.isPlaying ? "⏸" : "▶"
        font.pixelSize: root.iconSize + 2
        color: root.textColor
      }
    }
  }

  Rectangle {
    width: Math.round(24 * Config.uiScale); height: Math.round(24 * Config.uiScale); radius: 6; color: "transparent"
    visible: !root.nothingPlaying && player.canGoNext
    MouseArea {
      anchors.fill: parent
      onClicked: root.player.next()
      ShellText { anchors.centerIn: parent; text: "⏭"; font.pixelSize: root.iconSize; color: root.textColor }
    }
  }

  ColumnLayout {
    spacing: 0
    visible: !root.nothingPlaying
    ShellText {
      text: root.player.trackTitle || ""
      color: root.textColor
      font.pixelSize: Config.fsSmall
      elide: Text.ElideRight
      Layout.preferredWidth: Math.round(160 * Config.uiScale)
    }
    ShellText {
      text: root.player.trackArtist || root.player.identity || ""
      color: root.subColor
      font.pixelSize: Config.fsTiny
      elide: Text.ElideRight
      Layout.preferredWidth: Math.round(160 * Config.uiScale)
    }
  }
}