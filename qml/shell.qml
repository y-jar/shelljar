//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.components

// ---- shelljar entry ----
// Hosts the shared notification daemon + toasts + IPC, and creates one
// per-screen ShellScreen window (caelestia-style multi-monitor).
Item {
  id: root

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

  // one full-screen shell per monitor
  Repeater {
    id: screens
    model: Quickshell.screens
    delegate: ShellScreen {
      required property var modelData
      screen: modelData
      notificationServer: notiServer
      toastsModel: toasts
    }
  }

  // IPC (target "shelljar"). Toggles operate on the first screen for now.
  IpcHandler {
    target: "shelljar"

    function first() { return screens.itemAt(0) }

    function close(): void { const s = screens.itemAt(0); if (s) s.closeAll() }

    function toggleLauncher(): void { const s = screens.itemAt(0); if (s) s.toggleLauncher() }

    function toggleControlCenter(): void { const s = screens.itemAt(0); if (s) s.toggleControlCenter() }

    function toggleSession(): void { const s = screens.itemAt(0); if (s) s.toggleSession() }
  }
}