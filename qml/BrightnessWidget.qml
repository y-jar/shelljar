import qs.components
import QtQuick
import QtQuick.Layouts

// Dock brightness pill: icon + %, wheel changes, hover shows OSD, click opens panel.
RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  signal hoverRequested
  signal brightnessPanelRequested

  readonly property real value: BrightnessService.value
  readonly property bool available: BrightnessService.available

  function icon() {
    if (!available) return "☀"
    if (value <= 0.001) return "☀"
    if (value <= 0.5) return "🔅"
    return "🔆"
  }

  Rectangle {
    Layout.preferredWidth: Math.round(64 * Config.uiScale)
    implicitHeight: 26
    radius: 13
    color: hoverArea.containsMouse ? Config.surfaceAlt : Config.surface
    border.color: Qt.rgba(1,1,1,0.10)
    visible: available

    RowLayout {
      anchors.centerIn: parent
      spacing: 5
      ShellText {
        text: root.icon()
        color: root.textColor
        font.pixelSize: Config.fsSmall
      }
      ShellText {
        text: Math.round(root.value * 100) + "%"
        color: root.textColor
        font.pixelSize: Config.fsTiny
      }
    }

    MouseArea {
      id: hoverArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: root.hoverRequested()
      onWheel: event => BrightnessService.step(event.angleDelta.y > 0 ? 0.05 : -0.05)
      onClicked: root.brightnessPanelRequested()
    }
  }
}