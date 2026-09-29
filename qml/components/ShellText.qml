/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   ShellText
 *
 *   The base labeled text element for the whole shell. It applies the configured
 *   shell font so labels stay consistent, and offers a `variant` shorthand for
 *   the shared text ramp (bright/text/dim/faint/accent). Setting `color`
 *   directly still works and wins over the variant, so old callers are
 *   untouched. It lives in the components module because a root component that
 *   inherits from QtQuick.Text would recurse inside quickshell.
 ***/
import ".."
import QtQuick

Text {
  id: root

  font.family: Config.fontFamily

  // "" keeps the plain Config.text default; pick a ramp step for free
  property string variant: ""

  function colorFor(v) {
    switch (v) {
    case "bright": return Config.textBright
    case "dim": return Config.dim
    case "faint": return Config.faint
    case "accent": return Config.accent
    case "subtext": return Config.subtext
    default: return Config.text
    }
  }

  color: root.colorFor(root.variant)
}
