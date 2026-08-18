# shelljar

My custom **Quickshell** desktop shell for niri (and other layer-shell compositors).
An auto-hiding *island* at the top-center of the screen with clock, stats, tray,
audio, wallpapers, a grid launcher, and a control center — no noctalia needed.

## Surfaces

| Surface | Description |
|---|---|
| **Island** (top-center `PanelWindow`) | Auto-hides to a thin hover strip, reserves its space. Clock + wallpaper scroller in the middle, tray + stats on the left, user button on the right. |
| **Launcher** | Grid of installed apps with search. toggled via `shjctl toggleLauncher` (bound to `Mod+D` in niri). |
| **Control center** | User menu: volume/mute, notification history, power/session buttons. `shjctl toggleControlCenter`. |
| **Toasts** | Top-right notification popups (shell hosts an `org.freedesktop.Notifications` daemon). |
| **Power menu** | Full-screen session menu (Power Off, Reboot, Logout, Suspend, Lock); Power Off/Reboot use a countdown ring to confirm. `shjctl toggleSession` / control-center button. |

## IPC

```
shelljar ipc call shelljar toggleLauncher
shelljar ipc call shelljar toggleControlCenter
shelljar ipc call shelljar toggleSession
shelljar ipc call shelljar close
shelljar ipc call shelljar wallpaperCycle next
```

## Develop

```
nix develop
quickshell -p qml      # hot-iterate from the source tree
```

Build the package:

```
nix build .#shelljar   # result/bin/shelljar
```

## Layout

```
qml/        shell configuration (Config.qml + surfaces + widgets)
qml/        shell configuration (Config.qml + surfaces + widgets) — no external scripts;
            system stats (SystemStat.qml) and wallpapers (WallpaperService.qml) are self-contained
resources/  icons / branding
```