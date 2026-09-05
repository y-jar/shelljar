# shelljar

```
╃
 .▀▀█▀▀ .
   :▓.:
. ▀▀ : ╃
```

My custom **Quickshell** desktop shell for niri (and other layer-shell compositors).
An auto-hiding *bar* at the top-center of the screen with two rows of widgets:
profile/power, clock, notifications, volume; below that walls, tray, system
stats, battery, brightness, media — plus a grid launcher and a control center.
No noctalia needed.

## Surfaces

| Surface | Description |
|---|---|
| **Bar** (top-center `PanelWindow`) | Auto-hides to a thin hover strip, expands on right-click. Row 1: profile hamburger on the left, centered clock, notifications + volume on the right. Row 2: wallpaper + system stats. The side islands hold network/power/tray/media (left) and battery/brightness (right). |
| **Launcher** | Grid of installed apps with search. toggled via `shjctl toggleLauncher` (bound to `Mod+D` in niri). |
| **Control center** | Profile frame that opens just below the bar: user identity, audio, power/session menu trigger. `shjctl toggleControlCenter`. |
| **Volume panel** | Small frame under the volume pill with a large slider, mute and %. |
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
qml/        shell configuration (Config.qml + surfaces + widgets + services),
            no external scripts; system stats (SystemStat.qml) and wallpapers
            (WallpaperService.qml) are self contained
qml/components/  reusable primitives (Slider, the canvas network icons, ShellText)
resources/  branding placeholder (icons / fonts)
PLAN.md     working cleanup checklist (emptied when finished)
```
