/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   AudioWidget
 *
 *   The volume and mute control shown in the control center. It binds to the
 *   default pipewire sink and offers a mute button plus a live slider. The
 *   slider leans on the shared Slider component so it feels identical to the
 *   dedicated volume panel.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

RowLayout {
  id: root

  property color textColor: Config.text

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
  Slider {
    Layout.preferredWidth: Math.round(150 * Config.uiScale)
    value: root.vol
    step: Config.volStepFine
    fillColor: root.muted ? Config.subtext : Config.accent
    onChanged: v => root.setVolume(v)
  }

  ShellText {
    text: Math.round(root.vol * 100) + "%"
    color: root.textColor
    font.pixelSize: Config.fsSmall
    Layout.minimumWidth: Math.round(34 * Config.uiScale)
  }
}