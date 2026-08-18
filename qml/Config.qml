pragma Singleton
import QtQuick

// shelljar central config: palette, sizing, tuning knobs.
// Tweak here first; everything else reads these values.
Item {

  // ---- palette (dark Catppuccin-ish, matches niri theme) ----
  readonly property color bg: "#1e1e2e"
  readonly property color bgAlt: "#181825"
  readonly property color surface: "#313244"
  readonly property color surfaceAlt: "#45475a"
  readonly property color text: "#cdd6f4"
  readonly property color subtext: "#a6adc8"
  readonly property color accent: "#5F7CB8"
  readonly property color red: "#f38ba8"
  readonly property color green: "#a6e3a1"
  readonly property color yellow: "#f9e2af"
  readonly property color blue: "#89b4fa"

  // ---- theming / scale ----
  readonly property real uiScale: 0.85

  // ---- island (strip / dock) ----
  readonly property real dockWidthRatio: 0.2 // dock/strip width as fraction of screen width
  readonly property real minDockWidth: Math.round(180 * uiScale) // docked width floor
  readonly property real stripHeight: Math.round(6 * uiScale)  // collapsed strip height
  readonly property real dockHeight: Math.round(112 * uiScale) // expanded dock height
  readonly property real cornerRadius: 12
  readonly property real spacing: 8

  // ---- popup geometry ----
  readonly property int launcherWidth: Math.round(660 * uiScale)
  readonly property int launcherHeight: Math.round(480 * uiScale)
  readonly property int controlCenterWidth: Math.round(330 * uiScale)

  // ---- session power menu ----
  readonly property real sessionButtonSize: Math.round(190 * uiScale)
  readonly property int sessionCountdownMs: 3000
  readonly property int sessionColumns: 3

  // ---- font sizes (scaled) ----
  readonly property int fsTiny: Math.round(9 * uiScale)
  readonly property int fsSmall: Math.round(11 * uiScale)
  readonly property int fsMedium: Math.round(13 * uiScale)
  readonly property int fsLarge: Math.round(18 * uiScale)

  // ---- behavior ----
  readonly property int statsIntervalMs: 2000

  // ---- commands (must be on PATH; the package wrapper adds libexec) ----
  readonly property string statsCmd: "shjstats"
  readonly property string wallpaperCmd: "shjwall"
}