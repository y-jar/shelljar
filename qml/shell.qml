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

  // IPC (target "shelljar"). Toggles operate on the first screen for now.
  IpcHandler {
    target: "shelljar"

    function first() { return screens.instances && screens.instances.length ? screens.instances[0] : null }

    function close() { const s = first(); if (s) s.closeAll() }

    function toggleLauncher() { const s = first(); if (s) s.toggleLauncher() }

    function toggleControlCenter() { const s = first(); if (s) s.toggleControlCenter() }

    function toggleSession() { const s = first(); if (s) s.toggleSession() }

    function wallpaperNext() { const s = first(); if (s) s.wallpaperCycle("next") }
    function wallpaperPrev() { const s = first(); if (s) s.wallpaperCycle("prev") }
  }
}