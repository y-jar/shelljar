import QtQuick

// Drawn Wi-Fi glyph whose arcs light up with `level` (0-4).
// level 0 = fully dim (off), 4 = strongest. Dimmed arcs use `dimColor`.
Item {
  id: root

  property int level: 0
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
    }
  }

  onLevelChanged: canvas.requestPaint()
  onColorChanged: canvas.requestPaint()
  onDimColorChanged: canvas.requestPaint()
}