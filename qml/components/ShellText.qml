/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   ShellText
 *
 *   The base labeled text element for the whole shell.
 *   It applies the configured shell font to every piece of text so labels stay
 *   consistent. It lives in the components module because a root component
 *   that inherits from QtQuick.Text would recurse inside quickshell.
 ***/
import ".."
import QtQuick

Text {
  font.family: Config.fontFamily
}