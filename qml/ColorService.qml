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

    // ui-scale N baseline from the (declarative) config.kdl.
    const sm = (text || "").match(/ui-scale\s+([0-9.]+)\s*;/)
    if (sm) {
      const v = parseFloat(sm[1])
      if (isFinite(v) && v > 0) Config.userScale = v
    }
    // runtime override handled by runtimeScaleFile (auto-loads + wins if present)
  }

  // Runtime-adjustable scale, persisted to a writable cache file so it survives
  // restarts without fighting home-manager's read-only config.kdl symlink.
  readonly property string runtimeScalePath: (Quickshell.env("HOME") || "/home/user") + "/.cache/shelljar/ui-scale"
  FileView {
    id: runtimeScaleFile
    path: root.runtimeScalePath
    watchChanges: true
    printErrors: false
    onLoaded: {
      const v = parseFloat((text() || "").trim())
      if (isFinite(v) && v > 0) Config.userScale = v
    }
  }

  function setUiScale(v) {
    Config.userScale = Math.max(0.5, Math.min(2.0, v))
    setScaleProc.exec([
      "sh", "-c",
      "mkdir -p \"$HOME/.cache/shelljar\"; printf '%s\\n' \"" + Config.userScale.toFixed(2) + "\" > \"$HOME/.cache/shelljar/ui-scale\""
    ])
    runtimeScaleFile.reload()
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
    const hue = h / 360
    // accent keeps the seed's punch; surfaces stay low-chroma so the wallpaper
    // does the shouting and the shell stays a calm frame around it
    const accS = Math.max(0.35, Math.min(0.75, hsl.s * 0.7 + 0.25))
    const surfS = Math.max(0.16, Math.min(0.50, hsl.s * 0.55 + 0.12))

    Config.accent = Qt.hsla(hue, accS, 0.60, 1)
    Config.accentContainer = Qt.hsla(hue, accS * 0.8, 0.30, 1)
    Config.accentInk = Qt.hsla(hue, 0.08, 0.98, 1)

    // surface ramp: deepest bg -> nearest card
    Config.bg = Qt.hsla(hue, surfS * 0.55, 0.09, 1)
    Config.bgAlt = Qt.hsla(hue, surfS * 0.50, 0.065, 1)
    Config.surfaceLow = Qt.hsla(hue, surfS * 0.60, 0.12, 1)
    Config.surfaceMid = Qt.hsla(hue, surfS * 0.60, 0.16, 1)
    Config.surfaceHigh = Qt.hsla(hue, surfS * 0.60, 0.23, 1)
    Config.surface = Qt.hsla(hue, surfS * 0.70, 0.16, 1)
    Config.surfaceAlt = Qt.hsla(hue, surfS * 0.70, 0.24, 1)

    // text ramp
    Config.textBright = Qt.hsla(hue, 0.03, 0.99, 1)
    Config.text = Qt.hsla(hue, 0.05, 0.92, 1)
    Config.subtext = Qt.hsla(hue, 0.06, 0.70, 1)
    Config.dim = Qt.hsla(hue, 0.06, 0.66, 1)
    Config.faint = Qt.hsla(hue, 0.07, 0.50, 1)

    // outlines: a light hairline, never a hard white
    Config.outline = Qt.hsla(hue, 0.20, 0.80, 0.14)
    Config.outlineSoft = Qt.hsla(hue, 0.20, 0.80, 0.07)
    Config.outlineStrong = Qt.hsla(hue, 0.22, 0.85, 0.22)
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

  // writes, e.g. the ui-scale line back into config.kdl
  Process {
    id: setScaleProc
  }

  // wallpaper changed -> re-extract colors
  Connections {
    target: WallpaperService
    function onCurrentChanged() {
      if (root.scheme !== "off") root.start()
    }
  }
}
