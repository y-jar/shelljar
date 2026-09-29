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
 *   Non-interactive by design: no MouseArea lives here, so it can never steal
 *   pointer events from the control, and it stops repainting once hidden.
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
  readonly property real pointerH: 5 * root.s
  readonly property real gap: 5 * root.s

  property bool armed: false

  width: bubble.width
  height: bubble.height + pointerH
  z: 100
  visible: armed || opacity > 0.01
  opacity: armed ? 1 : 0
  Behavior on opacity { NumberAnimation { duration: root.armed ? Motion.standard : Motion.fast; easing.type: Motion.easeStandard } }

  Timer {
    id: delay
    interval: 450
    onTriggered: root.armed = true
  }

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
    anchors.horizontalCenter: root.align === "center" ? parent.horizontalCenter : undefined
    anchors.left: root.align === "left" ? parent.left : undefined
    anchors.right: root.align === "right" ? parent.right : undefined
    anchors.top: root.below ? parent.top : undefined
    anchors.bottom: root.below ? undefined : parent.bottom
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

  Canvas {
    id: pointer
    width: Math.round(11 * root.s)
    height: root.pointerH
    anchors.horizontalCenter: root.align === "center" ? parent.horizontalCenter : undefined
    anchors.left: root.align === "left" ? parent.left : undefined
    anchors.right: root.align === "right" ? parent.right : undefined
    anchors.top: root.below ? parent.top : undefined
    anchors.bottom: root.below ? undefined : parent.bottom

    onPaint: {
      const ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = Config.surfaceHigh
      ctx.beginPath()
      if (root.below) {
        ctx.moveTo(0, 0)
        ctx.lineTo(width, 0)
        ctx.lineTo(width / 2, height)
      } else {
        ctx.moveTo(0, height)
        ctx.lineTo(width, height)
        ctx.lineTo(width / 2, 0)
      }
      ctx.closePath()
      ctx.fill()
    }

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
  }
}
