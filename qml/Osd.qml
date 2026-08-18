import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

// Top-right OSD popup: shows volume / brightness feedback.
// Shown on value change and on hover of the volume/brightness pills.
Item {
  id: root

  width: 260
  height: 64
  visible: showTimer.running || hoverTimer.running
  anchors.right: parent.right
  anchors.rightMargin: 16
  anchors.top: parent.top
  anchors.topMargin: 12
  z: 50

  property string icon: ""
  property real percent: 0
  property bool low: false

  function showVolume() {
    const sink = Pipewire.defaultAudioSink
    if (!sink || !sink.ready || !sink.audio) return
    const muted = sink.audio.muted
    const v = sink.audio.volume
    root.icon = muted || v === 0 ? "🔇" : (v < 0.5 ? "🔉" : "🔊")
    root.percent = Math.round(v * 100)
    root.low = muted
    restart()
  }

  function showBrightness(val) {
    root.icon = val <= 0.001 ? "☀" : (val <= 0.5 ? "🔅" : "🔆")
    root.percent = Math.round(val * 100)
    root.low = false
    restart()
  }

  function restart() {
    showTimer.stop()
    showTimer.start()
    hoverTimer.stop()
  }

  function hover() {
    hoverTimer.restart()
  }

  Timer {
    id: showTimer
    interval: 2000
  }
  Timer {
    id: hoverTimer
    interval: 1200
  }

  Rectangle {
    anchors.fill: parent
    radius: Config.cornerRadius
    color: Config.bgAlt
    border.color: Qt.rgba(1,1,1,0.10)

    RowLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 10

      ShellText {
        text: root.icon
        color: root.low ? Config.red : Config.text
        font.pixelSize: Config.fsLarge
        Layout.preferredWidth: 24
        Layout.alignment: Qt.AlignVCenter
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 6
        radius: 3
        color: Config.surfaceAlt
        Layout.alignment: Qt.AlignVCenter

        Rectangle {
          width: parent.width * (root.percent / 100)
          height: parent.height
          radius: 3
          color: root.low ? Config.red : Config.accent
        }
      }

      ShellText {
        text: root.percent + "%"
        color: Config.text
        font.pixelSize: Config.fsSmall
        Layout.alignment: Qt.AlignVCenter
      }
    }
  }
}