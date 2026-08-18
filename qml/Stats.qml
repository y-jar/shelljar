import qs.components
import QtQuick
import QtQuick.Layouts

// Compact single-row system stats, fed by the self-contained
// SystemStat singleton (reads /proc directly — no external script).
RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  spacing: 8

  function human(v) {
    if (v >= 1073741824) return (v / 1073741824).toFixed(1) + "G"
    if (v >= 1048576) return (v / 1048576).toFixed(1) + "M"
    if (v >= 1024) return (v / 1024).toFixed(1) + "K"
    return v.toString()
  }

  // ---- CPU ----
  ShellText { text: "CPU"; color: root.subColor; font.pixelSize: Config.fsTiny }
  ShellText {
    text: Math.round(SystemStat.cpuUsage) + "%"
    color: root.textColor
    font.pixelSize: Config.fsTiny
    Layout.minimumWidth: Math.round(30 * Config.uiScale)
  }

  // ---- RAM ----
  ShellText { text: "RAM"; color: root.subColor; font.pixelSize: Config.fsTiny }
  ShellText {
    text: root.human(SystemStat.memUsedBytes) + "/" + root.human(SystemStat.memTotalBytes)
    color: root.textColor
    font.pixelSize: Config.fsTiny
    Layout.minimumWidth: Math.round(52 * Config.uiScale)
  }

  // ---- NET ----
  ShellText { text: "↓"; color: Config.green; font.pixelSize: Config.fsTiny }
  ShellText {
    text: root.human(SystemStat.rxBps) + "/s"
    color: root.textColor
    font.pixelSize: Config.fsTiny
    Layout.minimumWidth: Math.round(34 * Config.uiScale)
  }
  ShellText { text: "↑"; color: Config.red; font.pixelSize: Config.fsTiny }
  ShellText {
    text: root.human(SystemStat.txBps) + "/s"
    color: root.textColor
    font.pixelSize: Config.fsTiny
    Layout.minimumWidth: Math.round(34 * Config.uiScale)
  }

  // ---- DISK ----
  ShellText { text: "DISK"; color: root.subColor; font.pixelSize: Config.fsTiny }
  ShellText {
    text: root.human(SystemStat.diskUsedBytes) + "/" + root.human(SystemStat.diskTotalBytes)
    color: Config.yellow
    font.pixelSize: Config.fsTiny
    Layout.minimumWidth: Math.round(52 * Config.uiScale)
  }
}