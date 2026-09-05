/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   VolumeWidget
 *
 *   A compact dock pill for audio. It shows an icon and the current percentage,
 *   hovering it pulses the OSD, the wheel steps the volume and a click asks the
 *   bar to open the volume panel. It talks to the default pipewire sink.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

RowLayout {
  id: root

  property color textColor: Config.text
  signal hoverRequested
  signal valueChanged
  signal toggleRequested

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property bool sinkReady: sink !== null && sink.ready && sink.audio !== null
  readonly property real vol: sinkReady ? sink.audio.volume : 0
  readonly property bool muted: sinkReady && sink.audio.muted

  onVolChanged: valueChanged()
  onMutedChanged: valueChanged()

  PwObjectTracker { objects: [root.sink] }

  function setVolume(v) {
    if (sinkReady) sink.audio.volume = Math.max(0, Math.min(1, v))
  }

  Rectangle {
    Layout.preferredWidth: Config.pillWidth
    Layout.preferredHeight: Config.pillHeight
    radius: Config.pillHeight / 2
    color: hoverArea.containsMouse ? Config.surfaceAlt : Config.surface
    border.color: Config.borderStrong

    RowLayout {
      anchors.centerIn: parent
      spacing: 5
      ShellText {
        text: root.muted ? "🔇" : (root.vol === 0 ? "🔈" : (root.vol < 0.5 ? "🔉" : "🔊"))
        color: root.textColor
        font.pixelSize: Config.fsSmall
      }
      ShellText {
        text: Math.round(root.vol * 100) + "%"
        color: root.textColor
        font.pixelSize: Config.fsTiny
      }
    }

    MouseArea {
      id: hoverArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.hoverRequested()
      onClicked: root.toggleRequested()
      onWheel: event => root.setVolume(root.vol + (event.angleDelta.y > 0 ? Config.volStep : -Config.volStep))
    }
  }
}