/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   EthernetIcon
 *
 *   A small cable jack glyph drawn on a canvas that can be tinted any color.
 *   It is used inside the network pill to show a wired connection instead of
 *   the wireless arcs. The color property drives the whole shape.
 ***/
import ".."
import qs.components
import QtQuick

Item {
  id: root

  property color color: Config.text

  implicitWidth: Math.round(18 * Config.uiScale)
  implicitHeight: Math.round(18 * Config.uiScale)

  Canvas {
    id: canvas
    anchors.fill: parent
    antialiasing: true

    onPaint: {
      const ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)

      const w = width
      const h = height
      const lw = Math.max(1.5, width * 0.08)

      // RJ45-ish jack: a rounded connector with a notched face
      const bx = w * 0.16
      const by = h * 0.22
      const bw = w * 0.68
      const bh = h * 0.56
      ctx.fillStyle = root.color
      ctx.fillRect(bx, by, bw, bh)
      ctx.clearRect(bx + bw * 0.16, by + bh * 0.3, bw * 0.68, bh * 0.4)

      // cable tail
      ctx.beginPath()
      ctx.moveTo(w * 0.5, h * 0.78)
      ctx.lineTo(w * 0.5, h * 0.9)
      ctx.lineWidth = lw * 1.4
      ctx.lineCap = "round"
      ctx.strokeStyle = root.color
      ctx.stroke()
    }
  }

  onColorChanged: canvas.requestPaint()
}