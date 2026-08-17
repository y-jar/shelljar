import qs.components
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
    width: Math.round(24 * Config.uiScale); height: Math.round(24 * Config.uiScale); radius: 6
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

  // larger slider with a draggable knob
  Rectangle {
    id: track
    Layout.preferredWidth: Math.round(150 * Config.uiScale)
    Layout.preferredHeight: Math.round(12 * Config.uiScale)
    radius: height / 2
    color: Config.surfaceAlt

    // filled portion
    Rectangle {
      id: fill
      width: track.width * root.vol
      height: track.height
      radius: height / 2
      color: root.muted ? Config.subtext : Config.accent
    }

    // draggable knob
    Rectangle {
      id: knob
      width: Math.round(18 * Config.uiScale)
      height: width
      radius: width / 2
      x: Math.max(0, Math.min(track.width - width, fill.width - width / 2))
      y: (track.height - height) / 2
      color: "#ffffff"
      border.color: Qt.rgba(0,0,0,0.3)
      border.width: 1
    }

    // drag anywhere on the track to seek / fine-tune
    MouseArea {
      id: dragArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onPositionChanged: if (pressed) root.setVolume(mouse.x / width)
      onClicked: root.setVolume(mouse.x / width)
      onWheel: event => root.setVolume(root.vol + (event.angleDelta.y > 0 ? 0.02 : -0.02))
    }
  }

  ShellText {
    text: Math.round(root.vol * 100) + "%"
    color: root.textColor
    font.pixelSize: Config.fsSmall
    Layout.minimumWidth: Math.round(34 * Config.uiScale)
  }
}