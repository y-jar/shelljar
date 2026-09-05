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
import Quickshell.Services.UPower

RowLayout {
  id: root

  property color textColor: Config.text
  signal batteryClicked

  readonly property var battery: UPower.displayDevice
  readonly property bool hasBattery: battery !== null && battery.isPresent
  readonly property bool charging: battery !== null && (battery.state === UPowerDeviceState.Charging
      || battery.state === UPowerDeviceState.PendingCharge
      || battery.state === UPowerDeviceState.FullyCharged)
  readonly property real pct: battery !== null ? battery.percentage : 0
  readonly property bool low: battery !== null && !charging && pct <= Config.batteryLow
  readonly property bool critical: battery !== null && !charging && pct <= Config.batteryCritical

  readonly property color statusColor: charging ? Config.green : (critical ? Config.red : (low ? Config.yellow : root.textColor))

  visible: hasBattery

  function icon() {
    if (charging) return "⚡"
    if (pct >= 50) return "🔋"
    return "🪫"
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
      ShellText {
        text: root.icon()
        color: root.statusColor
        font.pixelSize: Config.fsSmall
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