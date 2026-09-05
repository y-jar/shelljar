/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Osd
 *
 *   A small on screen bar in the top right that gives feedback for volume and
 *   brightness. It shows on a value change and while the user hovers the pills,
 *   then quietly fades after its timers in Config have run.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Item {
  id: root

  width: Config.osdWidth
  height: Config.osdHeight
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
    root.icon = val <= Config.brightnessEpsilon ? "☀" : (val <= 0.5 ? "🔅" : "🔆")
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
    interval: Config.osdShowMs
  }
  Timer {
    id: hoverTimer
    interval: Config.osdHoverMs
  }

  Rectangle {
    anchors.fill: parent
    radius: Config.cornerRadius
    color: Config.bgAlt
    border.color: Config.borderStrong

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