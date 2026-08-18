import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// Live system stats fed by scripts/shjstats (single tab-separated line):
// cpu% ramUsed ramTotal dlBps ulBps diskUsed diskTotal
// Compact single-row display that fits the island bar.
RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  spacing: 8

  readonly property int cpu: stats.cpu
  readonly property int ramUsed: stats.ramUsed
  readonly property int ramTotal: stats.ramTotal
  readonly property int dlBps: stats.dlBps
  readonly property int ulBps: stats.ulBps
  readonly property int diskUsed: stats.diskUsed
  readonly property int diskTotal: stats.diskTotal

  function human(v) {
    if (v >= 1073741824) return (v / 1073741824).toFixed(1) + "G"
    if (v >= 1048576) return (v / 1048576).toFixed(1) + "M"
    if (v >= 1024) return (v / 1024).toFixed(1) + "K"
    return v.toString()
  }

  function pct(used, total) {
    if (total <= 0) return 0
    return Math.min(100, Math.round((used / total) * 100))
  }

  QtObject {
    id: stats
    property int cpu: 0
    property int ramUsed: 0
    property int ramTotal: 1
    property int dlBps: 0
    property int ulBps: 0
    property int diskUsed: 0
    property int diskTotal: 1
  }

  // ---- compact single-line readout ----
  ShellText {
    text: "CPU"
    color: root.subColor
    font.pixelSize: Config.fsTiny
  }
  ShellText {
    text: (root.cpu || 0) + "%"
    Layout.minimumWidth: Math.round(30 * Config.uiScale)
    color: root.textColor
    font.pixelSize: Config.fsTiny
  }

  ShellText {
    text: "RAM"
    color: root.subColor
    font.pixelSize: Config.fsTiny
  }
  ShellText {
    text: root.human(root.ramUsed) + "/" + root.human(root.ramTotal)
    Layout.minimumWidth: Math.round(52 * Config.uiScale)
    color: root.textColor
    font.pixelSize: Config.fsTiny
  }

  ShellText {
    text: "↓"
    color: Config.green
    font.pixelSize: Config.fsTiny
  }
  ShellText {
    text: root.human(root.dlBps) + "/s"
    Layout.minimumWidth: Math.round(34 * Config.uiScale)
    color: root.textColor
    font.pixelSize: Config.fsTiny
  }
  ShellText {
    text: "↑"
    color: Config.red
    font.pixelSize: Config.fsTiny
  }
  ShellText {
    text: root.human(root.ulBps) + "/s"
    Layout.minimumWidth: Math.round(34 * Config.uiScale)
    color: root.textColor
    font.pixelSize: Config.fsTiny
  }

  ShellText {
    text: "DISK"
    color: root.subColor
    font.pixelSize: Config.fsTiny
  }
  ShellText {
    text: root.human(root.diskUsed) + "/" + root.human(root.diskTotal)
    Layout.minimumWidth: Math.round(52 * Config.uiScale)
    color: Config.yellow
    font.pixelSize: Config.fsTiny
  }

  // Poll shjstats every interval; StdioCollector receives each run's full output.
  Timer {
    id: pollTimer
    interval: Config.statsIntervalMs
    running: true
    repeat: true
    onTriggered: statProc.exec(["sh", "-c", Config.statsCmd])
  }

  Process {
    id: statProc
    command: ["sh", "-c", Config.statsCmd]
    stdout: StdioCollector {
      onStreamFinished: {
        // take the last non-empty line (robust to any accumulated buffer)
        const lines = (text || "").split(/\r?\n/)
        let line = ""
        for (let i = lines.length - 1; i >= 0; i--) {
          if (lines[i].trim() !== "") { line = lines[i].trim(); break }
        }
        const f = line.split("\t")
        if (f.length < 7) return
        function num(x, dflt) {
          const n = parseInt(x)
          return (Number.isFinite(n) && n >= 0) ? n : dflt
        }
        stats.cpu = num(f[0], 0)
        stats.ramUsed = num(f[1], 0)
        stats.ramTotal = Math.max(1, num(f[2], 1))
        stats.dlBps = num(f[3], 0)
        stats.ulBps = num(f[4], 0)
        stats.diskUsed = num(f[5], 0)
        stats.diskTotal = Math.max(1, num(f[6], 1))
      }
    }
  }
}