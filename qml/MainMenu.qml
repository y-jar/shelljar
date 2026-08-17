import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell

// Main menu opened by right-clicking the island pill (noctalia-style context
// menu). Lists the panels + session actions; selecting one runs it and closes.
Rectangle {
  id: root

  property bool open: false
  width: Math.round(220 * Config.uiScale)
  implicitHeight: content.implicitHeight + 24
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Qt.rgba(1,1,1,0.10)
  focus: true

  signal openPower
  signal openLauncher
  signal openControlCenter
  signal closeRequested

  readonly property var items: [
    { key: "power", glyph: "⚡", label: "Power menu" },
    { key: "launcher", glyph: "▦", label: "Launcher" },
    { key: "control", glyph: "☰", label: "Control center" },
    { key: "sep", glyph: null, label: "" },
    { key: "lock", glyph: "🔒", label: "Lock" },
    { key: "suspend", glyph: "⏾", label: "Suspend" },
    { key: "logout", glyph: "↪", label: "Logout" },
  ]

  function command(key) {
    switch (key) {
    case "lock": return "loginctl lock-session"
    case "suspend": return "systemctl suspend"
    case "logout": return "loginctl terminate-user ${USER}"
    }
    return ""
  }

  function select(key) {
    switch (key) {
    case "power": root.openPower(); break
    case "launcher": root.openLauncher(); break
    case "control": root.openControlCenter(); break
    case "lock": case "suspend": case "logout":
      Quickshell.execDetached(["sh", "-c", command(key)])
      root.closeRequested(); break
    }
  }

  ColumnLayout {
    id: content
    anchors.fill: parent
    anchors.margins: 12
    spacing: 4

    Repeater {
      model: root.items

      delegate: Item {
        required property var modelData
        Layout.fillWidth: true

        implicitHeight: modelData.separator ? 1 : Math.round(34 * Config.uiScale)

        // separator
        Rectangle {
          anchors.fill: parent
          visible: modelData.separator
          color: Qt.rgba(1,1,1,0.06)
        }

        // item row
        Rectangle {
          anchors.fill: parent
          visible: !modelData.separator
          radius: 8
          color: itemHover.containsMouse ? Config.surface : "transparent"

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10

            ShellText {
              text: modelData.glyph || ""
              color: Config.text
              font.pixelSize: Config.fsSmall
            }
            ShellText {
              text: modelData.label || ""
              color: Config.text
              font.pixelSize: Config.fsSmall
            }
            Item { Layout.fillWidth: true }
          }

          MouseArea {
            id: itemHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.select(modelData.key)
          }
        }
      }
    }
  }

  Keys.onEscapePressed: root.closeRequested()
}