/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   WallpaperStrip
 *
 *   The walls button in the bar second row. The wheel slides the wallpaper
 *   carousel, a click opens the grid and a right click opens the full screen
 *   picker.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  property color hoverBg: Config.surface

  signal openRequested(var dir)
  signal gridRequested
  signal pickerRequested

  Rectangle {
    Layout.fillHeight: true
    Layout.preferredWidth: Math.round(110 * Config.uiScale)
    implicitHeight: 34
    radius: 10
    color: root.hoverBg
    border.color: Config.borderSoft

    ColumnLayout {
      anchors.centerIn: parent
      spacing: 0
      ShellText {
        text: "Walls"
        color: root.textColor
        font.pixelSize: Config.fsSmall
      }
      ShellText {
        text: "Scroll / Click"
        color: root.subColor
        font.pixelSize: Config.fsTiny
      }
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onWheel: event => root.openRequested(event.angleDelta.y > 0 ? "prev" : "next")
      onClicked: event => {
        if (event.button === Qt.RightButton) root.pickerRequested()
        else root.gridRequested()
      }
    }
  }
}