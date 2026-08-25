import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

// Pop-out volume panel: a compact frame with a large draggable slider, mute
// toggle and live %. Opens from the bar's volume pill.
Rectangle {
  id: root

  property bool open: false
  signal closeRequested

  width: Math.round(300 * Config.uiScale)
  implicitHeight: 110
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Qt.rgba(1,1,1,0.10)

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property bool sinkReady: sink !== null && sink.ready && sink.audio !== null
  readonly property real vol: sinkReady ? sink.audio.volume : 0
  readonly property bool muted: sinkReady && sink.audio.muted

  PwObjectTracker { objects: [root.sink] }

  function setVolume(v) {
    if (sinkReady) sink.audio.volume = Math.max(0, Math.min(1, v))
  }
  function toggleMute() {
    if (sinkReady) sink.audio.muted = !sink.audio.muted
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 14
    spacing: 12

    RowLayout {
      Layout.fillWidth: true
      ShellText {
        text: "Volume"
        color: Config.text
        font.pixelSize: Config.fsMedium
        font.weight: Font.DemiBold
      }
      Item { Layout.fillWidth: true }
      // mute toggle
      Rectangle {
        width: Math.round(26 * Config.uiScale); height: Math.round(26 * Config.uiScale); radius: 8
        color: muteHover.containsMouse ? Config.surfaceAlt : Config.surface
        border.color: Qt.rgba(1,1,1,0.08)
        ShellText {
          anchors.centerIn: parent
          text: root.muted ? "🔇" : (root.vol === 0 ? "🔈" : (root.vol < 0.5 ? "🔉" : "🔊"))
          font.pixelSize: Config.fsSmall
        }
        MouseArea {
          id: muteHover
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.toggleMute()
        }
      }
      ShellText {
        text: Math.round(root.vol * 100) + "%"
        color: Config.text
        font.pixelSize: Config.fsSmall
        Layout.minimumWidth: Math.round(40 * Config.uiScale)
        horizontalAlignment: Text.AlignRight
      }
    }

    // large slider
    Rectangle {
      id: track
      Layout.fillWidth: true
      Layout.preferredHeight: Math.round(20 * Config.uiScale)
      radius: height / 2
      color: Config.surfaceAlt

      Rectangle {
        id: fill
        width: track.width * root.vol
        height: track.height
        radius: height / 2
        color: root.muted ? Config.subtext : Config.accent
      }

      Rectangle {
        id: knob
        width: Math.round(26 * Config.uiScale)
        height: width
        radius: width / 2
        x: Math.max(0, Math.min(track.width - width, fill.width - width / 2))
        y: (track.height - height) / 2
        color: "#ffffff"
        border.color: Qt.rgba(0,0,0,0.3)
        border.width: 1
      }

      MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: if (pressed) root.setVolume(mouse.x / width)
        onClicked: root.setVolume(mouse.x / width)
        onWheel: event => root.setVolume(root.vol + (event.angleDelta.y > 0 ? 0.05 : -0.05))
      }
    }
  }
}
