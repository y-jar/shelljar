/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   BrightnessWidget
 *
 *   A compact dock pill for screen brightness. The wheel steps it, hovering
 *   pulses the OSD and a click opens the panel. When no backlight or display
 *   can be adjusted it renders greyed out and does nothing.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root

  property color textColor: Config.text
  signal hoverRequested
  signal brightnessPanelRequested

  readonly property real value: BrightnessService.value
  readonly property bool available: BrightnessService.available

  function icon() {
    if (!available) return "☀"
    if (value <= Config.brightnessEpsilon) return "☀"
    if (value <= 0.5) return "🔅"
    return "🔆"
  }

  Rectangle {
    Layout.preferredWidth: Config.pillWidth
    Layout.preferredHeight: Config.pillHeight
    radius: Config.pillHeight / 2
    color: hoverArea.containsMouse ? Config.surfaceAlt : Config.surface
    border.color: Config.borderStrong
    opacity: root.available ? 1 : 0.4

    RowLayout {
      anchors.centerIn: parent
      spacing: 5
      ShellText {
        text: root.icon()
        color: (root.available ? root.textColor : Config.subtext)
        font.pixelSize: Config.fsSmall
      }
      ShellText {
        text: Math.round(root.value * 100) + "%"
        color: (root.available ? root.textColor : Config.subtext)
        font.pixelSize: Config.fsTiny
      }
    }

    MouseArea {
      id: hoverArea
      anchors.fill: parent
      enabled: root.available
      hoverEnabled: root.available
      onEntered: root.hoverRequested()
      onWheel: event => BrightnessService.step(event.angleDelta.y > 0 ? Config.brightnessStep : -Config.brightnessStep)
      onClicked: root.brightnessPanelRequested()
    }
  }
}