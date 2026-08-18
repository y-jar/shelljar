pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// ---- wallpaper list + apply (caelestia-style service, applies via awww) ----
// Reads settings from ~/.config/shelljar/config.kdl:
//   wallpaper-dir "…";          # wallpaper folder
//   wallpaper-thumb-width 150;  # carousel thumbnail width
//   wallpaper-settle-ms 800;    # ms of no-scroll before applying
// Scans the dir once; apply() sets the wallpaper through the awww daemon.
Item {
  id: root

  property var wallpapers: []
  property string current: ""
  property int thumbWidth: 150
  property int settleMs: 800

  readonly property string home: Quickshell.env("HOME") || "/home/user"
  readonly property string fallbackDir: home + "/resjar/wall-jar/wall-bin"

  function expand(path) {
    if (!path) return path
    if (path.startsWith("~/")) return home + path.substring(1)
    return path.replace(/^\$HOME/, home).replace(/^\$\{HOME\}/, home)
  }

  function parseConfig(text) {
    const t = text || ""
    const dir = t.match(/wallpaper-dir\s*"([^"]+)"\s*;/)
    if (dir) root._dir = root.expand(dir[1])
    const tw = t.match(/wallpaper-thumb-width\s*(\d+)\s*;/)
    if (tw) root.thumbWidth = parseInt(tw[1]) || 150
    const ms = t.match(/wallpaper-settle-ms\s*(\d+)\s*;/)
    if (ms) root.settleMs = parseInt(ms[1]) || 800
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

  property string _dir: fallbackDir

  FileView {
    id: confFile
    path: (Quickshell.env("HOME") || "/home/user") + "/.config/shelljar/config.kdl"
    printErrors: false
    onLoaded: root.parseConfig(confFile.text())
    onLoadFailed: root._dir = root.fallbackDir
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