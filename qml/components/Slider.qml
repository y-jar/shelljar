/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Slider
 *
 *   A shared draggable slider used by the audio, volume and brightness panels.
 *   It draws a rounded track with a filled portion and a round knob, and it
 *   handles drag, click and wheel input. Callers bind value and react to the
 *   changed signal, or call commit to push a new value in.
 ***/
import ".."
import QtQuick

Rectangle {
  id: root

  property real value: 0
  property real from: 0
  property real to: 1
  property real step: 0.05
  property color fillColor: Config.accent
  property color trackColor: Config.surfaceAlt
  property real trackThickness: Math.round(12 * Config.uiScale)
  property real knobSize: Math.round(18 * Config.uiScale)
  property bool enabled: true

  signal changed(real value)

  height: root.trackThickness
  radius: height / 2
  color: root.trackColor

  function clamp(v) {
    return Math.max(root.from, Math.min(root.to, v))
  }

  function commit(v) {
    root.value = root.clamp(v)
    root.changed(root.value)
  }

  function nudge(delta) {
    root.commit(root.value + delta * root.step)
  }

  // filled portion
  Rectangle {
    id: fill
    width: root.width * (root.value - root.from) / (root.to - root.from)
    height: root.height
    radius: height / 2
    color: root.fillColor
  }

  // draggable knob
  Rectangle {
    id: knob
    width: root.knobSize
    height: root.knobSize
    radius: width / 2
    x: Math.max(0, Math.min(root.width - width, fill.width - width / 2))
    y: (root.height - height) / 2
    color: Config.knobColor
    border.color: Qt.rgba(0, 0, 0, 0.3)
    border.width: 1
  }

  // mouse mapping: drag, click and wheel all set the value
  MouseArea {
    id: mouse
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onPositionChanged: if (pressed) root.commit(mouse.x / width)
    onClicked: root.commit(mouse.x / width)
    onWheel: event => root.nudge(event.angleDelta.y > 0 ? 1 : -1)
  }
}