//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.components

// ---- shelljar entry ----
// The config root is an invisible FloatingWindow (not an Item) so quickshell
// does NOT wrap it in a white ProxyFloatingWindow. It hosts the shared
// notification daemon + toasts + IPC, and creates one full-screen PerScreen
// window per monitor (caelestia-style multi-monitor).
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

    function close(): void { const s = first(); if (s) s.closeAll() }

    function toggleLauncher(): void { const s = first(); if (s) s.toggleLauncher() }

    function toggleControlCenter(): void { const s = first(); if (s) s.toggleControlCenter() }

    function toggleSession(): void { const s = first(); if (s) s.toggleSession() }
  }
}