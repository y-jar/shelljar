import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// Middle island: scroll to cycle wallpapers, click to open the picker.
RowLayout {
  id: root

  property color textColor: config.text
  property color subColor: config.subtext
  property color hoverBg: config.surface

  function cycle(dir) {
    wallProc.exec(["sh", "-c", config.wallpaperCmd + " " + dir])
  }

  Rectangle {
    Layout.fillHeight: true
    Layout.preferredWidth: 120
    implicitHeight: 34
    radius: 10
    color: root.hoverBg
    border.color: Qt.rgba(1,1,1,0.05)

    // hover hint
    ColumnLayout {
      anchors.centerIn: parent
      spacing: 0
      Text {
        text: "🖼  Wallpapers"
        color: root.textColor
        font.pixelSize: 11
      }
      Text {
        text: "scroll to change"
        color: root.subColor
        font.pixelSize: 8
      }
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onWheel: root.cycle(wheel.angleDelta.y > 0 ? "next" : "prev")
      onClicked: wallProc.exec(["sh", "-c", "waypaper"])  // fallback; picker keybind also exists
      onDoubleClicked: wallProc.exec(["sh", "-c", "waypaper"])
    }
  }

  Process {
    id: wallProc
    stdout: StdioCollector {
      onStreamFinished: { if (text && text.trim() !== "") console.log("[shelljar] wallpaper:", text.trim()) }
    }
    onRunningChanged: { if (!running) running = false }
  }
}