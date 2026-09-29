/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   ControlCenter
 *
 *   The profile frame that opens under the bar: the user row with a power
 *   button, a grid of quick-settings tiles (wifi, bluetooth, wallpaper, UI
 *   scale), audio and brightness sliders, and a power-profile segmented
 *   control. It is a Panel, so it inherits the shared surface and reveal.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.UPower

Panel {
  id: root
  anchors.fill: parent

  signal openSession
  signal openScaleLayer
  signal openWallpaper

  readonly property var radio: Bluetooth.defaultAdapter

  function btOn() { return root.radio !== null && root.radio.enabled }

  function profileKey() {
    switch (PowerProfiles.profile) {
    case PowerProfile.PowerSaver: return "powersaver"
    case PowerProfile.Performance: return "performance"
    default: return "balanced"
    }
  }

  function applyProfile(key) {
    if (key === "powersaver") PowerProfiles.profile = PowerProfile.PowerSaver
    else if (key === "performance") PowerProfiles.profile = PowerProfile.Performance
    else PowerProfiles.profile = PowerProfile.Balanced
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: Math.round(12 * Config.uiScale)

    // ---- user row ----
    RowLayout {
      Layout.fillWidth: true
      spacing: Math.round(10 * Config.uiScale)

      Rectangle {
        width: Math.round(38 * Config.uiScale)
        height: width
        radius: width / 2
        color: Config.surfaceHigh
        border.width: 1
        border.color: Config.outlineSoft
        GlyphIcon {
          anchors.centerIn: parent
          width: Math.round(20 * Config.uiScale)
          height: width
          name: "user"
          color: Config.text
          stroke: 1.7
        }
      }

      ColumnLayout {
        spacing: 0
        ShellText {
          text: {
            const u = Quickshell.env("USER")
            return u != null && u !== "" ? u : "jar"
          }
          color: Config.text
          font.pixelSize: Config.fsMedium
          font.weight: Font.DemiBold
        }
        ShellText {
          text: "shelljar"
          color: Config.subtext
          font.pixelSize: Config.fsTiny
        }
      }

      Item { Layout.fillWidth: true }

      IconButton {
        glyph: "power"
        glyphColor: Config.red
        tooltip: "Power menu"
        onClicked: root.openSession()
      }
    }

    Divider { Layout.fillWidth: true }

    // ---- quick-settings tiles ----
    GridLayout {
      Layout.fillWidth: true
      columns: 4
      columnSpacing: Math.round(8 * Config.uiScale)
      rowSpacing: Math.round(8 * Config.uiScale)

      ToggleTile {
        Layout.fillWidth: true
        glyph: "wifi"
        label: "Wi-Fi"
        checked: Networking.wifiEnabled
        onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
      }
      ToggleTile {
        Layout.fillWidth: true
        glyph: "bluetooth"
        label: "BT"
        checked: root.btOn()
        enabled: root.radio !== null
        onClicked: root.radio.enabled = !root.radio.enabled
      }
      ToggleTile {
        Layout.fillWidth: true
        glyph: "wallpaper"
        label: "Wall"
        onClicked: root.openWallpaper()
      }
      ToggleTile {
        Layout.fillWidth: true
        glyph: "scaling"
        label: "Scale"
        onClicked: root.openScaleLayer()
      }
    }

    Divider { Layout.fillWidth: true }

    // ---- audio ----
    ShellText { text: "Audio"; color: Config.subtext; font.pixelSize: Config.fsTiny }
    AudioWidget { Layout.fillWidth: true }

    // ---- brightness ----
    RowLayout {
      Layout.fillWidth: true
      spacing: Math.round(8 * Config.uiScale)

      GlyphIcon {
        Layout.alignment: Qt.AlignVCenter
        width: Math.round(14 * Config.uiScale)
        height: width
        name: "sun"
        color: Config.text
        stroke: 1.7
      }
      Slider {
        Layout.fillWidth: true
        value: BrightnessService.value
        step: Config.brightnessStep
        enabled: BrightnessService.available
        fillColor: Config.accent
        onChanged: v => BrightnessService.setValue(v)
      }
      ShellText {
        Layout.alignment: Qt.AlignVCenter
        Layout.minimumWidth: Math.round(34 * Config.uiScale)
        text: Math.round(BrightnessService.value * 100) + "%"
        color: Config.text
        font.pixelSize: Config.fsTiny
        horizontalAlignment: Text.AlignRight
      }
    }

    Divider { Layout.fillWidth: true }

    // ---- power profile ----
    ShellText { text: "Power profile"; color: Config.subtext; font.pixelSize: Config.fsTiny }
    Segmented {
      Layout.fillWidth: true
      value: root.profileKey()
      options: [
        { value: "powersaver", label: "Saver" },
        { value: "balanced", label: "Balanced" },
        { value: "performance", label: "Performance" }
      ]
      onSelected: v => root.applyProfile(v)
    }
  }
}
