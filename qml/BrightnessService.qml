pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// ---- brightness service ----
// Two backends:
//   1. Kernel backlight (/sys/class/backlight/*) via FileView + brightnessctl (laptops).
//   2. Desktop monitor brightness via DDC/CI (ddcutil) when no kernel backlight exists.
// `available` is true if either backend is present; a widget shows greyed when false.
Item {
  id: root

  // kernel backlight
  property string device: ""
  property int brightness: 0
  property int maxBrightness: 1
  // monitor (DDC/CI)
  property bool monitorAvailable: false
  // unified current value, 0..1
  property real value: 0
  readonly property bool available: device !== "" || monitorAvailable

  function setValue(v) {
    v = Math.max(0, Math.min(1, v))
    if (!available) return
    if (device !== "") {
      // kernel backlight
      const pct = Math.round(v * 100)
      setProc.exec(["brightnessctl", "-d", root.device, "s", pct + "%"])
      root.value = v
    } else if (monitorAvailable) {
      // monitor DDC/CI (VCP 10 = brightness, 0-100)
      setDdcProc.exec(["ddcutil", "setvcp", "10", String(Math.round(v * 100))])
      root.value = v
    }
  }

  function step(delta) {
    if (!available) return
    setValue(root.value + delta)
  }

  function pollValue() {
    if (!monitorAvailable) return
    getvcpProc.exec(["ddcutil", "getvcp", "10"])
  }

  // ---- kernel backlight (existing) ----
  Process {
    id: findProc
    stdout: StdioCollector {
      onStreamFinished: {
        const d = (text || "").trim().split("\n")[0] || ""
        root.device = d
        brightnessFile.path = d === "" ? "" : "/sys/class/backlight/" + d + "/brightness"
        maxFile.path = d === "" ? "" : "/sys/class/backlight/" + d + "/max_brightness"
      }
    }
  }
  Process { id: setProc }
  Process {
    id: setDdcProc
  }

  FileView {
    id: brightnessFile
    watchChanges: root.device !== ""
    onFileChanged: reload()
    onLoaded: root.brightness = parseInt(text()) || 0
  }
  FileView {
    id: maxFile
    onLoaded: root.maxBrightness = parseInt(text()) || 1
  }
  onBrightnessChanged: { root.value = maxBrightness > 0 ? brightness / maxBrightness : 0 }

  // ---- monitor DDC/CI detection + polling ----
  Process {
    id: detectProc
    stdout: StdioCollector {
      onStreamFinished: {
        const out = (text || "").trim().split("\n").filter(l => l.trim() !== "")
        root.monitorAvailable = out.length > 0
        root.pollValue()
      }
    }
  }
  Process {
    id: getvcpProc
    stdout: StdioCollector {
      onStreamFinished: root.parseValue(text || "")
    }
  }
  function parseValue(t) {
    const m = (t || "").match(/current value\s*=\s*(\d+)/i)
    if (m) {
      const n = parseInt(m[1])
      // VCP 10 is normally 0-100
      root.value = Math.max(0, Math.min(1, n / 100))
    }
  }

  Timer {
    id: pollTimer
    interval: 2500
    running: root.monitorAvailable
    repeat: true
    onTriggered: root.pollValue()
  }

  Component.onCompleted: {
    findProc.exec(["sh", "-c", "for d in /sys/class/backlight/*; do [ -d \"$d\" ] && { echo \"${d##*/}\"; break; }; done"])
    detectProc.exec(["ddcutil", "detect", "--brief"])
  }
}