import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// Live system stats fed by scripts/shjstats (single tab-separated line):
// cpu% ramUsed ramTotal dlBps ulBps diskUsed diskTotal
ColumnLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext

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

  // ---- bars ----
  ColumnLayout {
    Layout.fillWidth: true
    spacing: 4

    // CPU
    RowLayout {
      Layout.fillWidth: true
      spacing: 6
      Rectangle {
        width: 44; height: 4; radius: 2
        color: Config.surfaceAlt
        Rectangle {
          width: parent.width * (stats.cpu / 100)
          height: parent.height
          radius: 2
          color: Config.accent
        }
      }
      Text { text: stats.cpu + "%"; color: root.textColor; font.pixelSize: Config.fsTiny }
    }

    // RAM
    RowLayout {
      Layout.fillWidth: true
      spacing: 6
      Rectangle {
        width: 44; height: 4; radius: 2
        color: Config.surfaceAlt
        Rectangle {
          width: parent.width * (root.pct(root.ramUsed, root.ramTotal) / 100)
          height: parent.height
          radius: 2
          color: Config.blue
        }
      }
      Text { text: root.human(root.ramUsed) + "/" + root.human(root.ramTotal); color: root.textColor; font.pixelSize: Config.fsTiny }
    }

    // NET
    RowLayout {
      Layout.fillWidth: true
      spacing: 6
      Text { text: "↓"; color: Config.green; font.pixelSize: Config.fsTiny }
      Text { text: root.human(root.dlBps) + "/s"; color: root.textColor; font.pixelSize: Config.fsTiny }
      Text { text: "↑"; color: Config.red; font.pixelSize: Config.fsTiny; Layout.leftMargin: 4 }
      Text { text: root.human(root.ulBps) + "/s"; color: root.textColor; font.pixelSize: Config.fsTiny }
    }

    // DISK
    RowLayout {
      Layout.fillWidth: true
      spacing: 6
      Text { text: "◧"; color: Config.yellow; font.pixelSize: Config.fsTiny }
      Text { text: root.human(root.diskUsed) + "/" + root.human(root.diskTotal); color: root.textColor; font.pixelSize: Config.fsTiny }
    }
  }

  Item { Layout.fillWidth: true; Layout.fillHeight: true }
}