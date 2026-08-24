import qs.components
import QtQuick
import QtQuick.Layouts

// Pop-out brightness panel: slider + %.
Rectangle {
  id: root

  property bool open: false
  signal closeRequested

  width: Math.round(300 * Config.uiScale)
  implicitHeight: 90
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Qt.rgba(1,1,1,0.10)

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 14
    spacing: 10

    RowLayout {
      Layout.fillWidth: true
      ShellText {
        text: "Brightness"
        color: Config.text
        font.pixelSize: Config.fsMedium
        font.weight: Font.DemiBold
      }
      Item { Layout.fillWidth: true }
      ShellText {
        text: Math.round(BrightnessService.value * 100) + "%"
        color: Config.text
        font.pixelSize: Config.fsSmall
      }
    }

    // slider
    Rectangle {
      id: track
      Layout.fillWidth: true
      Layout.preferredHeight: Math.round(10 * Config.uiScale)
      radius: height / 2
      color: Config.surfaceAlt

      Rectangle {
        id: fill
        width: track.width * BrightnessService.value
        height: track.height
        radius: height / 2
        color: Config.accent
      }

      Rectangle {
        id: knob
        width: Math.round(16 * Config.uiScale)
        height: width
        radius: width / 2
        x: Math.max(0, Math.min(track.width - width, fill.width - width / 2))
        y: (track.height - height) / 2
        color: "#ffffff"
        border.color: Qt.rgba(0,0,0,0.3)
        border.width: 1
      }

      MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: if (pressed) BrightnessService.setValue(mouse.x / width)
        onClicked: BrightnessService.setValue(mouse.x / width)
      }
    }
  }
}