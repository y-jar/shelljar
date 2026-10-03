/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Clipboard
 *
 *   The one place the shell writes to the Wayland clipboard. Notifications copy
 *   their text through here (toast middle-click, the copy keybind and history
 *   cards), piping straight into wl-copy (wl-clipboard) so images/odd bytes stay
 *   out of the equation and the text is passed as an argument, never interpolated
 *   into a shell string.
 ***/
pragma Singleton
import QtQuick
import Quickshell

Item {
  id: root

  function copy(text) {
    if (!text || text === "") return
    Quickshell.execDetached([
      "sh", "-c",
      "printf '%s' \"$1\" | wl-copy",
      "shelljar-clip", text,
    ])
  }
}
