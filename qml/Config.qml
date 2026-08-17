import QtQuick

// shelljar central config: palette, sizing, tuning knobs.
// Tweak here first; everything else reads these values.
Item {
  id: config

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

  // ---- island geometry ----
  readonly property real stripHeight: 4       // hovers strip reserved at top center when hidden
  readonly property real islandHeight: 48     // expanded island thickness
  readonly property real cornerRadius: 12
  readonly property real spacing: 8

  // ---- popup geometry ----
  readonly property int launcherWidth: 720
  readonly property int launcherHeight: 520
  readonly property int controlCenterWidth: 360

  // ---- behavior ----
  readonly property int statsIntervalMs: 2000

  // ---- commands (must be on PATH; the package wrapper adds libexec) ----
  readonly property string statsCmd: "shjstats"
  readonly property string wallpaperCmd: "shjwall"
}