/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   WifiIcon
 *
 *   A wireless glyph drawn on a canvas whose arcs light up based on a level
 *   from zero to four. It can also draw a slash across itself when the radio is
 *   on but not connected. Dimmed arcs use the dim color so an idle radio reads
 *   as quiet while an active one stays bright.
 ***/
import ".."
import qs.components
import QtQuick

Item {
  id: root

  property int level: 0
  property bool slash: false
  property color color: Config.text
  property color dimColor: Qt.rgba(1, 1, 1, 0.28)

  implicitWidth: Math.round(18 * Config.uiScale)
  implicitHeight: Math.round(18 * Config.uiScale)

  Canvas {
    id: canvas
    anchors.fill: parent
    antialiasing: true

    onPaint: {
      const ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)

      const cx = width / 2
      const cy = height * 0.98
      const lw = Math.max(1.6, width * 0.09)
      const radii = [ height * 0.22, height * 0.40, height * 0.58 ]
      const start = Math.PI * 1.15
      const end = Math.PI * 1.85
      const n = root.level

      ctx.lineCap = "round"

      ctx.beginPath()
      ctx.fillStyle = n >= 1 ? root.color : root.dimColor
      ctx.arc(cx, cy, lw * 0.9, 0, Math.PI * 2)
      ctx.fill()

      for (let i = 0; i < radii.length; i++) {
        ctx.beginPath()
        ctx.arc(cx, cy, radii[i], start, end, false)
        ctx.lineWidth = lw
        ctx.strokeStyle = n >= i + 2 ? root.color : root.dimColor
        ctx.stroke()
      }

      // not-connected slash
      if (root.slash) {
        ctx.beginPath()
        ctx.moveTo(width * 0.18, height * 0.12)
        ctx.lineTo(width * 0.82, height * 0.88)
        ctx.lineWidth = lw
        ctx.strokeStyle = n >= 1 ? root.color : root.dimColor
        ctx.stroke()
      }
    }
  }

  onLevelChanged: canvas.requestPaint()
  onSlashChanged: canvas.requestPaint()
  onColorChanged: canvas.requestPaint()
  onDimColorChanged: canvas.requestPaint()
}