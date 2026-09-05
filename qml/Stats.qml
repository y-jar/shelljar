/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Stats
 *
 *   A compact single row readout of CPU, memory, network and disk usage that
 *   draws on the SystemStat singleton. Each field has its own color so the row
 *   stays easy to scan, and long values elide instead of squeezing the layout.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root

  property color textColor: Config.text
  property color subColor: Config.subtext
  spacing: 8

  function human(v) {
    if (v >= 1073741824) return (v / 1073741824).toFixed(2) + "G"
    if (v >= 1048576) return (v / 1048576).toFixed(2) + "M"
    if (v >= 1024) return (v / 1024).toFixed(2) + "K"
    return v.toFixed(2)
  }

  // ---- CPU ----
  ShellText { text: "CPU"; color: root.subColor; font.pixelSize: Config.fsTiny }
  ShellText {
    text: Math.round(SystemStat.cpuUsage) + "%"
    color: root.textColor
    font.pixelSize: Config.fsTiny
    Layout.minimumWidth: Math.round(30 * Config.uiScale)
    elide: Text.ElideRight
  }

  // ---- RAM ----
  ShellText { text: "RAM"; color: root.subColor; font.pixelSize: Config.fsTiny }
  ShellText {
    text: root.human(SystemStat.memUsedBytes) + "/" + root.human(SystemStat.memTotalBytes)
    color: root.textColor
    font.pixelSize: Config.fsTiny
    Layout.minimumWidth: Math.round(52 * Config.uiScale)
    elide: Text.ElideRight
  }

  // ---- NET ----
  ShellText { text: "↓"; color: Config.green; font.pixelSize: Config.fsTiny }
  ShellText {
    text: root.human(SystemStat.rxBps) + "/s"
    color: root.textColor
    font.pixelSize: Config.fsTiny
    Layout.minimumWidth: Math.round(34 * Config.uiScale)
    elide: Text.ElideRight
  }
  ShellText { text: "↑"; color: Config.red; font.pixelSize: Config.fsTiny }
  ShellText {
    text: root.human(SystemStat.txBps) + "/s"
    color: root.textColor
    font.pixelSize: Config.fsTiny
    Layout.minimumWidth: Math.round(34 * Config.uiScale)
    elide: Text.ElideRight
  }

  // ---- DISK ----
  ShellText { text: "DISK"; color: root.subColor; font.pixelSize: Config.fsTiny }
  ShellText {
    text: root.human(SystemStat.diskUsedBytes) + "/" + root.human(SystemStat.diskTotalBytes)
    color: Config.yellow
    font.pixelSize: Config.fsTiny
    Layout.minimumWidth: Math.round(52 * Config.uiScale)
    elide: Text.ElideRight
  }
}