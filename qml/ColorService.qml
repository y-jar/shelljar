pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// ---- wallpaper-derived theme colors (noctalia-style, self-contained) ----
// Reads `color-scheme "tonal-spot";` from ~/.config/shelljar/config.kdl
// ("off" keeps the fixed palette). When a wallpaper is applied, extracts its
// dominant colors via Quickshell.ColorQuantizer and re-derives Config's palette.
Item {
  id: root

  property string scheme: "tonal-spot"
  property color _seed: "#5F7CB8"

  function readConfig(text) {
    const m = (text || "").match(/color-scheme\s*"([^"]+)"\s*;/)
    root.scheme = m ? m[1] : "tonal-spot"
    if (root.scheme !== "off") root.start()
  }

  function reload(): void { confFile.reload() }

  function start() {
    if (!WallpaperService.current) return
    quantizer.source = Qt.resolvedUrl(WallpaperService.current)
  }

  // ---- rgb <-> hsl ----
  function rgbToHsl(c) {
    const r = c.r, g = c.g, b = c.b
    const max = Math.max(r, g, b), min = Math.min(r, g, b)
    let h = 0, s = 0
    const l = (max + min) / 2
    const d = max - min
    if (d !== 0) {
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
      if (max === r) h = ((g - b) / d + (g < b ? 6 : 0))
      else if (max === g) h = ((b - r) / d + 2)
      else h = ((r - g) / d + 4)
      h /= 6
    }
    return { h: h, s: s, l: l }
  }

  function pickSeed(colors) {
    // prefer a saturated, mid-brightness color among the top few
    for (const c of colors.slice(0, 8)) {
      const hsl = root.rgbToHsl(c)
      if (hsl.s > 0.15 && hsl.l > 0.15 && hsl.l < 0.9) return c
    }
    return colors[0] || root._seed
  }

  function applyTonalSpot(seed) {
    const hsl = root.rgbToHsl(seed)
    const h = Math.round(hsl.h * 360)
    Config.accent = Qt.hsla(h / 360, Math.max(0.35, Math.min(0.75, hsl.s * 0.7 + 0.25)), 0.55, 1)
    Config.bg = Qt.hsla(h / 360, 0.30, 0.10, 1)
    Config.bgAlt = Qt.hsla(h / 360, 0.25, 0.08, 1)
    Config.surface = Qt.hsla(h / 360, 0.35, 0.16, 1)
    Config.surfaceAlt = Qt.hsla(h / 360, 0.35, 0.24, 1)
    Config.text = Qt.hsla(h / 360, 0.05, 0.92, 1)
    Config.subtext = Qt.hsla(h / 360, 0.05, 0.72, 1)
  }

  function buildPalette(colors) {
    if (root.scheme === "off" || !colors || colors.length === 0) return
    const seed = root.pickSeed(colors)
    root._seed = seed
    root.applyTonalSpot(seed)
  }

  // ---- color quantizer on the current wallpaper ----
  ColorQuantizer {
    id: quantizer
    depth: 6
    rescaleSize: 64
    onColorsChanged: root.buildPalette(colors)
  }

  // ---- config file ----
  FileView {
    id: confFile
    path: (Quickshell.env("HOME") || "/home/user") + "/.config/shelljar/config.kdl"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.readConfig(confFile.text())
    onLoadFailed: root.scheme = "tonal-spot"
  }

  // wallpaper changed -> re-extract colors
  Connections {
    target: WallpaperService
    function onCurrentChanged() {
      if (root.scheme !== "off") root.start()
    }
  }

  Component.onCompleted: {
    confFile.reload()
  }
}