import qs.components
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

// ---- pop-out wallpaper picker grid (noctalia-style) ----
// A grid of wallpaper thumbnails; click one to apply it via awww and close.
Rectangle {
  id: root

  property bool open: false
  signal closeRequested

  width: Math.min(Math.round(800 * Config.uiScale), Math.round((parent ? parent.width : 1600) * 0.5))
  height: Math.round(430 * Config.uiScale)
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Qt.rgba(1,1,1,0.10)

  readonly property int columns: (screen && screen.width > 1920) ? 5 : 4

  GridView {
    id: grid
    anchors.fill: parent
    anchors.margins: 10
    clip: true
    model: WallpaperService.wallpapers
    cellWidth: Math.floor((width - 10) / root.columns)
    cellHeight: Math.floor(cellWidth * 0.7) + 26
    currentIndex: -1

    delegate: Item {
      required property var modelData
      required property int index
      width: grid.cellWidth
      height: grid.cellHeight

      Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 8
        color: cellHover.containsMouse || modelData === WallpaperService.current ? Config.surface : "transparent"
        border.color: modelData === WallpaperService.current ? Config.accent : "transparent"
        border.width: modelData === WallpaperService.current ? 2 : 0

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 4
          spacing: 3

          Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 6
            color: Config.surface
            clip: true

            Image {
              anchors.fill: parent
              source: modelData
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
            }
          }

          ShellText {
            Layout.fillWidth: true
            Layout.preferredHeight: 14
            text: modelData.split("/").pop()
            color: Config.subtext
            font.pixelSize: Config.fsTiny
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
          }
        }

        MouseArea {
          id: cellHover
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            WallpaperService.apply(modelData)
            root.closeRequested()
          }
        }
      }
    }
  }

  onOpenChanged: {
    if (root.open) {
      const idx = WallpaperService.wallpapers.indexOf(WallpaperService.current)
      if (idx >= 0) {
        grid.currentIndex = idx
        grid.positionViewAtIndex(idx, GridView.Center)
      }
    }
  }
}