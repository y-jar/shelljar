/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   PerScreen
 *
 *   One full screen window per monitor. It hosts that monitor's bar, its
 *   islands and the popups (launcher, control center, session menu, wallpaper
 *   pickers, panels and toast column). Heavy popups are created on demand with
 *   a Loader and destroyed again when closed, so a monitor only pays for what
 *   it is actually showing. Opening anything closes the rest through one shared
 *   closeAll so popups never stack on top of each other.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

PanelWindow {
  id: root

  required property var modelData
  screen: modelData // the screen Variants passes in

  // Screen scale: pick the primary/first screen's density ONCE so multi-monitor
  // windows don't fight over the shared Config.screenScale (the last one to init
  // previously shrank every window on a low-density screen). Clamped so it can
  // only enlarge for high-DPI panels, never shrink below ~1x. Fine-tuning is the
  // user slider (Config.userScale).
  Component.onCompleted: root.applyScreenScale()
  function applyScreenScale() {
    if (Config.screenScaleSet) return // stable: only set once
    const s = (Quickshell.screens && Quickshell.screens.length) ? Quickshell.screens[0] : root.screen
    if (s) {
      const d = s.logicalPixelDensity || s.devicePixelRatio * 96 || 96
      Config.screenScale = Math.max(1.0, Math.min(1.5, d / 96))
      Config.screenScaleSet = true
    }
  }

  readonly property string ns: screen ? "shelljar-" + screen.name : "shelljar"
  WlrLayershell.namespace: ns
  WlrLayershell.exclusionMode: ExclusionMode.Ignore // overlay: no reserved space
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: root.grabKeys
    ? WlrKeyboardFocus.Exclusive
    : (root.popupOpen || root.islandActive) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
  color: "transparent"

  anchors.top: true
  anchors.bottom: true
  anchors.left: true
  anchors.right: true

  // shared from shell.qml
  property var notificationServer: null
  property var toastsModel: null

  // ---- popup state: one flag per surface, each drives a Loader ----
  property bool launcherOpen: false
  property bool controlsOpen: false
  property bool sessionOpen: false
  property bool pickerOpen: false
  property bool scaleLayerOpen: false
  property bool volumeOpen: false
  property bool batteryOpen: false
  property bool brightnessOpen: false
  property bool networkOpen: false
  property bool calendarOpen: false
  property bool notificationsOpen: false
  property bool carouselOpen: false
  property bool gridOpen: false

  readonly property bool popupOpen: launcherOpen || controlsOpen || sessionOpen || pickerOpen || scaleLayerOpen
    || notificationsOpen || volumeOpen || batteryOpen || brightnessOpen || networkOpen || calendarOpen
    || carouselOpen || gridOpen
  readonly property bool barActive: bar.barOpen
  readonly property bool leftActive: leftIsland.open
  readonly property bool rightActive: rightIsland.open
  readonly property bool islandActive: barActive || leftActive || rightActive
  // key-driven overlays grab keyboard focus; mouse popups stay hands-off
  readonly property bool grabKeys: launcherOpen || pickerOpen || sessionOpen || scaleLayerOpen || (polkitDialog !== null && polkitDialog.active)

  // wallpaper carousel sizing (kept in sync with WallpaperCarousel's own math)
  readonly property real carouselThumbW: Math.round(WallpaperService.thumbWidth * Config.uiScale)
  readonly property real carouselThumbH: Math.round(carouselThumbW / 16 * 9)

  // clickthrough: full screen while a popup or any island is open, otherwise
  // only the three islands' rects pass clicks.
  mask: Region {
    x: (root.popupOpen || root.islandActive) ? 0 : bar.x
    y: (root.popupOpen || root.islandActive) ? 0 : bar.y
    width: (root.popupOpen || root.islandActive) ? root.width : bar.width
    height: (root.popupOpen || root.islandActive) ? root.height : bar.height

    Region {
      x: leftIsland.x
      y: leftIsland.y
      width: (!root.popupOpen && !root.islandActive) ? leftIsland.width : 0
      height: (!root.popupOpen && !root.islandActive) ? leftIsland.height : 0
    }
    Region {
      x: rightIsland.x
      y: rightIsland.y
      width: (!root.popupOpen && !root.islandActive) ? rightIsland.width : 0
      height: (!root.popupOpen && !root.islandActive) ? rightIsland.height : 0
    }
    Region {
      x: toasts.x
      y: toasts.y
      width: (!root.popupOpen && toasts.visible) ? toasts.width : 0
      height: (!root.popupOpen && toasts.visible) ? toasts.height : 0
    }
  }

  // dim scrim behind open popups
  Rectangle {
    id: scrim
    anchors.fill: parent
    color: Config.scrim
    visible: root.popupOpen
    opacity: root.popupOpen ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 120 } }
    MouseArea { anchors.fill: parent; onClicked: root.closeAll() }
  }

  // transparent click catcher: clicking away from the open islands closes them
  MouseArea {
    anchors.fill: parent
    visible: root.islandActive && !root.popupOpen
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: root.closeAll()
  }

  // ---- middle island (profile / centered clock / notifications + sound) ----
  Bar {
    id: bar
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    notificationServer: root.notificationServer
    onControlClicked: { root.closeAll(); root.controlsOpen = true }
    onNotificationsRequested: root.toggle("notificationsOpen")
    onWallpaperOpenRequested: dir => { root.closeAll(); root.carouselOpen = true; Qt.callLater(() => carouselLoader.item && carouselLoader.item.nudge(dir)) }
    onWallpaperGridRequested: { root.closeAll(); root.gridOpen = true }
    onWallpaperPickerRequested: root.openWallPicker()
    onOsdHoverRequested: { osd.showVolume(); osd.hover() }
    onOsdValueChanged: osd.showVolume()
    onVolumePanelRequested: root.toggle("volumeOpen")
    onClockClicked: root.toggle("calendarOpen")
  }

  // ---- left island (network / power / tray / media), top-left edge ----
  LeftIsland {
    id: leftIsland
    anchors.left: parent.left
    anchors.leftMargin: 8
    anchors.top: parent.top
    anchors.topMargin: 0
    onNetworkClicked: root.toggle("networkOpen")
    onPowerClicked: { root.closeAll(); root.sessionOpen = true }
  }

  // ---- right island (battery / brightness), top-right edge ----
  RightIsland {
    id: rightIsland
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.top: parent.top
    anchors.topMargin: 0
    onBatteryPanelRequested: { root.closeAll(); root.batteryOpen = true }
    onBrightnessPanelRequested: { root.closeAll(); root.brightnessOpen = true }
    onOsdBrightnessHoverRequested: { osd.showBrightness(BrightnessService.value); osd.hover() }
    onOsdBrightnessValueChanged: osd.showBrightness(BrightnessService.value)
  }

  // ---- volume/brightness OSD (top-right) ----
  Osd { id: osd }

  // ---- volume panel (pop-out, under the bar's volume pill) ----
  Loader {
    id: volumeLoader
    active: root.volumeOpen
    anchors.right: bar.right
    anchors.rightMargin: 8
    anchors.top: bar.bottom
    anchors.topMargin: 8
    width: Config.popupWidth
    height: Math.round(110 * Config.uiScale)
    sourceComponent: Component {
      VolumePanel {
        anchors.fill: parent
        open: root.volumeOpen
        onCloseRequested: root.volumeOpen = false
      }
    }
  }

  // ---- battery panel (pop-out, beside the right island) ----
  Loader {
    id: batteryLoader
    active: root.batteryOpen
    anchors.right: rightIsland.left
    anchors.rightMargin: 8
    anchors.top: rightIsland.top
    width: Config.popupWidth
    height: Math.round(300 * Config.uiScale)
    sourceComponent: Component {
      BatteryPanel {
        anchors.fill: parent
        open: root.batteryOpen
        onCloseRequested: root.batteryOpen = false
      }
    }
  }

  // ---- brightness panel (pop-out, beside the right island) ----
  Loader {
    id: brightnessLoader
    active: root.brightnessOpen
    anchors.right: rightIsland.left
    anchors.rightMargin: 8
    anchors.top: rightIsland.top
    anchors.topMargin: 44
    width: Config.popupWidth
    height: Math.round(90 * Config.uiScale)
    sourceComponent: Component {
      BrightnessPanel {
        anchors.fill: parent
        open: root.brightnessOpen
        onCloseRequested: root.brightnessOpen = false
      }
    }
  }

  // ---- network panel (pop-out, beside the left island) ----
  Loader {
    id: networkLoader
    active: root.networkOpen
    anchors.left: leftIsland.right
    anchors.leftMargin: 8
    anchors.top: leftIsland.top
    width: Config.networkPanelWidth
    height: Math.min(Math.round(520 * Config.uiScale), Math.round(root.height - 90))
    sourceComponent: Component {
      NetworkPanel {
        anchors.fill: parent
        open: root.networkOpen
        onCloseRequested: root.networkOpen = false
      }
    }
  }

  // ---- calendar panel (pop-out, under the clock) ----
  Loader {
    id: calendarLoader
    active: root.calendarOpen
    anchors.horizontalCenter: bar.horizontalCenter
    anchors.top: bar.bottom
    anchors.topMargin: 8
    width: Config.popupWidth
    height: Math.round(300 * Config.uiScale)
    sourceComponent: Component {
      CalendarPanel {
        anchors.fill: parent
        open: root.calendarOpen
        onCloseRequested: root.calendarOpen = false
      }
    }
  }

  // ---- notifications panel (pop-out) ----
  Loader {
    id: notificationsLoader
    active: root.notificationsOpen
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.top: bar.bottom
    anchors.topMargin: 8
    width: Config.notificationsWidth
    height: Config.notificationsHeight
    sourceComponent: Component {
      NotificationsPanel {
        anchors.fill: parent
        open: root.notificationsOpen
        notificationServer: root.notificationServer
        onCloseRequested: root.notificationsOpen = false
      }
    }
  }

  // ---- wallpaper preview carousel (pop-out) ----
  Loader {
    id: carouselLoader
    active: root.carouselOpen
    anchors.horizontalCenter: bar.horizontalCenter
    anchors.top: bar.bottom
    anchors.topMargin: 8
    width: 5 * (root.carouselThumbW + 8)
    height: root.carouselThumbH
    sourceComponent: Component {
      WallpaperCarousel {
        anchors.fill: parent
        open: root.carouselOpen
        onCloseRequested: root.carouselOpen = false
      }
    }
  }

  // ---- wallpaper picker grid (pop-out) ----
  Loader {
    id: gridLoader
    active: root.gridOpen
    anchors.horizontalCenter: bar.horizontalCenter
    anchors.top: bar.bottom
    anchors.topMargin: 8
    width: Math.min(Math.round(800 * Config.uiScale), Math.round(root.width * 0.5))
    height: Math.round(430 * Config.uiScale)
    sourceComponent: Component {
      WallpaperGrid {
        anchors.fill: parent
        open: root.gridOpen
        onCloseRequested: root.gridOpen = false
      }
    }
  }

  // ---- full-screen calm wallpaper picker (super+w / right-click) ----
  Loader {
    id: pickerLoader
    active: root.pickerOpen
    anchors.fill: parent
    sourceComponent: Component {
      WallpaperPicker {
        anchors.fill: parent
        open: root.pickerOpen
        onCloseRequested: root.pickerOpen = false
      }
    }
  }

  // ---- launcher (grid) ----
  Loader {
    id: launcherLoader
    active: root.launcherOpen
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: bar.bottom
    anchors.topMargin: 12
    width: Config.launcherWidth
    height: Config.launcherHeight
    sourceComponent: Component {
      Launcher {
        anchors.fill: parent
        open: root.launcherOpen
        onCloseRequested: root.launcherOpen = false
      }
    }
  }

  // ---- control center (profile frame) opens just below the bar ----
  Loader {
    id: controlsLoader
    active: root.controlsOpen
    anchors.left: bar.left
    anchors.leftMargin: 8
    anchors.top: bar.bottom
    anchors.topMargin: 12
    width: Config.controlCenterWidth
    height: Config.controlCenterHeight
    sourceComponent: Component {
      ControlCenter {
        anchors.fill: parent
        open: root.controlsOpen
        onOpenSession: {
          root.controlsOpen = false
          root.sessionOpen = true
        }
        onOpenScaleLayer: {
          root.closeAll()
          root.scaleLayerOpen = true
        }
      }
    }
  }

  // ---- full-screen UI scale calibrator (A/D or arrows, Enter saves) ----
  Loader {
    id: scaleLayerLoader
    active: root.scaleLayerOpen
    anchors.fill: parent
    sourceComponent: Component {
      UiScaleLayer {
        anchors.fill: parent
        open: root.scaleLayerOpen
        onCloseRequested: root.scaleLayerOpen = false
      }
    }
  }

  // ---- full-screen power menu ----
  Loader {
    id: sessionLoader
    active: root.sessionOpen
    anchors.fill: parent
    sourceComponent: Component {
      SessionMenu {
        anchors.fill: parent
        open: root.sessionOpen
        onCloseRequested: root.sessionOpen = false
      }
    }
  }

  // ---- privileged action authentication dialog ----
  // Kept always-instantiated: the agent must be listening for auth requests
  // even when no surface is open.
  Polkit {
    id: polkitDialog
    anchors.fill: parent
    enabled: true
  }

  // ---- toast notifications (top-right) ----
  ColumnLayout {
    id: toasts
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.top: bar.bottom
    anchors.topMargin: 12
    width: Config.toastWidth
    spacing: 6
    visible: root.toastsModel ? root.toastsModel.count > 0 : false

    Repeater {
      id: toastRepeater
      model: root.toastsModel

      delegate: Rectangle {
        required property var modelData
        required property int index
        Layout.fillWidth: true
        height: toastText.implicitHeight + 16
        radius: 10
        color: Config.bg
        border.color: Config.borderMid

        RowLayout {
          anchors.fill: parent
          anchors.margins: 10
          spacing: 8
          ShellText {
            text: "▣"
            color: Config.accent
            font.pixelSize: Config.fsMedium
          }
          ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            ShellText {
              text: modelData.appName || ""
              color: Config.accent
              font.pixelSize: Config.fsTiny
            }
            ShellText {
              id: toastText
              text: (modelData.summary || "") + (modelData.body ? "\n" + modelData.body : "")
              color: Config.text
              font.pixelSize: Config.fsSmall
              wrapMode: Text.WordWrap
              Layout.fillWidth: true
            }
          }
          Rectangle {
            width: 16; height: 16; radius: 8; color: "transparent"
            ShellText {
              anchors.centerIn: parent
              text: "✕"
              color: Config.subtext
              font.pixelSize: Config.fsTiny
            }
            MouseArea { anchors.fill: parent; onClicked: root.toastsModel.remove(index) }
          }
        }

        Timer { interval: Config.toastMs; running: true; onTriggered: root.toastsModel.remove(index) }
      }
    }
  }

  // ESC closes the open islands (focus granted while an island is active)
  Item {
    anchors.fill: parent
    focus: root.islandActive && !root.popupOpen
    Keys.onEscapePressed: root.closeAll()
  }

  function closeAll() {
    root.launcherOpen = false
    root.controlsOpen = false
    root.sessionOpen = false
    root.pickerOpen = false
    root.scaleLayerOpen = false
    root.volumeOpen = false
    root.batteryOpen = false
    root.brightnessOpen = false
    root.networkOpen = false
    root.calendarOpen = false
    root.notificationsOpen = false
    root.carouselOpen = false
    root.gridOpen = false
    bar.barOpen = false
    leftIsland.open = false
    rightIsland.open = false
  }

  // close everything, then toggle just the given surface flag open or closed
  function toggle(name) {
    const was = root[name]
    root.closeAll()
    root[name] = !was
  }

  function toggleLauncher() {
    const wasOpen = root.launcherOpen
    root.closeAll()
    root.launcherOpen = !wasOpen
  }

  function toggleControlCenter() {
    const wasOpen = root.controlsOpen
    root.closeAll()
    root.controlsOpen = !wasOpen
  }

  function toggleSession() {
    const wasOpen = root.sessionOpen
    root.closeAll()
    root.sessionOpen = !wasOpen
  }

  // open the full-screen picker alone (right-click on the Walls button)
  function openWallPicker() {
    root.closeAll()
    root.pickerOpen = true
  }

  // keybind-driven cycle: open the full-screen picker and slide one step
  function wallpaperCycle(dir) {
    if (!root.pickerOpen) root.openWallPicker()
    Qt.callLater(() => pickerLoader.item && pickerLoader.item.nudge(dir))
  }
}
