import qs.components
import QtQuick
import QtQuick.Layouts
import Quickshell

// ---- full-screen wallpaper picker (calm, hyprquickpaper-style) ----
// A large screen-spanning carousel meant for a relaxed browsing session.
// Browse by drag + scroll; the centered tile is the active candidate.
// Apply with space / enter / w, exit with esc (or click a tile to apply it).
// Unlike the quick carousel there is NO settle-delay auto-apply: selection is
// always deliberate.
Item {
  id: root

  property bool open: false
  signal closeRequested

  // how many slots to lay out across the screen
  readonly property int visibleCount: 7
  readonly property real maxScale: 1.0
  readonly property real edgeScale: 0.78
  readonly property real marginY: Math.round(24 * Config.uiScale)

  // dim + click-away scrim behind the carousel
  Rectangle {
    anchors.fill: parent
    color: "#a0000000"

    MouseArea {
      anchors.fill: parent
      onClicked: root.closeRequested()
    }
  }

  // centered browsing band
  Item {
    id: band
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    height: Math.round(parent.height * 0.66)

    ListView {
      id: view
      anchors.fill: parent
      model: WallpaperService.wallpapers
      orientation: Qt.Horizontal
      spacing: 12
      clip: true

      interactive: true
      flickDeceleration: 2500
      boundsBehavior: Flickable.StopAtBounds
      cacheBuffer: 800

      snapMode: ListView.SnapToItem
      highlightFollowsCurrentItem: true
      highlightRangeMode: ListView.StrictlyEnforceRange
      preferredHighlightBegin: 0.5
      preferredHighlightEnd: 0.5

      focus: root.open && root.visible

      // center the first/last tile in the viewport
      leftMargin: Math.max(0, (width - view.cellW) / 2)
      rightMargin: leftMargin

      readonly property real cellW: width / root.visibleCount
      readonly property real viewportCenterX: width / 2

      delegate: Item {
        id: delegateItem
        required property int index
        required property var modelData

        readonly property real baseWidth: view.cellW

        // dock-style magnification peaking at the viewport center
        property real scaleFactor: {
          const centerX = x - view.contentX + baseWidth / 2
          const frac = Math.min(
            1,
            Math.abs(centerX - view.viewportCenterX) / view.viewportCenterX
          )
          const t = 1 - frac * frac * (3 - 2 * frac)
          return root.edgeScale + (root.maxScale - root.edgeScale) * t
        }

        width: baseWidth * scaleFactor
        height: view.height
        z: Math.round(scaleFactor * 100)

        Rectangle {
          anchors.centerIn: parent
          width: parent.width * 0.96
          height: parent.height * Math.min(1, delegateItem.scaleFactor) * 0.92
          radius: Config.cornerRadius
          color: Config.surface
          border.color: ListView.isCurrentItem ? Config.accent : Qt.rgba(1, 1, 1, 0.10)
          border.width: ListView.isCurrentItem ? 2 : 0
          clip: true

          Image {
            anchors.fill: parent
            source: modelData
            sourceSize.width: Math.round(view.cellW * root.maxScale)
            sourceSize.height: Math.round(view.cellW * root.maxScale / 16 * 9)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            smooth: true
          }

          Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 22
            color: Qt.rgba(0, 0, 0, 0.55)
            visible: ListView.isCurrentItem

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

      // keyboard: space/enter/w = apply current, esc/backspace = close,
      // arrows = slide
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
          event.accepted = true
          view.decrementCurrentIndex()
          break
        case Qt.Key_Right:
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
  }

  // hint bar at the bottom
  ShellText {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.marginY
    text: "drag / scroll to browse — space / enter / w to apply — esc to close"
    color: Config.subtext
    font.pixelSize: Config.fsSmall
    opacity: 0.9
  }

  function syncToCurrent() {
    const idx = WallpaperService.wallpapers.indexOf(WallpaperService.current)
    if (idx >= 0 && view.currentIndex !== idx) view.currentIndex = idx
    view.positionViewAtIndex(Math.max(0, view.currentIndex), ListView.Center)
  }

  function nudge(dir) {
    if (dir === "prev") view.decrementCurrentIndex()
    else view.incrementCurrentIndex()
    view.positionViewAtIndex(view.currentIndex, ListView.Contain)
  }

  // "nudge" for the full-screen picker keeps it open (no settle-apply)
  onOpenChanged: {
    if (root.open && WallpaperService.wallpapers.length > 0) {
      root.syncToCurrent()
      view.forceActiveFocus()
    }
  }
}