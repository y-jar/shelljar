/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   NetworkPanel
 *
 *   A full popout network panel opened from the left island. It can list and
 *   connect to wifi networks with a password prompt, disconnect or forget a
 *   saved one, show live details for both wifi and ethernet, toggle the radio
 *   and report the current internet connectivity.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Rectangle {
  id: root

  property bool open: false
  signal closeRequested

  width: Config.networkPanelWidth
  height: Math.min(Math.round(520 * Config.uiScale), Math.round((root.parent ? root.parent.height : 600) - 90))
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Config.borderStrong

  // ---- state ----
  property string view: "wifi" // "wifi" | "ethernet"
  property var pskTarget: null
  property string pskText: ""
  property int detailWifiIndex: -1
  property int detailEthIndex: -1

  readonly property var devices: (Networking.devices && Networking.devices.values) || []
  function findDevice(t) { for (const d of root.devices) { if (d && d.type === t) return d } return null }
  readonly property var wifiDevice: findDevice(DeviceType.Wifi)
  readonly property var wired: findDevice(DeviceType.Wired)
  readonly property var wifiNetworks: (root.wifiDevice && root.wifiDevice.networks && root.wifiDevice.networks.values) || []
  readonly property bool hasWired: root.wired !== null
  readonly property bool hasWifi: root.wifiDevice !== null
  readonly property bool wifiEnabled: Networking.wifiEnabled

  function level(sig) { return Math.min(4, Math.max(0, Math.ceil((sig || 0) / 25))) }
  function secured(n) { return n ? !!n.security : false }

  // ---- nmcli detail fetch ----
  property string nmDetail: ""
  Process {
    id: nm
    stdout: StdioCollector { onStreamFinished: root.nmDetail = (text || "") }
  }
  function runNm(iface) {
    root.nmDetail = ""
    nm.exec(["nmcli", "-t", "-f",
      "GENERAL.DEVICE,GENERAL.HWADDR,GENERAL.SPEED,IP4.ADDRESS,IP4.GATEWAY,IP4.DNS[1],IP6.ADDRESS,IP6.GATEWAY,IP6.DNS[1]",
      "device", "show", iface])
  }
  function nmValue(raw, key) {
    for (const line of (raw || "").split("\n")) {
      if (line.startsWith(key + ":")) return line.substring(key.length + 1)
    }
    return ""
  }

  onOpenChanged: {
    if (root.open) {
      root.view = (!root.hasWifi && root.hasWired) ? "ethernet" : "wifi"
      pskTarget = null; pskText = ""; detailWifiIndex = -1; detailEthIndex = -1
      if (root.hasWired && root.wired.connected) root.runNm(root.wired.name)
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8

    // ---- header ----
    RowLayout {
      Layout.fillWidth: true
      spacing: 8
      ShellText {
        text: "Network"
        color: Config.text
        font.pixelSize: Config.fsMedium
        font.weight: Font.DemiBold
      }
      Item { Layout.fillWidth: true }

      ShellText {
        text: root.wifiEnabled ? "Wi-Fi on" : "Wi-Fi off"
        color: root.wifiEnabled ? Config.green : Config.subtext
        font.pixelSize: Config.fsTiny
        visible: root.hasWifi
      }
      Rectangle {
        Layout.preferredWidth: 36
        Layout.preferredHeight: 20
        radius: 10
        color: root.wifiEnabled ? Config.accent : Config.surfaceAlt
        visible: root.hasWifi
        MouseArea { anchors.fill: parent; onClicked: Networking.wifiEnabled = !Networking.wifiEnabled }
        Rectangle {
          width: 16; height: 16; radius: 8; color: Config.white
          x: root.wifiEnabled ? parent.width - width - 2 : 2
          anchors.verticalCenter: parent.verticalCenter
          Behavior on x { NumberAnimation { duration: 120 } }
        }
      }
      ShellText {
        text: "✕"
        color: Config.subtext
        font.pixelSize: Config.fsSmall
        MouseArea { anchors.fill: parent; onClicked: root.closeRequested() }
      }
    }

    // ---- view tabs ----
    RowLayout {
      Layout.fillWidth: true
      visible: root.hasWifi && root.hasWired
      spacing: 6
      Repeater {
        model: ["wifi", "ethernet"]
        delegate: Rectangle {
          required property string modelData
          Layout.fillWidth: true
          implicitHeight: 30
          radius: 8
          color: root.view === modelData ? Config.accent : Config.surface
          MouseArea { anchors.fill: parent; onClicked: root.view = modelData }
          ShellText {
            anchors.centerIn: parent
            text: modelData === "wifi" ? "Wi-Fi" : "Ethernet"
            color: root.view === modelData ? Config.white : Config.text
            font.pixelSize: Config.fsSmall
          }
        }
      }
    }

    Rectangle {
      Layout.fillWidth: true
      height: 1
      color: Config.borderSoft
    }

    // ---- scrollable content ----
    Flickable {
      id: scroll
      Layout.fillWidth: true
      Layout.fillHeight: true
      contentWidth: width
      contentHeight: content.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds

      ColumnLayout {
        id: content
        width: scroll.width
        spacing: 8

        // ===== Wi-Fi =====
        ColumnLayout {
          visible: root.view === "wifi"
          Layout.fillWidth: true
          spacing: 6

          ShellText {
            visible: root.hasWifi && !root.wifiEnabled
            Layout.fillWidth: true
            text: "Wi-Fi is off"
            color: Config.subtext
            font.pixelSize: Config.fsSmall
            horizontalAlignment: Text.AlignHCenter
          }
          ShellText {
            visible: root.wifiEnabled && root.wifiNetworks.length === 0
            Layout.fillWidth: true
            text: "Scanning…"
            color: Config.subtext
            font.pixelSize: Config.fsSmall
            horizontalAlignment: Text.AlignHCenter
          }

          Repeater {
            model: root.wifiEnabled ? root.wifiNetworks : []

            delegate: ColumnLayout {
              required property var modelData
              required property int index
              spacing: 4
              Layout.fillWidth: true

              function isDetail() { return root.detailWifiIndex === index }

              Rectangle {
                Layout.fillWidth: true
                implicitHeight: 38
                radius: 8
                color: modelData.connected ? Config.accent : (hoverArea.containsMouse ? Config.surfaceAlt : Config.surface)

                RowLayout {
                  anchors.fill: parent
                  anchors.margins: 8
                  spacing: 8
                  Item {
                    width: Math.round(16 * Config.uiScale); height: width
                    WifiIcon {
                      anchors.fill: parent
                      level: root.level(modelData.signalStrength)
                      color: modelData.connected ? Config.white : Config.text
                    }
                  }
                  ShellText {
                    Layout.fillWidth: true
                    text: modelData.name || "?"
                    color: modelData.connected ? Config.white : Config.text
                    font.pixelSize: Config.fsSmall
                    elide: Text.ElideRight
                  }
                  ShellText {
                    text: root.secured(modelData) ? "🔒" : ""
                    color: modelData.connected ? Config.white : Config.subtext
                    font.pixelSize: Config.fsTiny
                    visible: root.secured(modelData)
                  }
                  ShellText {
                    text: modelData.connected ? "Connected" : (modelData.known ? "Known" : "")
                    color: modelData.connected ? Config.white : Config.subtext
                    font.pixelSize: Config.fsTiny
                    visible: modelData.connected || modelData.known
                  }
                  ShellText {
                    text: modelData.stateChanging ? "…" : ""
                    color: Config.white
                    font.pixelSize: Config.fsTiny
                    visible: !!modelData.stateChanging
                  }
                }

                MouseArea {
                  id: hoverArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    const n = modelData
                    if (n.connected) {
                      root.detailWifiIndex = isDetail() ? -1 : index
                      root.pskTarget = null
                      if (root.hasWifi && root.wifiDevice.name && root.detailWifiIndex === index) {
                        root.runNm(root.wifiDevice.name)
                      }
                    } else if (n.known || !root.secured(n)) {
                      n.connect()
                    } else {
                      root.pskTarget = n
                      root.pskText = ""
                      root.detailWifiIndex = -1
                    }
                  }
                }
              }

              // PSK entry
              Rectangle {
                visible: root.pskTarget === modelData && !modelData.connected
                Layout.fillWidth: true
                implicitHeight: 40
                radius: 8
                color: Config.surface

                RowLayout {
                  anchors.fill: parent
                  anchors.margins: 8
                  spacing: 8
                  TextField {
                    id: pskField
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholderText: "WPA password…"
                    placeholderTextColor: Config.subtext
                    color: Config.text
                    background: Rectangle { color: Config.surfaceAlt; radius: 6 }
                    font.pixelSize: Config.fsSmall
                    text: root.pskText
                    onTextChanged: root.pskText = text
                    Keys.onReturnPressed: root.connectPsk()
                  }
                  Rectangle {
                    implicitWidth: 54; implicitHeight: 26; radius: 6; color: Config.accent
                    MouseArea {
                      anchors.fill: parent
                      onClicked: root.connectPsk()
                    }
                    ShellText {
                      anchors.centerIn: parent
                      text: "Connect"; color: Config.white; font.pixelSize: Config.fsTiny
                    }
                  }
                }
              }

              // wifi details
              ColumnLayout {
                visible: isDetail() && modelData.connected
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                  model: [
                    { k: "Signal", v: (modelData.signalStrength || 0) + "%" },
                    { k: "Security", v: root.secured(modelData) ? "Secured" : "Open" },
                    { k: "IP", v: root.nmValue(root.nmDetail, "IP4.ADDRESS") }
                  ]
                  delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 8
                    ShellText {
                      text: modelData.k; color: Config.subtext; font.pixelSize: Config.fsTiny; Layout.preferredWidth: 104
                    }
                    ShellText {
                      Layout.fillWidth: true
                      text: modelData.v; color: Config.text; font.pixelSize: Config.fsTiny
                      elide: Text.ElideRight; horizontalAlignment: Text.AlignRight
                    }
                  }
                }

                RowLayout {
                  Layout.fillWidth: true
                  spacing: 8
                  Item { Layout.fillWidth: true }
                  Rectangle {
                    implicitWidth: 78; implicitHeight: 26; radius: 6; color: Config.surfaceAlt
                    MouseArea {
                      anchors.fill: parent
                      onClicked: { modelData.disconnect(); root.detailWifiIndex = -1 }
                    }
                    ShellText { anchors.centerIn: parent; text: "Disconnect"; color: Config.text; font.pixelSize: Config.fsTiny }
                  }
                  Rectangle {
                    implicitWidth: 56; implicitHeight: 26; radius: 6; color: Config.surfaceAlt
                    visible: modelData.known
                    MouseArea {
                      anchors.fill: parent
                      onClicked: modelData.forget()
                    }
                    ShellText { anchors.centerIn: parent; text: "Forget"; color: Config.text; font.pixelSize: Config.fsTiny }
                  }
                }
              }
            }
          }
        }

        // ===== Ethernet =====
        ColumnLayout {
          visible: root.view === "ethernet"
          Layout.fillWidth: true
          spacing: 6

          ShellText {
            visible: !root.hasWired
            Layout.fillWidth: true
            text: "No ethernet device"
            color: Config.subtext
            font.pixelSize: Config.fsSmall
            horizontalAlignment: Text.AlignHCenter
          }

          Repeater {
            model: root.hasWired ? [root.wired] : []

            delegate: ColumnLayout {
              required property var modelData
              spacing: 4
              Layout.fillWidth: true

              function isDetail() { return root.detailEthIndex === 0 }

              Rectangle {
                Layout.fillWidth: true
                implicitHeight: 38
                radius: 8
                color: modelData.connected ? Config.accent : Config.surface

                RowLayout {
                  anchors.fill: parent
                  anchors.margins: 8
                  spacing: 8
                  ShellText {
                    text: "🔌"
                    color: modelData.connected ? Config.white : Config.subtext
                    font.pixelSize: Config.fsSmall
                  }
                  ShellText {
                    Layout.fillWidth: true
                    text: modelData.name || "Ethernet"
                    color: modelData.connected ? Config.white : Config.text
                    font.pixelSize: Config.fsSmall
                    elide: Text.ElideRight
                  }
                  ShellText {
                    text: (modelData.address && modelData.address.length ? modelData.address[0] : "")
                      || (modelData.connected ? "Connected" : "Disconnected")
                    color: modelData.connected ? Config.white : Config.subtext
                    font.pixelSize: Config.fsTiny
                    elide: Text.ElideRight
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.detailEthIndex = isDetail() ? -1 : 0
                    if (root.detailEthIndex === 0) root.runNm(modelData.name)
                  }
                }
              }

              ColumnLayout {
                visible: isDetail()
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                  model: [
                    { k: "Interface", v: root.nmValue(root.nmDetail, "GENERAL.DEVICE") },
                    { k: "Hardware Addr", v: root.nmValue(root.nmDetail, "GENERAL.HWADDR") },
                    { k: "Link speed", v: root.nmValue(root.nmDetail, "GENERAL.SPEED") },
                    { k: "IPv4", v: root.nmValue(root.nmDetail, "IP4.ADDRESS") },
                    { k: "Gateway", v: root.nmValue(root.nmDetail, "IP4.GATEWAY") },
                    { k: "DNS", v: root.nmValue(root.nmDetail, "IP4.DNS") },
                    { k: "IPv6", v: root.nmValue(root.nmDetail, "IP6.ADDRESS") }
                  ]
                  delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 8
                    ShellText {
                      text: modelData.k; color: Config.subtext; font.pixelSize: Config.fsTiny; Layout.preferredWidth: 104
                    }
                    ShellText {
                      Layout.fillWidth: true
                      text: modelData.v; color: Config.text; font.pixelSize: Config.fsTiny
                      elide: Text.ElideRight; horizontalAlignment: Text.AlignRight
                    }
                  }
                }
              }
            }
          }
        }

        // ---- connectivity footer ----
        ShellText {
          Layout.fillWidth: true
          text: {
            switch (root.wifiConnectivity) {
            case NetworkConnectivity.Full: return "Internet: connected"
            case NetworkConnectivity.Limited: return "Internet: limited"
            case NetworkConnectivity.Portal: return "Internet: portal / sign-in"
            case NetworkConnectivity.None: return "No internet"
            default: return "Internet: unknown"
            }
          }
          color: {
            switch (root.wifiConnectivity) {
            case NetworkConnectivity.Full: return Config.green
            case NetworkConnectivity.Limited:
            case NetworkConnectivity.Portal: return Config.yellow
            default: return Config.subtext
            }
          }
          font.pixelSize: Config.fsTiny
        }
      }
    }
  }

  readonly property var wifiConnectivity: Networking.connectivity

  function connectPsk() {
    if (root.pskTarget) root.pskTarget.connectWithPsk(root.pskText)
    root.pskTarget = null
  }
}