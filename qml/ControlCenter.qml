/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   ControlCenter
 *
 *   The profile frame that opens under the bar. It shows the current user, an
 *   audio slider and a button that opens the full power menu. Notifications
 *   keep their own separate panel so this stays a compact identity card.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth

Rectangle {
  id: root

  property bool open: false
  width: Config.controlCenterWidth
  height: Config.controlCenterHeight
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Config.borderMid

  property color textColor: Config.text
  property color subColor: Config.subtext

  signal openSession

  readonly property var radio: Bluetooth.defaultAdapter

  function btOn() { return root.radio !== null && root.radio.enabled }
  function btOff() { return root.radio !== null && !root.radio.enabled }

  ScrollView {
    anchors.fill: parent
    anchors.margins: 14
    clip: true

    ColumnLayout {
      width: parent.width
      spacing: 12

      // user row
      RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
          width: Math.round(42 * Config.uiScale); height: Math.round(42 * Config.uiScale); radius: 21
          color: Config.surface
          border.color: Config.borderMid
          ShellText {
            anchors.centerIn: parent
            text: "👤"
            font.pixelSize: Config.fsLarge
          }
        }

        ColumnLayout {
          spacing: 2
          ShellText {
            id: userLabel
            text: user()
            color: root.textColor
            font.pixelSize: Config.fsMedium
            font.weight: Font.DemiBold
          }
          ShellText {
            text: "desktop shell"
            color: root.subColor
            font.pixelSize: Config.fsTiny
          }
        }

        Item { Layout.fillWidth: true }
      }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Config.borderSoft
      }

      ShellText { text: "Audio"; color: root.subColor; font.pixelSize: Config.fsTiny }
      AudioWidget { }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Config.borderSoft
      }

      // UI scale — adjusts shelljar text/widget sizing, persisted to config.kdl.
      RowLayout {
        Layout.fillWidth: true
        spacing: 10
        ShellText {
          text: "⚲"
          color: root.textColor
          font.pixelSize: Config.fsSmall
        }
        ShellText {
          Layout.fillWidth: true
          text: "UI scale"
          color: root.subColor
          font.pixelSize: Config.fsSmall
        }
        ShellText {
          text: Math.round(Config.userScale * 100) + "%"
          color: root.textColor
          font.pixelSize: Config.fsSmall
        }
      }
      Slider {
        id: scaleSlider
        Layout.fillWidth: true
        from: 0.6
        to: 2.0
        step: 0.05
        value: Config.userScale
        onChanged: v => root.setScale(v)
      }
      Component.onCompleted: {
        scaleSlider.value = Config.userScale
        scaleSlider.changed.connect(root.setScale)
      }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Config.borderSoft
      }

      // Bluetooth toggle, shown only when a radio adapter exists
      RowLayout {
        visible: root.radio !== null
        Layout.fillWidth: true
        spacing: 8
        ShellText {
          text: "🅱"
          color: root.textColor
          font.pixelSize: Config.fsSmall
        }
        ShellText {
          Layout.fillWidth: true
          text: root.btOn() ? "Bluetooth on" : "Bluetooth off"
          color: root.btOn() ? Config.green : root.subColor
          font.pixelSize: Config.fsSmall
        }
        Rectangle {
          Layout.preferredWidth: 36
          Layout.preferredHeight: 20
          radius: 10
          color: root.btOn() ? Config.accent : Config.surfaceAlt
          MouseArea { anchors.fill: parent; onClicked: root.radio.enabled = !root.radio.enabled }
          Rectangle {
            width: 16; height: 16; radius: 8; color: Config.white
            x: root.btOn() ? parent.width - width - 2 : 2
            anchors.verticalCenter: parent.verticalCenter
            Behavior on x { NumberAnimation { duration: 120 } }
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Config.borderSoft
      }

      // full-screen power menu trigger
      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 40
        radius: 10
        color: Config.surface
        border.color: Config.borderMid

        RowLayout {
          anchors.fill: parent
          anchors.margins: 12
          spacing: 8
          ShellText {
            text: "⏻"
            color: Config.red
            font.pixelSize: Config.fsMedium + 2
          }
          ShellText {
            text: "Power menu"
            color: root.textColor
            font.pixelSize: Config.fsSmall
          }
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: parent.color = Config.surfaceAlt
          onExited: parent.color = Config.surface
          onClicked: root.openSession()
        }
      }
    }
  }

  function user() {
    const u = Quickshell.env("USER")
    return u != null && u !== "" ? u : "jar"
  }

  function setScale(v) {
    ColorService.setUiScale(v)
  }
}