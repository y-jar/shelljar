/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   shell
 *
 *   The invisible root window of the whole shell. It owns the shared
 *   notification daemon, the toast model and the ipc handler, and it creates
 *   one full screen PerScreen window per monitor so every display gets the same
 *   islands, bar and popouts.
 ***/
//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.components

FloatingWindow {
  id: root

  visible: false      // this window never maps; only the per-screen windows show
  color: "transparent"

  // notification daemon (implements org.freedesktop.Notifications), shared
  NotificationServer {
    id: notiServer
    onNotification: n => {
      n.tracked = true // keep in history for the control center
      toasts.insert(0, {
        appName: n.appName,
        summary: n.summary,
        body: n.body,
      })
      while (toasts.count > 4) toasts.remove(toasts.count - 1)
    }
  }

  ListModel { id: toasts }

  // activate the singleton so it reads config + re-themes on wallpaper change
  Component.onCompleted: ColorService.reload()

  // one full-screen shell per monitor (Variants so window delegates are allowed)
  Variants {
    id: screens
    model: Quickshell.screens
    delegate: Component {
      PerScreen {
        screen: modelData
        notificationServer: notiServer
        toastsModel: toasts
      }
    }
  }

  // IPC (target "shelljar"). Toggles open on the monitor the user is focused on,
  // or on the monitor passed as a string arg (e.g. mango sends the cursor monitor
  // so the launcher opens where the mouse is). Args are typed `string` because
  // quickshell only registers handler functions with explicit IPC types.
  IpcHandler {
    target: "shelljar"

    // a screen by name, or null
    function screenByName(name: string) {
      for (const s of Quickshell.screens) { if (s && s.name === name) return s }
      return null
    }

    // the monitor of the currently focused window (like fuzzel)
    function focusedScreen() {
      try {
        const t = typeof ToplevelManager !== "undefined" ? ToplevelManager.activeToplevel : null
        if (t && t.screens && t.screens.length > 0) {
          const n = t.screens[0].name
          for (const s of Quickshell.screens) { if (s && s.name === n) return s }
        }
      } catch (e) {}
      return null
    }

    // the PerScreen instance for monitor (if given), else the focused one,
    // falling back to the first one
    function target(monitor: string) {
      const scr = (monitor && screenByName(monitor)) || focusedScreen()
      for (const inst of screens.instances) { if (inst.modelData === scr) return inst }
      return screens.instances && screens.instances.length ? screens.instances[0] : null
    }

    function close() { const s = target(""); if (s) s.closeAll() }

    function toggleLauncher(monitor: string) { const s = target(monitor); if (s) s.toggleLauncher() }

    function toggleControlCenter(monitor: string) { const s = target(monitor); if (s) s.toggleControlCenter() }

    function toggleSession(monitor: string) { const s = target(monitor); if (s) s.toggleSession() }

    function wallpaperNext(monitor: string) { const s = target(monitor); if (s) s.wallpaperCycle("next") }
    function wallpaperPrev(monitor: string) { const s = target(monitor); if (s) s.wallpaperCycle("prev") }

    // uiScale: set (e.g. "1.1"), step ("+"/"inc"/"up"/"-"/"dec"/"down"), or report.
    function uiScale(arg: string) {
      const cur = ColorService && ColorService.setUiScale ? Config.userScale : 0.85
      let v = cur
      const s = (arg || "").trim().toLowerCase()
      const n = parseFloat(s)
      if (isFinite(n)) v = n
      else if (s === "+" || s === "inc" || s === "up") v = cur + 0.05
      else if (s === "-" || s === "dec" || s === "down") v = cur - 0.05
      ColorService.setUiScale(v)
    }
  }
}