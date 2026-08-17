import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// Power/session actions for the control center.
ColumnLayout {
  id: root

  property color textColor: config.text
  property color subColor: config.subtext

  Process { id: sysProc }

  function run(cmd) { sysProc.exec(["sh", "-c", cmd]) }

  Text {
    text: "Session"
    color: root.textColor
    font.pixelSize: 12
    font.weight: Font.DemiBold
  }

  GridLayout {
    columns: 4
    columnSpacing: 6
    rowSpacing: 6

    Repeater {
      model: ["lock", "logout", "reboot", "power"]

      delegate: Rectangle {
        width: 52; height: 44; radius: 8
        color: config.surface
        border.color: Qt.rgba(1,1,1,0.05)

        Text {
          anchors.centerIn: parent
          text: ({ lock: "🔒", logout: "↪", reboot: "⟳", power: "⏻" }[modelData] || "")
          color: root.textColor
          font.pixelSize: 14
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: parent.color = config.surfaceAlt
          onExited: parent.color = config.surface
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