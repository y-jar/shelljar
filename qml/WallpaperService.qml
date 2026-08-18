pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// ---- wallpaper list + apply (caelestia-style service, applies via awww) ----
// Reads the wallpaper dir from ~/.config/shelljar/config.kdl (`wallpaper-dir "…";`)
// and scans it once; apply() sets the wallpaper through the awww daemon.
Item {
  id: root

  property var wallpapers: []
  property string current: ""
  readonly property string fallbackDir: (Quickshell.env("HOME") || "/home/user") + "/resjar/wall-jar/wall-bin"

  function dirFromConfig(text) {
    const m = (text || "").match(/wallpaper-dir\s*"([^"]+)"\s*;/)
    return m ? m[1] : ""
  }

  function scan() {
    const dir = root._dir
    listProc.exec(["sh", "-c",
      "find \"" + dir + "\" -maxdepth 1 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \\) | sort"])
  }

  function apply(path) {
    root.current = path
    Quickshell.execDetached(["awww", "img", path, "--transition-type", "fade", "--transition-duration", "1"])
  }

  function applyByIndex(index) {
    if (index >= 0 && index < root.wallpapers.length) root.apply(root.wallpapers[index])
  }

  // dir resolved from config.kdl (fallback: default dir)
  property string _dir: fallbackDir

  FileView {
    id: confFile
    path: (Quickshell.env("HOME") || "/home/user") + "/.config/shelljar/config.kdl"
    printErrors: false
    onLoaded: {
      const d = root.dirFromConfig(confFile.text())
      if (d !== "") { root._dir = d }
    }
    onLoadFailed: { root._dir = root.fallbackDir }
  }

  Process {
    id: listProc
    stdout: StdioCollector {
      onStreamFinished: {
        const out = (text || "").split("\n").map(s => s.trim()).filter(s => s !== "")
        root.wallpapers = out
      }
    }
  }

  Component.onCompleted: {
    confFile.reload()
    root.scan()
  }
}