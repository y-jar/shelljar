import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// Power/session actions for the control center.
ColumnLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext

  Process { id: sysProc }

  function run(cmd) { sysProc.exec(["sh", "-c", cmd]) }

  ShellText {
    text: "Session"
    color: root.textColor
    font.pixelSize: Config.fsMedium
    font.weight: Font.DemiBold
  }

  GridLayout {
    columns: 4
    columnSpacing: 6
    rowSpacing: 6

    Repeater {
      model: ["lock", "logout", "reboot", "power"]

      delegate: Rectangle {
        width: Math.round(52 * Config.uiScale); height: Math.round(44 * Config.uiScale); radius: 8
        color: Config.surface
        border.color: Qt.rgba(1,1,1,0.05)

        ShellText {
          anchors.centerIn: parent
          text: ({ lock: "🔒", logout: "↪", reboot: "⟳", power: "⏻" }[modelData] || "")
          color: root.textColor
          font.pixelSize: Config.fsLarge
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: parent.color = Config.surfaceAlt
          onExited: parent.color = Config.surface
          onClicked: {
            if (modelData === "lock") root.run("loginctl lock-session")
            else if (modelData === "logout") root.run("loginctl terminate-user ${USER}")
            else if (modelData === "reboot") root.run("systemctl reboot")
            else if (modelData === "power") root.run("systemctl poweroff")
          }
        }
      }
    }
  }
}