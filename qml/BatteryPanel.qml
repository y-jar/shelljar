/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   BatteryPanel
 *
 *   A popout frame opened from the right island battery pill. It lists each
 *   laptop battery with its percent, remaining time, a fill bar and the charge
 *   health, and it lets the user choose a power profile. A close button
 *   dismisses it on demand.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

Rectangle {
  id: root

  property bool open: false
  signal closeRequested

  width: Config.popupWidth
  height: Math.round(300 * Config.uiScale)
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Config.borderStrong

  function fmtTime(seconds) {
    if (seconds <= 0) return ""
    const h = Math.floor(seconds / 3600)
    const m = Math.round((seconds % 3600) / 60)
    if (h > 0) return h + "h " + m + "m"
    return m + "m"
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8

    RowLayout {
      Layout.fillWidth: true
      ShellText {
        text: "Battery"
        color: Config.text
        font.pixelSize: Config.fsMedium
        font.weight: Font.DemiBold
      }
      Item { Layout.fillWidth: true }
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

    Rectangle {
      Layout.fillWidth: true
      height: 1
      color: Config.borderSoft
    }

    // batteries
    Repeater {
      model: UPower.devices

      delegate: Item {
        required property var modelData
        visible: modelData.isLaptopBattery
        Layout.fillWidth: true
        implicitHeight: 40

        ColumnLayout {
          anchors.fill: parent
          spacing: 3

          RowLayout {
            Layout.fillWidth: true
            ShellText {
              text: (modelData.name && modelData.name !== "") ? modelData.name : "Battery"
              color: Config.subtext
              font.pixelSize: Config.fsTiny
            }
            Item { Layout.fillWidth: true }
            ShellText {
              text: {
                const t = modelData.state === UPowerDeviceState.Charging || modelData.state === UPowerDeviceState.PendingCharge
                  ? modelData.timeToFull : modelData.timeToEmpty
                return fmtTime(t)
              }
              color: Config.subtext
              font.pixelSize: Config.fsTiny
            }
            ShellText {
              text: Math.round(modelData.percentage) + "%"
              color: Config.text
              font.pixelSize: Config.fsTiny
              font.weight: Font.DemiBold
            }
          }

          Rectangle {
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: Config.surfaceAlt
            Rectangle {
              width: parent.width * Math.min(1, modelData.percentage / 100)
              height: parent.height
              radius: 3
              color: (modelData.state === UPowerDeviceState.Charging || modelData.state === UPowerDeviceState.FullyCharged)
                ? Config.green : (modelData.percentage <= Config.batteryCritical ? Config.red : Config.accent)
            }
          }
        }
      }
    }

    Rectangle {
      Layout.fillWidth: true
      height: 1
      color: Config.borderSoft
    }

    // power profile
    ShellText {
      text: "Power profile"
      color: Config.subtext
      font.pixelSize: Config.fsTiny
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 6

      Repeater {
        model: ["powersaver", "balanced", "performance"]

        delegate: Rectangle {
          required property string modelData
          Layout.fillWidth: true
          implicitHeight: 30
          radius: 8
          color: active() ? Config.accent : Config.surface
          border.color: Config.borderStrong

          function active() {
            return (modelData === "powersaver" && PowerProfiles.profile === PowerProfile.PowerSaver)
              || (modelData === "balanced" && PowerProfiles.profile === PowerProfile.Balanced)
              || (modelData === "performance" && PowerProfiles.profile === PowerProfile.Performance)
          }
          function apply() {
            if (modelData === "powersaver") PowerProfiles.profile = PowerProfile.PowerSaver
            else if (modelData === "balanced") PowerProfiles.profile = PowerProfile.Balanced
            else if (modelData === "performance") PowerProfiles.profile = PowerProfile.Performance
          }

          ShellText {
            anchors.centerIn: parent
            text: modelData === "powersaver" ? "🌿" : modelData === "balanced" ? "⚖️" : "🚀"
            color: parent.active() ? Config.white : Config.text
            font.pixelSize: Config.fsSmall
          }
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.apply()
          }
        }
      }
    }

    ShellText {
      text: "Health: " + Math.round(UPower.displayDevice && UPower.displayDevice.healthSupported ? UPower.displayDevice.healthPercentage : 0) + "%"
      visible: UPower.displayDevice !== null && UPower.displayDevice.healthSupported
      color: Config.subtext
      font.pixelSize: Config.fsTiny
    }

    Item { Layout.fillHeight: true }
  }
}