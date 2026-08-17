import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

// Volume / mute control for the default audio sink via pipewire.
RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  readonly property var sink: Pipewire.defaultAudioSink
  readonly property bool sinkReady: sink !== null && sink.ready && sink.audio !== null
  readonly property real vol: sinkReady ? sink.audio.volume : 0
  readonly property bool muted: sinkReady && sink.audio.muted

  // Keep the default sink bound so volume/mute props are valid.
  PwObjectTracker {
    objects: [root.sink]
  }

  // mute / unmute toggle
  function toggleMute() {
    if (sinkReady) sink.audio.muted = !sink.audio.muted
  }

  function setVolume(v) {
    if (sinkReady) sink.audio.volume = Math.max(0, Math.min(1, v))
  }

  // mute toggle button
  Rectangle {
    width: Math.round(22 * Config.uiScale); height: Math.round(22 * Config.uiScale); radius: 5
    color: "transparent"
    MouseArea {
      anchors.fill: parent
      onClicked: root.toggleMute()
      ShellText {
        anchors.centerIn: parent
        text: root.muted ? "🔇" : (root.vol === 0 ? "🔈" : (root.vol < 0.5 ? "🔉" : "🔊"))
        font.pixelSize: Config.fsMedium
      }
    }
  }

  // slider
  Rectangle {
    Layout.preferredWidth: 90
    height: 4
    radius: 2
    color: Config.surfaceAlt
    clip: false

    Rectangle {
      width: parent.width * root.vol
      height: parent.height
      radius: 2
      color: root.muted ? Config.subtext : Config.accent
    }

    MouseArea {
      anchors.fill: parent
      onPositionChanged: if (pressed) root.setVolume(mouse.x / width)
      onClicked: root.setVolume(mouse.x / width)
    }
  }

  ShellText {
    text: Math.round(root.vol * 100) + "%"
    color: root.textColor
    font.pixelSize: Config.fsSmall
  }
}