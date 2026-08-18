import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

// Dock volume pill: icon + %, hover shows the OSD, wheel changes volume.
RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  signal hoverRequested
  signal valueChanged

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
    Layout.preferredWidth: Math.round(64 * Config.uiScale)
    implicitHeight: 26
    radius: 13
    color: hoverArea.containsMouse ? Config.surfaceAlt : Config.surface
    border.color: Qt.rgba(1,1,1,0.10)

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
      onEntered: root.hoverRequested()
      onWheel: event => root.setVolume(root.vol + (event.angleDelta.y > 0 ? 0.05 : -0.05))
    }
  }
}