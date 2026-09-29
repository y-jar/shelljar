/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   MediaWidget
 *
 *   Compact music controls for the left island: album art, transport buttons,
 *   the track title and artist, and a thin progress line. It picks the player
 *   that is actually playing rather than just the first one, so the controls
 *   always follow the song you hear.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  property int iconSize: Math.round(13 * Config.uiScale)
  spacing: Math.round(7 * Config.uiScale)

  readonly property var players: Mpris.players ? Mpris.players.values : []

  function pickPlayer() {
    for (const p of root.players) { if (p && p.isPlaying) return p }
    for (const p of root.players) { if (p && p.trackTitle !== "") return p }
    return root.players.length > 0 ? root.players[0] : null
  }
  readonly property var player: root.pickPlayer()
  readonly property bool nothingPlaying: player === null || player.trackTitle === ""
  readonly property string art: (player && player.trackArtUrl) ? player.trackArtUrl : ""
  readonly property real progress: (player && player.length > 0)
    ? Math.max(0, Math.min(1, player.position / player.length)) : 0

  // ---- album art ----
  Rectangle {
    Layout.alignment: Qt.AlignVCenter
    visible: !root.nothingPlaying
    width: Math.round(30 * Config.uiScale)
    height: width
    radius: Math.round(7 * Config.uiScale)
    color: Config.surfaceHigh
    border.width: 1
    border.color: Config.outlineSoft
    clip: true

    GlyphIcon {
      anchors.centerIn: parent
      width: Math.round(16 * Config.uiScale)
      height: width
      name: "music"
      color: Config.subtext
      stroke: 1.7
      visible: artImage.status !== Image.Ready || root.art === ""
    }
    Image {
      id: artImage
      anchors.fill: parent
      source: root.art
      sourceSize.width: Math.round(60 * Config.uiScale)
      sourceSize.height: Math.round(60 * Config.uiScale)
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
      visible: status === Image.Ready && root.art !== ""
    }
  }

  // ---- prev / play-pause / next ----
  Rectangle {
    Layout.alignment: Qt.AlignVCenter
    width: Math.round(24 * Config.uiScale); height: width; radius: 6; color: "transparent"
    visible: !root.nothingPlaying && player.canGoPrevious
    opacity: 0.9
    MouseArea {
      anchors.fill: parent
      onClicked: root.player.previous()
      GlyphIcon { anchors.centerIn: parent; width: root.iconSize; height: width; name: "prev"; color: root.textColor }
    }
  }

  Rectangle {
    Layout.alignment: Qt.AlignVCenter
    width: Math.round(26 * Config.uiScale); height: width; radius: 6
    color: Config.surface
    visible: !root.nothingPlaying && player.canTogglePlaying
    MouseArea {
      anchors.fill: parent
      onClicked: root.player.togglePlaying()
      GlyphIcon {
        anchors.centerIn: parent
        width: root.iconSize + 2
        height: width
        name: root.player && root.player.isPlaying ? "pause" : "play"
        color: root.textColor
      }
    }
  }

  Rectangle {
    Layout.alignment: Qt.AlignVCenter
    width: Math.round(24 * Config.uiScale); height: width; radius: 6; color: "transparent"
    visible: !root.nothingPlaying && player.canGoNext
    MouseArea {
      anchors.fill: parent
      onClicked: root.player.next()
      GlyphIcon { anchors.centerIn: parent; width: root.iconSize; height: width; name: "next"; color: root.textColor }
    }
  }

  // ---- title / artist / progress ----
  ColumnLayout {
    Layout.alignment: Qt.AlignVCenter
    spacing: Math.round(2 * Config.uiScale)
    visible: !root.nothingPlaying

    ShellText {
      text: root.player ? root.player.trackTitle || "" : ""
      color: root.textColor
      font.pixelSize: Config.fsSmall
      elide: Text.ElideRight
      Layout.preferredWidth: Math.round(160 * Config.uiScale)
    }
    ShellText {
      text: root.player ? (root.player.trackArtist || root.player.identity || "") : ""
      color: root.subColor
      font.pixelSize: Config.fsTiny
      elide: Text.ElideRight
      Layout.preferredWidth: Math.round(160 * Config.uiScale)
    }
    Rectangle {
      Layout.preferredWidth: Math.round(160 * Config.uiScale)
      Layout.preferredHeight: Math.round(3 * Config.uiScale)
      radius: height / 2
      color: Config.surfaceAlt
      visible: root.player && root.player.length > 0
      Rectangle {
        width: parent.width * root.progress
        height: parent.height
        radius: parent.radius
        color: Config.accent
      }
    }
  }
}
