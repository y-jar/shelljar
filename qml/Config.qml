/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Config
 *
 *   The single place where the shell keeps its palette, its sizing, and its
 *   tuning knobs. Every widget reads from here so the whole look and feel can
 *   be changed from one file. ColorService rewrites the mutable palette from
 *   the live wallpaper while the fixed functional colors stay unchanged.
 ***/
pragma Singleton
import QtQuick

Item {

  // ---- palette (mutable: ColorService re-derives these from the wallpaper) ----
  property color bg: "#1e1e2e"
  property color bgAlt: "#181825"
  property color surface: "#313244"
  property color surfaceAlt: "#45475a"
  property color text: "#cdd6f4"
  property color subtext: "#a6adc8"
  property color accent: "#5F7CB8"
  // functional / fixed accents
  readonly property color red: "#f38ba8"
  readonly property color green: "#a6e3a1"
  readonly property color yellow: "#f9e2af"
  readonly property color blue: "#89b4fa"
  readonly property color white: "#ffffff"
  readonly property color scrim: "#00000060"
  readonly property color scrimHeavy: "#99000000"
  readonly property color knobColor: "#ffffff"

  // ---- typography ----
  readonly property string fontFamily: "Monocraft"

  // shown in the right island when a machine has no battery
  readonly property string desktopTag: "Desktop"

  // ---- theming / scale ----
  readonly property real uiScale: 0.85

  // ---- island (strip / dock) ----
  readonly property real dockWidthRatio: 0.2 // dock/strip width as fraction of screen width
  readonly property real minDockWidth: Math.round(180 * uiScale) // docked width floor
  readonly property real stripHeight: Math.round(6 * uiScale)  // collapsed strip height
  readonly property real dockHeight: Math.round(112 * uiScale) // expanded dock height
  readonly property real cornerRadius: 12
  readonly property real spacing: 8

  // ---- shared pill / widget sizing ----
  readonly property real pillWidth: Math.round(64 * uiScale)
  readonly property real pillHeight: Math.round(26 * uiScale)
  readonly property real iconButtonSize: Math.round(30 * uiScale)
  readonly property int eventBadgeSize: 12

  // ---- popup geometry ----
  readonly property int launcherWidth: Math.round(720 * uiScale)
  readonly property int launcherHeight: Math.round(540 * uiScale)
  readonly property int controlCenterWidth: Math.round(330 * uiScale)
  readonly property int controlCenterHeight: Math.round(250 * uiScale)
  readonly property int popupWidth: Math.round(300 * uiScale)
  readonly property int networkPanelWidth: Math.round(380 * uiScale)
  readonly property int notificationsWidth: Math.round(330 * uiScale)
  readonly property int notificationsHeight: Math.round(360 * uiScale)
  readonly property int osdWidth: 260
  readonly property int osdHeight: 64
  readonly property int toastWidth: 360
  readonly property int toastHeight: 348

  // ---- system thresholds ----
  readonly property int batteryLow: 20
  readonly property int batteryCritical: 10
  readonly property real brightnessEpsilon: 0.001

  // ---- scroll steps ----
  readonly property real volStep: 0.05
  readonly property real volStepFine: 0.02
  readonly property real brightnessStep: 0.05

  // ---- session power menu ----
  readonly property real sessionButtonSize: Math.round(190 * uiScale)
  readonly property int sessionCountdownMs: 3000
  readonly property int sessionColumns: 3
  readonly property int sessionTickMs: 250

  // ---- timing ----
  readonly property int toastMs: 6000
  readonly property int osdShowMs: 2000
  readonly property int osdHoverMs: 1200
  readonly property int brightnessPollMs: 2500
  readonly property int statsCpuMs: 1000
  readonly property int statsNetMs: 3000
  readonly property int statsMemMs: 5000
  readonly property int statsDiskMs: 30000

  // ---- soft hairline borders ----
  readonly property color borderSoft: Qt.rgba(1, 1, 1, 0.06)
  readonly property color borderMid: Qt.rgba(1, 1, 1, 0.08)
  readonly property color borderStrong: Qt.rgba(1, 1, 1, 0.10)

  // ---- font sizes (scaled) ----
  readonly property int fsTiny: Math.round(9 * uiScale)
  readonly property int fsSmall: Math.round(11 * uiScale)
  readonly property int fsMedium: Math.round(13 * uiScale)
  readonly property int fsLarge: Math.round(18 * uiScale)
}