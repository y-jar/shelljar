import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

// Dock network pill: a Wi-Fi signal-level icon (or ethernet glyph) + connected
// name. Left-click opens the network popdown panel.
RowLayout {
  id: root

  signal networkClicked

  property color textColor: Config.text
  property color subColor: Config.subtext

  readonly property var devices: Networking.devices || []

  function findDevice(t) {
    for (const d of root.devices) { if (d && d.type === t) return d }
    return null
  }
  readonly property var wifiDevice: findDevice(DeviceType.Wifi)
  readonly property var wiredDevice: findDevice(DeviceType.Wired)

  function activeNetwork(dev) {
    if (!dev || !dev.networks) return null
    for (const n of dev.networks) { if (n.connected) return n }
    return null
  }
  readonly property var activeWifi: activeNetwork(root.wifiDevice)
  readonly property bool wiredUp: root.wiredDevice !== null && root.wiredDevice.connected

  readonly property int wifiLevel: activeWifi
    ? Math.min(4, Math.max(0, Math.ceil(activeWifi.signalStrength / 25))) : 0
  readonly property bool wifiEnabled: Networking.wifiEnabled
  readonly property bool online: root.activeWifi !== null || root.wiredUp

  Rectangle {
    Layout.preferredWidth: Math.round(100 * Config.uiScale)
    implicitHeight: 28
    radius: 14
    color: hover.containsMouse ? Config.surfaceAlt : Config.surface
    border.color: Qt.rgba(1, 1, 1, 0.10)

    RowLayout {
      anchors.centerIn: parent
      spacing: 6

      Item {
        width: Math.round(18 * Config.uiScale)
        height: width
        // Wi-Fi level icon (primary). Ethernet-active shows the level icon at full,
        // tinted accent; otherwise it reflects the live wifi level (or 0 when off).
        WifiIcon {
          anchors.fill: parent
          level: root.activeWifi ? root.wifiLevel : (root.wifiEnabled ? 0 : 0)
          color: root.online ? Config.accent : Config.text
        }
      }

      ShellText {
        Layout.preferredWidth: Math.round(58 * Config.uiScale)
        text: {
          if (root.activeWifi) return root.activeWifi.name
          if (root.wiredUp) return "Ethernet"
          if (root.wifiEnabled) return "Wi-Fi"
          return "Off"
        }
        color: root.online ? root.textColor : root.subColor
        font.pixelSize: Config.fsTiny
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
      }
    }

    MouseArea {
      id: hover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.networkClicked()
    }
  }
}