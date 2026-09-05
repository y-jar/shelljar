# shelljar

```
╃
 .▀▀█▀▀ .
   :▓:.
. ▀▀ : ╃
```

> **A cozy Quickshell desktop shell for niri** a little jar of widgets that
> lives at the top of your screen, hides when you don't need it, and pops out
> bars, a launcher, a calendar and a control center at the click of a mouse or key.

## 💛 author's note
> I made this shell in a jar for myself and a fun little project to work on, as wallpaper management was an issue and then I thought "But I could add a bar.. I could add a launcher"... etc. after using it I really liked the idea and wanted to share it with others.

## ✨ what is shelljar?
> It is a simple and albet kinda weird looking and funky looking shell made with quickshell. 

<!-- main description lives here -->

> **a tiny heads up:** shelljar is mostly built and tuned against **NixOS**.
> if you run it somewhere else and something acts up, that very well may be my
> NixOS assumptions showing. you're welcome to open an issue and I'll do my best
> to look into it 💚

---

## 🚀 surfaces & features

| surface | what it does |
|---|---|
| **the bar (top-center)** | auto-hides to a thin strip; right-click to open two rows. row 1: profile ➞ clock ➞ notifications & volume. row 2: wallpaper + system stats. |
| **islands (left/right)** | left: network ✱ power ✱ tray ✱ media. right: battery ✱ brightness. right-click to expand. |
| **launcher** | grid of apps, type to search, arrows to move, enter to launch, right-click to pin. `Mod+D`. |
| **control center** | your face row, audio slider, bluetooth toggle, power-menu button. `Mod+S`. |
| **volume / brightness / battery panels** | little pop-outs with a big slider, % and a ✕ to close. |
| **notifications** | top-right toasts + a history panel with a **Clear** button and action buttons. |
| **calendar** | click the clock — a month grid pops out. |
| **power menu** | full-screen switch: power/reboot (countdown ring), logout, suspend, lock. `Mod+P`. |
| **wallpapers** | scroll the bar button for a carousel, click for a grid, right-click for the full-screen picker. `Mod+W` next / `Mod+O` prev. |

## ⌨️ controls you'll actually remember

| keys | action |
|---|---|
| `Mod+D` | launcher |
| `Mod+P` | power menu |
| `Mod+S` | control center |
| `Mod+W` / `Mod+O` | wallpaper next / previous |
| `Esc` | close whatever's open |
> rebind these in your compositor / `bindings.kdl` — shelljar just listens for IPC.

## 🎨 theming
shelljar colors itself from the live wallpaper. the user config lives at
`~/.config/shelljar/config.kdl`:

```kdl
wallpaper-dir "$HOME/resjar/wall-jar/wall-bin";   // where your walls live
wallpaper-thumb-width 300;                        // carousel thumbnail width
wallpaper-settle-ms 800;                          // ms of no-scroll before applying
color-scheme "tonal-spot";                        // "tonal-spot" or "off"
```

## 🗺️ where things live

| what | path |
|---|---|
| user config | `~/.config/shelljar/config.kdl` |
| pinned (favourite) apps | `~/.cache/shelljar/favorites` |
| live wallpaper marker | `~/.cache/shelljar/current-wall` |
| quickshell logs | `/run/user/<uid>/quickshell/by-id/<shell-id>/log.qslog` |
| branding (icons / fonts / profile pic) | `resources/` (drop files, reference from `qml/Config.qml`) |
| shell font | `Config.fontFamily` (default `Monocraft`) |

## 🔌 ipc (for hotkeys / scripts)

```sh
shelljar ipc call shelljar toggleLauncher     # or: shjctl toggleLauncher
shelljar ipc call shelljar toggleControlCenter
shelljar ipc call shelljar toggleSession
shelljar ipc call shelljar close
shelljar ipc call shelljar wallpaperCycle next
```

## 🛠️ develop

```sh
nix develop          # tools + env
quickshell -p qml    # hot iterate from source
nix build .#shelljar # -> result/bin/shelljar
```

## 📁 layout

```
qml/                   shell config: Config.qml + surfaces + widgets + services
qml/components/        reusable bits (Slider, canvas icons, ShellText)
resources/             branding placeholders
```

## 🙃 nerdy little things I'm proud of
> The Large wallpaper manager was something I spent a lot of time on and I found it to be a great way to manage my wallpapers (kinda addicted to using it).

## 🤖 ai disclaimer
This README (and a decent chunk of the code) was whipped up with the help of a
code assistant between cups of coffee. it tries its best, proofread with love
(and maybe a little more coffee), and if something looks dramatic it probably
shipped anyway. you have been warned, but I hope this jar makes you smile.

> NOTE: I have sense layed off of the coffee. 

## 📜 license
> Free Steal and take credit. 

Always Learning,
Jar / Park
