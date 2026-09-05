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

  // IPC (target "shelljar"). Toggles open on the monitor the user is focused on.
  IpcHandler {
    target: "shelljar"

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

    // the PerScreen instance for that screen, falling back to the first one
    function target() {
      const scr = focusedScreen()
      for (const inst of screens.instances) { if (inst.modelData === scr) return inst }
      return screens.instances && screens.instances.length ? screens.instances[0] : null
    }

    function close() { const s = target(); if (s) s.closeAll() }

    function toggleLauncher() { const s = target(); if (s) s.toggleLauncher() }

    function toggleControlCenter() { const s = target(); if (s) s.toggleControlCenter() }

    function toggleSession() { const s = target(); if (s) s.toggleSession() }

    function wallpaperNext() { const s = target(); if (s) s.wallpaperCycle("next") }
    function wallpaperPrev() { const s = target(); if (s) s.wallpaperCycle("prev") }
  }
}