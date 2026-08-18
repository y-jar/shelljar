import qs.components
import QtQuick
import QtQuick.Layouts

// Dock wallpaper button: wheel pops out the wallpaper carousel, click opens the picker.
RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  property color hoverBg: Config.surface

  signal openRequested(var dir)
  signal gridRequested

  function cycle(dir) { root.openRequested(dir) }

  Rectangle {
    Layout.fillHeight: true
    Layout.preferredWidth: Math.round(110 * Config.uiScale)
    implicitHeight: 34
    radius: 10
    color: root.hoverBg
    border.color: Qt.rgba(1,1,1,0.05)

    ColumnLayout {
      anchors.centerIn: parent
      spacing: 0
      ShellText {
        text: "🖼  Wallpapers"
        color: root.textColor
        font.pixelSize: Config.fsSmall
      }
      ShellText {
        text: "scroll to preview"
        color: root.subColor
        font.pixelSize: Config.fsTiny
      }
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onWheel: event => root.cycle(event.angleDelta.y > 0 ? "prev" : "next")
      onClicked: root.gridRequested()
    }
  }
}