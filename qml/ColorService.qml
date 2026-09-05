/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   ColorService
 *
 *   Derives the shell palette from the live wallpaper. It reads the color
 *   scheme from the config file and, unless the scheme is off, pulls the
 *   dominant colors out of the current wallpaper with a color quantizer and
 *   rewrites the mutable palette in Config. A scheme of off simply keeps the
 *   fixed stock colors.
 ***/
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property string scheme: "tonal-spot"
  property color _seed: Config.accent

  readonly property string configPath: (Quickshell.env("HOME") || "/home/user") + "/.config/shelljar/config.kdl"

  function readConfig(text) {
    const m = (text || "").match(/color-scheme\s*"([^"]+)"\s*;/)
    root.scheme = m ? m[1] : "tonal-spot"
    if (root.scheme !== "off") root.start()
  }

  function reload() { confFile.reload() }

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
    // Vivid, mid-lightness color makes each wallpaper's theme distinct. Scan the
    // whole palette for the most saturated hue (avoid pure black/white edges).
    let best = null
    let bestSat = 0
    for (const c of colors) {
      const hsl = root.rgbToHsl(c)
      if (hsl.l > 0.12 && hsl.l < 0.9 && hsl.s > bestSat) {
        bestSat = hsl.s
        best = c
      }
    }
    return best || colors[0] || root._seed
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
    path: root.configPath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.readConfig(confFile.text())
    onLoadFailed: { root.scheme = "tonal-spot"; root.start() }
  }

  // wallpaper changed -> re-extract colors
  Connections {
    target: WallpaperService
    function onCurrentChanged() {
      if (root.scheme !== "off") root.start()
    }
  }
}