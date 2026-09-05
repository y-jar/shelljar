/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   WallpaperCarousel
 *
 *   A popout row of wallpaper previews that slides as you scroll. When the view
 *   settles on a wallpaper it applies that file through the awww daemon and
 *   closes. Clicking a preview applies it right away instead.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
  id: root

  property bool open: false
  property real thumbW: Math.round(WallpaperService.thumbWidth * Config.uiScale)
  property real thumbH: Math.round(thumbW / 16 * 9)
  signal closeRequested

  width: 5 * (thumbW + 8)
  implicitHeight: thumbH

  PathView {
    id: view
    anchors.fill: parent
    model: WallpaperService.wallpapers
    snapMode: PathView.SnapToItem
    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5
    highlightRangeMode: PathView.StrictlyEnforceRange
    pathItemCount: 5
    cacheItemCount: 6

    path: Path {
      startX: 0
      startY: view.height / 2
      PathLine { x: view.width / 2; relativeY: 0 }
      PathLine { x: view.width; relativeY: 0 }
    }

    delegate: Item {
      required property var modelData
      width: root.thumbW
      height: root.thumbH

      scale: PathView.isCurrentItem ? 1.0 : 0.85
      opacity: PathView.onPath ? 1 : 0
      Behavior on scale { NumberAnimation { duration: 120 } }

      Rectangle {
        anchors.fill: parent
        radius: 8
        color: Config.surface
        clip: true

        Image {
          anchors.fill: parent
          source: modelData
          sourceSize.width: Math.round(root.thumbW)
          sourceSize.height: Math.round(root.thumbH)
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
        }
        Rectangle {
          anchors.fill: parent
          color: "transparent"
          border.width: PathView.isCurrentItem ? 2 : 0
          border.color: Config.accent
          radius: 8
        }
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          root.endSettle()
          WallpaperService.applyByIndex(PathView.index)
          root.closeRequested()
        }
      }
    }

    // wheel over the carousel slides it
    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.NoButton
      onWheel: e => {
        if (e.angleDelta.y > 0) view.decrementCurrentIndex()
        else view.incrementCurrentIndex()
        root.beginSettle()
      }
    }

    onMovementEnded: root.beginSettle()
    onCurrentIndexChanged: root.beginSettle()
  }

  // empty state when there are no wallpapers yet
  ShellText {
    anchors.centerIn: parent
    visible: WallpaperService.wallpapers.length === 0
    text: "No wallpapers found"
    color: Config.subtext
    font.pixelSize: Config.fsSmall
  }

  // when the user stops scrolling for a beat, apply the centered wallpaper + close
  Timer {
    id: settle
    interval: WallpaperService.settleMs
    onTriggered: {
      WallpaperService.applyByIndex(view.currentIndex)
      root.closeRequested()
    }
  }

  onOpenChanged: {
    if (root.open) {
      const idx = WallpaperService.wallpapers.indexOf(WallpaperService.current)
      view.currentIndex = idx >= 0 ? idx : 0
      root.endSettle()
    } else {
      root.endSettle()
    }
  }

  function beginSettle() {
    if (settle) settle.restart()
  }
  function endSettle() {
    if (settle) settle.stop()
  }

  function nudge(dir) {
    if (dir === "prev") view.decrementCurrentIndex()
    else view.incrementCurrentIndex()
    root.beginSettle()
  }
}