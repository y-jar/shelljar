/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   EdgeFillet
 *
 *   A small concave corner that lets a surface merge into the screen's top
 *   edge. Place one of these just outside each of the bar's top corners (same
 *   fill as the bar) and square the card's top corners: the fillet fills the
 *   little tongue between the bar's side and the edge, so the bar reads as
 *   growing out of the top of the screen instead of floating as a pill.
 *
 *   `side` is which side of the surface the fillet sits on: "left" means the
 *   surface is to the fillet's right, "right" means the surface is to its
 *   left. It draws with a Canvas and only repaints when a property changes, so
 *   it costs nothing while idle.
 ***/
import ".."
import QtQuick

Item {
  id: root

  property real size: Config.edgeFilletRadius
  property color color: Config.surfaceMid
  property string side: "left" // "left" | "right"

  width: size
  height: size

  Canvas {
    id: canvas
    anchors.fill: parent
    antialiasing: true

    onPaint: {
      const ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = root.color
      const w = width
      const h = height
      ctx.beginPath()
      if (root.side === "left") {
        // surface sits to the right; tongue fills up to the left edge
        ctx.moveTo(w, 0)
        ctx.lineTo(0, 0)
        ctx.arc(0, h, w, -Math.PI / 2, 0)
      } else {
        // surface sits to the left; tongue fills up to the right edge
        ctx.moveTo(0, 0)
        ctx.lineTo(w, 0)
        ctx.arc(w, h, w, -Math.PI / 2, -Math.PI, true)
      }
      ctx.closePath()
      ctx.fill()
    }
  }

  onSizeChanged: canvas.requestPaint()
  onColorChanged: canvas.requestPaint()
  onSideChanged: canvas.requestPaint()
}
