/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   WallpaperPicker
 *
 *   A full screen deliberate wallpaper chooser built on a PathView where the
 *   centered tile is always the current one. Browse with drag, scroll or the
 *   arrow keys, apply with space, enter or w, and back out with escape or a
 *   click on a tile. Nothing applies until you choose, so it never fights you.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
  id: root

  property bool open: false
  signal closeRequested

  // how many tiles to lay out across the screen
  readonly property int visibleCount: 5
  readonly property real edgeScale: 0.8
  readonly property real marginY: Math.round(24 * Config.uiScale)
  // fraction of tileW kept as path overhang on each side -- smaller = tiles sit closer
  readonly property real overhangRatio: 0.25

  readonly property real tileW: width / root.visibleCount
  readonly property real tileH: Math.round(root.height * 0.62)

  // invisible click-away catcher (no dark backdrop -- desktop shows through)
  Rectangle {
    anchors.fill: parent
    color: "transparent"

    MouseArea {
      anchors.fill: parent
      onClicked: root.closeRequested()
    }
  }

  PathView {
    id: view
    anchors.fill: parent
    model: WallpaperService.wallpapers

    path: Path {
      startX: -root.tileW * root.overhangRatio
      startY: view.height / 2
      PathLine { x: view.width + root.tileW * root.overhangRatio; relativeY: 0 }
    }

    pathItemCount: root.visibleCount
    cacheItemCount: 6

    snapMode: PathView.SnapToItem
    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5
    highlightRangeMode: PathView.StrictlyEnforceRange
    highlightMoveDuration: 220

    focus: root.open && root.visible

    delegate: Item {
      id: delegateItem
      required property int index
      required property var modelData

      width: root.tileW
      height: root.tileH

      // dock-style magnification: centered tile is the largest
      scale: PathView.isCurrentItem ? 1.0 : root.edgeScale
      opacity: PathView.onPath ? 1 : 0
      z: PathView.isCurrentItem ? 10 : 1

      Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }

      Rectangle {
        id: tile
        anchors.centerIn: parent
        width: root.tileW * (PathView.isCurrentItem ? 0.96 : 0.93)
        height: root.tileH * 0.92
        radius: Config.cornerRadius
        color: Config.surface
        border.color: PathView.isCurrentItem ? Config.accent : Config.borderStrong
        border.width: PathView.isCurrentItem ? 2 : 0
        clip: true

        Image {
          anchors.fill: parent
          source: modelData
          // fixed decode size -> stable cache key, no per-motion re-decode
          sourceSize.width: Math.round(root.tileW * 2)
          sourceSize.height: Math.round(root.tileH * 2)
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
          cache: true
          smooth: false
        }

        Rectangle {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          height: 22
          color: Qt.rgba(0, 0, 0, 0.55)
          visible: PathView.isCurrentItem

          ShellText {
            anchors.centerIn: parent
            text: modelData.split("/").pop()
            color: Config.text
            font.pixelSize: Config.fsSmall
            elide: Text.ElideMiddle
            width: parent.width - 16
            horizontalAlignment: Text.AlignHCenter
          }
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          WallpaperService.applyByIndex(index)
          root.closeRequested()
        }
      }
    }

    // keyboard: space/enter/w = apply the CENTERED tile, esc/backspace = close,
    // arrows/jk/hl = slide
    Keys.onPressed: function(event) {
      switch (event.key) {
      case Qt.Key_Space:
      case Qt.Key_Return:
      case Qt.Key_Enter:
      case Qt.Key_W:
        event.accepted = true
        WallpaperService.applyByIndex(view.currentIndex)
        root.closeRequested()
        break
      case Qt.Key_Escape:
      case Qt.Key_Backspace:
        event.accepted = true
        root.closeRequested()
        break
      case Qt.Key_Left:
      case Qt.Key_Up:
      case Qt.Key_H:
        event.accepted = true
        view.decrementCurrentIndex()
        break
      case Qt.Key_Right:
      case Qt.Key_Down:
      case Qt.Key_L:
        event.accepted = true
        view.incrementCurrentIndex()
        break
      default:
        break
      }
    }

    onCountChanged:
      root.syncToCurrent()
  }

  // passthrough wheel catcher: step-wise selection moves (updates currentIndex
  // immediately, short snap), instead of a big fling that makes you wait.
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    onWheel: e => {
      const steps = Math.max(1, Math.ceil(Math.abs(e.angleDelta.y) / 120))
      for (let i = 0; i < steps; i++) {
        if (e.angleDelta.y > 0) view.decrementCurrentIndex()
        else view.incrementCurrentIndex()
      }
      view.forceActiveFocus()
      e.accepted = true
    }
  }

  // hint bar at the bottom
  ShellText {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.marginY
    text: WallpaperService.wallpapers.length === 0
      ? "No wallpapers found"
      : "scroll to move — space / enter / w to apply — esc to close"
    color: Config.subtext
    font.pixelSize: Config.fsSmall
    opacity: 0.9
  }

  function syncToCurrent() {
    const idx = WallpaperService.wallpapers.indexOf(WallpaperService.current)
    if (idx >= 0 && view.currentIndex !== idx) view.currentIndex = idx
  }

  // keybind-driven cycle: open + slide one step (currently only uses next/prev)
  function nudge(dir) {
    if (dir === "prev") view.decrementCurrentIndex()
    else view.incrementCurrentIndex()
    view.forceActiveFocus()
  }

  onOpenChanged: {
    if (root.open && WallpaperService.wallpapers.length > 0) {
      root.syncToCurrent()
      Qt.callLater(() => view.forceActiveFocus())
    }
  }
}