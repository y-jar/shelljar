pragma Singleton
import QtQuick
import Quickshell.Io

// ---- self-contained system stats (noctalia-style) ----
// Reads /proc directly via Quickshell.Io.FileView + Timers; disk via `df`.
// All values are `real` (never QML `int`) so large byte counts can't overflow.
Item {
  id: root

  // public values
  property real cpuUsage: 0
  property real memUsedBytes: 0
  property real memTotalBytes: 1
  property real rxBps: 0
  property real txBps: 0
  property real diskUsedBytes: 0
  property real diskTotalBytes: 1

  // deltas / previous samples
  property real _prevTotal: 0
  property real _prevIdle: 0
  property real _prevRx: 0
  property real _prevTx: 0
  property real _prevTime: 0

  function isVirtual(name) {
    return name === "lo" || /^(veth|virbr|docker|br-|tun|tap|wg|vlan|dummy|bond)/.test(name)
  }

  function parseMemory(text) {
    let total = 0, avail = 0
    for (const line of text.split("\n")) {
      const p = line.split(/\s+/)
      if (p[0] === "MemTotal:") total = parseInt(p[1]) || 0
      else if (p[0] === "MemAvailable:") avail = parseInt(p[1]) || 0
    }
    if (total > 0) {
      root.memUsedBytes = Math.max(0, total - avail) * 1024
      root.memTotalBytes = total * 1024
    }
  }

  function parseCpu(text) {
    const p = text.split("\n")[0].split(/\s+/)
    if (p[0] !== "cpu") return
    let idle = (parseInt(p[4]) || 0) + (parseInt(p[5]) || 0)
    let total = 0
    for (let i = 1; i < p.length; i++) total += parseInt(p[i]) || 0
    const tDelta = total - root._prevTotal
    const iDelta = idle - root._prevIdle
    root._prevTotal = total
    root._prevIdle = idle
    if (tDelta > 0) {
      root.cpuUsage = Math.max(0, Math.min(100, ((tDelta - iDelta) * 100) / tDelta))
    }
  }

  function parseNet(text) {
    let rx = 0, tx = 0
    const lines = text.split("\n")
    for (let i = 2; i < lines.length; i++) {
      const line = lines[i].trim()
      if (!line) continue
      const ci = line.indexOf(":")
      if (ci === -1) continue
      const ifac = line.substring(0, ci).trim()
      if (root.isVirtual(ifac)) continue
      const s = line.substring(ci + 1).trim().split(/\s+/)
      rx += parseInt(s[0], 10) || 0
      tx += parseInt(s[8], 10) || 0
    }
    const now = Date.now()
    if (root._prevTime > 0) {
      const dsec = (now - root._prevTime) / 1000
      if (dsec > 0) {
        root.rxBps = Math.max(0, rx - root._prevRx) / dsec
        root.txBps = Math.max(0, tx - root._prevTx) / dsec
      }
    }
    root._prevRx = rx
    root._prevTx = tx
    root._prevTime = now
  }

  function parseDisk(text) {
    const lines = (text || "").split("\n")
    if (lines.length >= 2) {
      const p = lines[1].trim().split(/\s+/)
      if (p.length >= 3) {
        root.diskTotalBytes = (parseInt(p[1]) || 0) * 1024
        root.diskUsedBytes = (parseInt(p[2]) || 0) * 1024
      }
    }
  }

  FileView {
    id: memInfoFile
    path: "/proc/meminfo"
    onLoaded: root.parseMemory(text())
  }

  FileView {
    id: cpuStatFile
    path: "/proc/stat"
    onLoaded: root.parseCpu(text())
  }

  FileView {
    id: netDevFile
    path: "/proc/net/dev"
    onLoaded: root.parseNet(text())
  }

  Process {
    id: dfProc
    stdout: StdioCollector {
      onStreamFinished: root.parseDisk(text)
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: cpuStatFile.reload()
  }
  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: netDevFile.reload()
  }
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: memInfoFile.reload()
  }
  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: dfProc.exec(["df", "-P", "/"])
  }

  Component.onCompleted: {
    cpuStatFile.reload()
    memInfoFile.reload()
    netDevFile.reload()
    dfProc.exec(["df", "-P", "/"])
  }
}