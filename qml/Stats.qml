/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Stats
 *
 *   A compact single row of system stats for the bar. Each figure is one
 *   StatsPill (glyph + short value); the full reading lives in the pill's
 *   tooltip, so the bar stays scannable instead of turning into a wall of text.
 *   It draws on the SystemStat singleton.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  spacing: Math.round(9 * Config.uiScale)

  function human(v) {
    if (v >= 1073741824) return (v / 1073741824).toFixed(1) + "G"
    if (v >= 1048576) return (v / 1048576).toFixed(1) + "M"
    if (v >= 1024) return (v / 1024).toFixed(0) + "K"
    return Math.round(v) + "B"
  }

  StatsPill {
    glyph: "cpu"
    glyphColor: Config.blue
    value: Math.round(SystemStat.cpuUsage) + "%"
    tooltip: "CPU · " + Math.round(SystemStat.cpuUsage) + "%"
  }

  StatsPill {
    glyph: "ram"
    glyphColor: Config.green
    value: root.human(SystemStat.memUsedBytes)
    tooltip: "RAM · " + root.human(SystemStat.memUsedBytes) + " / " + root.human(SystemStat.memTotalBytes)
  }

  StatsPill {
    glyph: "arrow-down"
    glyphColor: Config.green
    value: root.human(SystemStat.rxBps) + "/s"
    tooltip: "Network down · " + root.human(SystemStat.rxBps) + "/s"
  }

  StatsPill {
    glyph: "arrow-up"
    glyphColor: Config.red
    value: root.human(SystemStat.txBps) + "/s"
    tooltip: "Network up · " + root.human(SystemStat.txBps) + "/s"
  }

  StatsPill {
    glyph: "disk"
    glyphColor: Config.yellow
    value: root.human(SystemStat.diskUsedBytes)
    tooltip: "Disk · " + root.human(SystemStat.diskUsedBytes) + " / " + root.human(SystemStat.diskTotalBytes)
  }
}
