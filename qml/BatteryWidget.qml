/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   BatteryWidget
 *
 *   A compact dock pill for the battery. It shows an icon and the percentage,
 *   colored by the state so charging reads green, critical reads red and a low
 *   charge reads yellow. A click opens the battery panel.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root

  property color textColor: Config.text
  signal batteryClicked

  // all battery maths lives in BatteryService (UPower reports 0-1 fractions)
  readonly property bool hasBattery: BatteryService.present
  readonly property bool charging: BatteryService.charging
  readonly property real pct: BatteryService.percent
  readonly property bool low: BatteryService.low
  readonly property bool critical: BatteryService.critical

  readonly property color statusColor: charging ? Config.green : (critical ? Config.red : (low ? Config.yellow : root.textColor))

  visible: hasBattery

  function iconName() {
    if (charging) return "battery-charging"
    return "battery"
  }

  Rectangle {
    Layout.preferredWidth: Config.pillWidth
    Layout.preferredHeight: Config.pillHeight
    radius: Config.pillHeight / 2
    color: hoverArea.containsMouse ? Config.surfaceAlt : Config.surface
    border.color: Config.borderStrong

    RowLayout {
      anchors.centerIn: parent
      spacing: 5
      GlyphIcon {
        Layout.preferredWidth: Math.round(14 * Config.uiScale)
        Layout.preferredHeight: Math.round(14 * Config.uiScale)
        name: root.iconName()
        color: root.statusColor
        stroke: 1.7
      }
      ShellText {
        text: Math.round(root.pct) + "%"
        color: root.statusColor
        font.pixelSize: Config.fsTiny
      }
    }

    MouseArea {
      id: hoverArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.batteryClicked()
    }
  }
}