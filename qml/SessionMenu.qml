import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Full-screen power / session menu (adapted from noctalia-4.7.1 SessionMenu.qml).
// Destructive actions (Power Off / Reboot) arm a countdown: click to arm, click
// again or timeout executes, ESC cancels. Others run on click.
Rectangle {
  id: root

  property bool open: false
  property color scrimColor: "#99000000"
  color: "transparent"

  signal closeRequested

  readonly property int countdownMs: Config.sessionCountdownMs

  // ---- actions ----
  readonly property var actions: [
    { key: "poweroff", label: "Power Off", glyph: "⏻", shutdown: true },
    { key: "reboot", label: "Reboot", glyph: "⟳", shutdown: true },
    { key: "logout", label: "Logout", glyph: "↪", shutdown: false },
    { key: "suspend", label: "Suspend", glyph: "⏾", shutdown: false },
    { key: "lock", label: "Lock", glyph: "🔒", shutdown: false },
  ]

  property var pendingKey: "" // action currently counting down
  property int timeRemaining: 0

  function command(key) {
    switch (key) {
    case "lock": return "loginctl lock-session"
    case "suspend": return "systemctl suspend"
    case "logout": return "loginctl terminate-user ${USER}"
    case "reboot": return "systemctl reboot"
    case "poweroff": return "systemctl poweroff"
    }
    return ""
  }

  function execute(key) {
    timer.stop()
    pendingKey = ""
    timeRemaining = 0
    Quickshell.execDetached(["sh", "-c", command(key)])
    root.closeRequested()
  }

  function arm(key) {
    // clicking again on the armed action confirms immediately
    if (pendingKey === key) { execute(key); return }
    pendingKey = key
    timeRemaining = countdownMs
    timer.start()
  }

  function cancel() {
    timer.stop()
    pendingKey = ""
    timeRemaining = 0
  }

  Timer {
    id: timer
    interval: 250
    repeat: true
    onTriggered: {
      timeRemaining -= 250
      if (timeRemaining <= 0) root.execute(root.pendingKey)
    }
  }

  // ---- dim scrim ----
  Rectangle {
    anchors.fill: parent
    color: root.scrimColor

    MouseArea {
      anchors.fill: parent
      onClicked: { if (root.pendingKey !== "") root.cancel(); else root.closeRequested() }
    }
  }

  // ---- centered action grid ----
  GridLayout {
    id: grid
    anchors.centerIn: parent
    columns: Config.sessionColumns
    columnSpacing: Config.spacing * 2
    rowSpacing: Config.spacing * 2

    Repeater {
      model: root.actions

      delegate: Rectangle {
        required property var modelData
        required property int index
        readonly property bool isPending: root.pendingKey === modelData.key
        readonly property real progress: isPending ? (root.countdownMs - root.timeRemaining) / root.countdownMs : 0

        width: Config.sessionButtonSize
        height: Config.sessionButtonSize
        radius: Math.round(Config.cornerRadius * 1.5)
        color: isPending ? Config.accent : (hoverArea.containsMouse ? Config.surfaceAlt : Config.surface)
        border.width: 1
        border.color: isPending ? Config.accent : Qt.rgba(1,1,1,0.12)

        ColumnLayout {
          anchors.centerIn: parent
          spacing: Config.spacing
          z: 2

          // countdown ring canvas (only when pending)
          Canvas {
            readonly property real r: Config.sessionButtonSize * 0.28
            Layout.preferredWidth: r * 2
            Layout.preferredHeight: r * 2
            Layout.alignment: Qt.AlignHCenter
            visible: parent.parent.isPending
            onPaint: {
              const ctx = getContext("2d")
              const s = width
              ctx.clearRect(0, 0, s, s)
              ctx.lineWidth = 4
              ctx.strokeStyle = Qt.rgba(1,1,1,0.25)
              ctx.beginPath()
              ctx.arc(s/2, s/2, r-2, 0, 2*Math.PI)
              ctx.stroke()
              ctx.strokeStyle = "#ffffff"
              ctx.beginPath()
              ctx.arc(s/2, s/2, r-2, -Math.PI/2, -Math.PI/2 + 2*Math.PI*parent.parent.progress)
              ctx.stroke()
            }
            Connections {
              target: parent.parent
              function onProgressChanged() { parent.requestPaint() }
            }
          }

          ShellText {
            Layout.alignment: Qt.AlignHCenter
            text: parent.parent.isPending
                  ? Math.max(1, Math.ceil(root.timeRemaining / 1000)) + "s"
                  : modelData.glyph
            color: parent.parent.isPending ? "white" : (modelData.shutdown ? Config.red : Config.text)
            font.pixelSize: Config.fsMedium * 1.6
          }

          ShellText {
            Layout.alignment: Qt.AlignHCenter
            text: modelData.label
            color: parent.parent.isPending ? "white" : Config.text
            font.pixelSize: Config.fsSmall + 2
          }
        }

        // background click area (below ring canvas)
        MouseArea {
          id: hoverArea
          anchors.fill: parent
          hoverEnabled: true
          onClicked: {
            if (modelData.shutdown) root.arm(modelData.key)
            else root.execute(modelData.key)
          }
        }
      }
    }
  }
}