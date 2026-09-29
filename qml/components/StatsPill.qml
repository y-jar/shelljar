/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   StatsPill
 *
 *   One compact system-stat readout for the bar: a small glyph and a short
 *   value, no label text. Hovering reveals the full value through a tooltip,
 *   so the bar stays clean while the detail is still one hover away.
 ***/
import ".."
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property string glyph: ""
  property string value: ""
  property string tooltip: ""
  property color glyphColor: Config.subtext
  property color valueColor: Config.text

  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight

  RowLayout {
    id: row
    anchors.fill: parent
    spacing: Math.round(4 * Config.uiScale)

    GlyphIcon {
      Layout.alignment: Qt.AlignVCenter
      width: Config.iconSm
      height: width
      name: root.glyph
      color: root.glyphColor
      stroke: 1.7
    }

    ShellText {
      Layout.alignment: Qt.AlignVCenter
      text: root.value
      color: root.valueColor
      font.pixelSize: Config.fsTiny
    }
  }

  HoverHandler { id: hover }

  Tooltip {
    s: Config.uiScale
    title: root.tooltip
    show: hover.hovered && root.tooltip !== ""
    placement: "below"
  }
}
