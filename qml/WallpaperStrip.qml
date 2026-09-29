/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   WallpaperStrip
 *
 *   The compact wallpaper button in the bar. The wheel slides the wallpaper
 *   carousel, a click opens the thumbnail grid and a right click opens the full
 *   screen picker.
 ***/
import qs.components
import QtQuick

Item {
  id: root

  property color textColor: Config.text

  signal openRequested(var dir)
  signal gridRequested
  signal pickerRequested

  implicitWidth: Config.iconButtonSize
  implicitHeight: Config.iconButtonSize

  IconButton {
    anchors.fill: parent
    buttonSize: root.width
    glyph: "wallpaper"
    glyphColor: root.textColor
    tooltip: "Wallpaper"
    onScrolled: d => root.openRequested(d > 0 ? "prev" : "next")
    onClicked: root.gridRequested()
    onRightClicked: root.pickerRequested()
  }
}
