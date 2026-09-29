/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Ripple
 *
 *   A press ripple for buttons and tiles, driven from outside with
 *   `fire(x, y)`. One clipped circle expands from the press point and fades;
 *   a single animation is reused every press, so it costs nothing while idle
 *   and never accumulates objects. Non-interactive: it holds no MouseArea, so
 *   it can never steal pointer events from the control it sits in.
 ***/
import ".."
import QtQuick

Item {
  id: root

  property color color: "#ffffff"
  property real maxOpacity: 0.12
  property point origin: Qt.point(width / 2, height / 2)

  anchors.fill: parent
  clip: true

  Rectangle {
    id: wave
    width: Math.max(root.width, root.height) * 2
    height: width
    radius: width / 2
    color: root.color
    opacity: 0
    scale: 0
  }

  function fire(px, py) {
    wave.x = px - wave.width / 2
    wave.y = py - wave.height / 2
    rippleAnim.restart()
  }

  SequentialAnimation {
    id: rippleAnim
    PropertyAction { target: wave; property: "scale"; value: 0 }
    PropertyAction { target: wave; property: "opacity"; value: root.maxOpacity }
    ParallelAnimation {
      NumberAnimation { target: wave; property: "scale"; to: 1; duration: Motion.standard; easing.type: Motion.easeDecel }
      NumberAnimation { target: wave; property: "opacity"; to: 0; duration: Motion.standard; easing.type: Motion.easeStandard }
    }
  }
}
