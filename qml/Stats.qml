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
    text: (root.cpu || 0) + "%"
    color: root.textColor
    font.pixelSize: Config.fsTiny
  }

  ShellText {
    text: root.human(root.ramUsed) + "/" + root.human(root.ramTotal)
    color: root.textColor
    font.pixelSize: Config.fsTiny
  }

  ShellText {
    text: "↓" + root.human(root.dlBps) + "/s"
    color: Config.green
    font.pixelSize: Config.fsTiny
  }
  ShellText {
    text: "↑" + root.human(root.ulBps) + "/s"
    color: Config.red
    font.pixelSize: Config.fsTiny
  }

  ShellText {
    text: "◧" + root.human(root.diskUsed) + "/" + root.human(root.diskTotal)
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
        const line = (text || "").trim()
        const f = line.split("\t")
        if (f.length < 7) return
        stats.cpu = parseInt(f[0]) || 0
        stats.ramUsed = parseInt(f[1]) || 0
        stats.ramTotal = parseInt(f[2]) || 1
        stats.dlBps = parseInt(f[3]) || 0
        stats.ulBps = parseInt(f[4]) || 0
        stats.diskUsed = parseInt(f[5]) || 0
        stats.diskTotal = parseInt(f[6]) || 1
      }
    }
  }
}