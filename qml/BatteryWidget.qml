import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

// Dock battery pill: icon + %, colored when charging/low/critical. Click opens the panel.
RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  signal batteryClicked

  readonly property var battery: UPower.displayDevice
  readonly property bool hasBattery: battery !== null && battery.isPresent
  readonly property bool charging: battery !== null && (battery.state === UPowerDeviceState.Charging
      || battery.state === UPowerDeviceState.PendingCharge
      || battery.state === UPowerDeviceState.FullyCharged)
  readonly property real pct: battery !== null ? battery.percentage : 0
  readonly property bool low: battery !== null && !charging && pct <= 20
  readonly property bool critical: battery !== null && !charging && pct <= 10

  visible: hasBattery

  function icon() {
    if (!hasBattery) return "🪫"
    if (charging) return "⚡"
    if (pct >= 50) return "🔋"
    return "🪫"
  }

  Rectangle {
    Layout.preferredWidth: Math.round(64 * Config.uiScale)
    implicitHeight: 26
    radius: 13
    color: hoverArea.containsMouse ? Config.surfaceAlt : Config.surface
    border.color: Qt.rgba(1,1,1,0.10)

    RowLayout {
      anchors.centerIn: parent
      spacing: 5
      ShellText {
        text: root.icon()
        color: (root.charging || root.critical) ? Config.red : root.textColor
        font.pixelSize: Config.fsSmall
      }
      ShellText {
        text: Math.round(root.pct) + "%"
        color: (root.critical) ? Config.red : root.textColor
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