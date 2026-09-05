/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   VolumePanel
 *
 *   A small popout frame opened from the bar volume pill. It shows a large
 *   draggable slider, a mute toggle and the current percentage. A close button
 *   in the header lets the user dismiss it, so the closeRequested signal is
 *   actually wired to something useful.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Rectangle {
  id: root

  property bool open: false
  signal closeRequested

  width: Config.popupWidth
  height: Math.round(110 * Config.uiScale)
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Config.borderStrong

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
        border.color: Config.borderMid
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
      ShellText {
        text: "✕"
        color: Config.subtext
        font.pixelSize: Config.fsSmall
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.closeRequested()
        }
      }
    }

    // large slider
    Slider {
      Layout.fillWidth: true
      value: root.vol
      step: Config.volStep
      trackThickness: Math.round(20 * Config.uiScale)
      knobSize: Math.round(26 * Config.uiScale)
      fillColor: root.muted ? Config.subtext : Config.accent
      onChanged: v => root.setVolume(v)
    }
  }
}
