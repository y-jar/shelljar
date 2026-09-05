/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   NetworkWidget
 *
 *   A compact icon pill for the left island. It shows the ethernet glyph when a
 *   wire is up, or a wireless glyph at the live signal level otherwise. A wifi
 *   radio that is on but idle shows a slash across the dim arcs so the state is
 *   always readable at a glance.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

RowLayout {
  id: root

  signal networkClicked

  readonly property var devices: (Networking.devices && Networking.devices.values) || []
  function findDevice(t) { for (const d of root.devices) { if (d && d.type === t) return d } return null }
  readonly property var wifiDevice: findDevice(DeviceType.Wifi)
  readonly property var wiredDevice: findDevice(DeviceType.Wired)

  function activeNetwork(dev) {
    if (!dev || !dev.networks) return null
    const nets = dev.networks.values || dev.networks
    for (const n of nets) { if (n.connected) return n }
    return null
  }
  readonly property var activeWifi: activeNetwork(root.wifiDevice)
  readonly property bool wiredUp: root.wiredDevice !== null && root.wiredDevice.connected
  readonly property bool wifiEnabled: Networking.wifiEnabled
  readonly property bool wifiConnected: root.activeWifi !== null
  readonly property int wifiLevel: activeWifi
    ? Math.min(4, Math.max(0, Math.ceil(activeWifi.signalStrength / 25))) : 0

  Rectangle {
    Layout.preferredWidth: Math.round(32 * Config.uiScale)
    Layout.preferredHeight: Math.round(30 * Config.uiScale)
    radius: 8
    color: hover.containsMouse ? Config.surfaceAlt : Config.surface
    border.color: Config.borderStrong

    Item {
      anchors.centerIn: parent
      width: Math.round(18 * Config.uiScale)
      height: width

      // ethernet active -> ethernet icon only
      EthernetIcon {
        anchors.fill: parent
        visible: root.wiredUp
        color: Config.accent
      }

      // otherwise -> wireless icon
      WifiIcon {
        anchors.fill: parent
        visible: !root.wiredUp
        level: root.wifiConnected ? root.wifiLevel : 0
        slash: root.wifiEnabled && !root.wifiConnected
        color: root.wifiConnected ? Config.accent : Config.text
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