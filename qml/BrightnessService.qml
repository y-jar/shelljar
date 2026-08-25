pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// ---- backlight service ----
// Finds /sys/class/backlight/*, reads via FileView (watched for external changes),
// writes via brightnessctl.
Item {
  id: root

  property string device: ""
  property int brightness: 0
  property int maxBrightness: 1
  property real value: 0
  readonly property bool available: device !== ""

  function setValue(v) {
    v = Math.max(0, Math.min(1, v))
    if (!available) return
    const pct = Math.round(v * 100)
    setProc.exec(["brightnessctl", "-d", root.device, "s", pct + "%"])
    root.value = v
  }

  function step(delta) {
    if (!available) return
    setValue(root.value + delta)
  }

  // find first backlight device
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

  Component.onCompleted: {
    findProc.exec(["sh", "-c", "for d in /sys/class/backlight/*; do [ -d \"$d\" ] && { echo \"${d##*/}\"; break; }; done"])
  }
}