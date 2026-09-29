/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   GlyphIcon
 *
 *   A self-contained vector glyph drawn from baked SVG path data, so the shell
 *   never depends on an emoji font or the system icon theme. Set `name` to pick
 *   a shape, `color` to tint it and `stroke` to set the line weight. Paths live
 *   in a 24x24 space and scale to the item's size; each glyph is centred on its
 *   own bounding box so shapes with different extents share an optical baseline.
 *
 *   The path table lives once in the Glyphs singleton (not per instance) and
 *   the shape is layer-cached, since a glyph's geometry never changes.
 *
 *   Ported from Ukishima's components/GlyphIcon.qml (credit: amanhex).
 ***/
import ".."
import QtQuick
import QtQuick.Shapes

Item {
  id: root

  property string name: ""
  property color color: Config.text
  property real stroke: 1.8
  readonly property real u: Math.min(width, height) / 24
  readonly property var g: Glyphs.path(name)

  Shape {
    id: glyph

    width: 24
    height: 24
    scale: root.u
    transformOrigin: Item.TopLeft
    x: glyph.boundingRect.width > 0 ? root.width / 2 - (glyph.boundingRect.x + glyph.boundingRect.width / 2) * root.u : (root.width - 24 * root.u) / 2
    y: glyph.boundingRect.height > 0 ? root.height / 2 - (glyph.boundingRect.y + glyph.boundingRect.height / 2) * root.u : (root.height - 24 * root.u) / 2
    antialiasing: true
    preferredRendererType: Shape.CurveRenderer
    // the glyph's geometry is static, so cache it as a texture; only the tint
    // changes on hover, which invalidates and re-renders the small tile
    layer.enabled: true
    layer.smooth: true

    ShapePath {
      strokeColor: root.g.fill ? "transparent" : root.color
      fillColor: root.g.fill ? root.color : "transparent"
      strokeWidth: root.stroke
      capStyle: ShapePath.RoundCap
      joinStyle: ShapePath.RoundJoin

      PathSvg {
        path: root.g.d
      }
    }
  }
}
