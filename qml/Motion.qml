/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Motion
 *
 *   One place for every duration and easing curve the shell animates with.
 *   Components read Motion.fast / Motion.standard / Motion.morph instead of
 *   hardcoding milliseconds, so the whole shell can be slowed, sped up or
 *   re-curved from one file and everything stays in step.
 ***/
pragma Singleton
import QtQuick
import Quickshell

Item {
  id: root

  // Every duration is scaled by this. Lower it (e.g. from a config flag) to
  // calm the shell down; 1 is the tuned default.
  readonly property real mult: 1

  // ---- durations (ms) ----
  readonly property int fast: Math.round(140 * mult) // hover / state feedback
  readonly property int glide: Math.round(220 * mult) // small reveal / popout
  readonly property int standard: Math.round(300 * mult) // resize / open
  readonly property int morph: Math.round(420 * mult) // large surface morph

  // ---- easing types (Easing.<type>) ----
  readonly property int easeStandard: Easing.OutCubic
  readonly property int easeEmphasized: Easing.OutQuart
  readonly property int easeDecel: Easing.OutCubic
  readonly property int easeAccel: Easing.InCubic
  readonly property int easeBack: Easing.OutBack

  // "Liquid" curve, cubic-bezier(0.16, 1, 0.3, 1): front-loaded with a long
  // visible settle. Use with easing.type = Motion.easeMorph and
  // easing.bezierCurve = Motion.morphCurve.
  readonly property int easeMorph: Easing.BezierSpline
  readonly property var morphCurve: [0.16, 1.0, 0.3, 1.0, 1.0, 1.0]
}
