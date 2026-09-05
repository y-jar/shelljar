/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   BrightnessPanel
 *
 *   A small popout frame opened from the right island brightness pill. It shows
 *   a draggable slider and the current percentage and greys out when no display
 *   can be adjusted. A close button dismisses it on demand.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root

  property bool open: false
  readonly property bool available: BrightnessService.available
  signal closeRequested

  width: Config.popupWidth
  height: Math.round(90 * Config.uiScale)
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Config.borderStrong

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
        color: root.available ? Config.text : Config.subtext
        font.pixelSize: Config.fsSmall
      }
      ShellText {
        text: "✕"
        color: Config.subtext
        font.pixelSize: Config.fsSmall
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.closeRequested()
        }
      }
    }

    Slider {
      Layout.fillWidth: true
      value: BrightnessService.value
      step: Config.brightnessStep
      enabled: root.available
      fillColor: Config.accent
      onChanged: v => BrightnessService.setValue(v)
    }
  }
}