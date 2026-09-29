/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Tooltip
 *
 *   A small hint bubble anchored to its parent control. `placement` floats it
 *   above or below and `align` lines it up left/centre/right so a bubble near
 *   a card edge never runs off screen. The host drives `show` from its own
 *   hover; the bubble arms after a short delay and fades out fast.
 *
 *   Deliberately light: no Canvas pointer and no MouseArea, so it can never
 *   steal pointer events and costs almost nothing. Controls instantiate it
 *   lazily (via a Loader) only while hovered, so there are no idle bubbles.
 ***/
import ".."
import QtQuick

Item {
  id: root

  property real s: Config.uiScale
  property string title: ""
  property string desc: ""
  property bool show: false
  property string placement: "below" // "below" | "above"
  property string align: "center" // "left" | "center" | "right"

  readonly property bool below: root.placement === "below"
  readonly property real gap: Math.round(5 * root.s)

  property bool armed: false

  width: bubble.width
  height: bubble.height
  z: 100
  visible: armed || opacity > 0.01
  opacity: armed ? 1 : 0
  Behavior on opacity { NumberAnimation { duration: root.armed ? Motion.standard : Motion.fast; easing.type: Motion.easeStandard } }

  Timer {
    id: delay
    interval: 450
    onTriggered: root.armed = true
  }

  // when created already shown (lazy Loader), arm the delay on completion
  Component.onCompleted: if (root.show) delay.restart()

  onShowChanged: {
    if (root.show) {
      delay.restart()
    } else {
      delay.stop()
      root.armed = false
    }
  }

  anchors.horizontalCenter: root.align === "center" ? parent.horizontalCenter : undefined
  anchors.left: root.align === "left" ? parent.left : undefined
  anchors.right: root.align === "right" ? parent.right : undefined
  anchors.top: root.below ? parent.bottom : undefined
  anchors.bottom: root.below ? undefined : parent.top
  anchors.topMargin: root.below ? root.gap : 0
  anchors.bottomMargin: root.below ? 0 : root.gap

  Rectangle {
    id: bubble
    width: Math.max(titleText.implicitWidth, descText.implicitWidth) + Math.round(18 * root.s)
    height: column.implicitHeight + Math.round(12 * root.s)
    radius: Config.radiusSm
    color: Config.surfaceHigh
    border.width: 1
    border.color: Config.outline
    anchors.horizontalCenter: parent.horizontalCenter
  }

  Column {
    id: column
    anchors.centerIn: bubble
    spacing: Math.round(1 * root.s)

    ShellText {
      id: titleText
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.title
      color: Config.text
      font.pixelSize: Config.fsSmall
      font.weight: Font.DemiBold
    }
    ShellText {
      id: descText
      anchors.horizontalCenter: parent.horizontalCenter
      visible: root.desc.length > 0
      text: root.desc
      color: Config.subtext
      font.pixelSize: Config.fsTiny
    }
  }
}
