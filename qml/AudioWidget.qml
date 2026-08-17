import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

// Volume / mute control for the default audio sink via pipewire.
RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  property bool showLabel: true
  readonly property var sink: Pipewire.defaultAudioSink
  readonly property real vol: sink != null && sink.audio != null ? sink.audio.volume : 0
  readonly property bool muted: sink != null && sink.audio != null && sink.audio.muted

  // mute / unmute toggle
  function toggleMute() {
    if (sink != null && sink.audio != null) sink.audio.setMuted(!sink.audio.muted)
  }

  function setVolume(v) {
    if (sink != null && sink.audio != null) sink.audio.setVolume(Math.max(0, Math.min(1, v)))
  }

  // mute toggle button
  Rectangle {
    width: 22; height: 22; radius: 5
    color: "transparent"
    MouseArea {
      anchors.fill: parent
      onClicked: root.toggleMute()
      Text {
        anchors.centerIn: parent
        text: root.muted ? "🔇" : (root.vol === 0 ? "🔈" : (root.vol < 0.5 ? "🔉" : "🔊"))
        font.pixelSize: 12
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

  Text {
    text: Math.round(root.vol * 100) + "%"
    color: root.textColor
    font.pixelSize: 10
  }
}