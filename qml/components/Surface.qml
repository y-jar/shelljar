/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Surface
 *
 *   The one card material every bar, island, popup, tile and tooltip is built
 *   from. It paints a soft vertical gradient (lighter on top, light coming from
 *   above), an optional 1px outline, a whisper of top sheen, and quiet
 *   hover/pressed/active feedback. It is translucent so the wallpaper reads
 *   through, but its fills stay opaque enough to keep copy legible. No blur.
 ***/
import ".."
import QtQuick

Rectangle {
  id: root

  // ---- material ----
  property color fillTop: Config.surfaceMid
  property color fillBot: Config.surfaceLow
  property color outlineColor: Config.outline
  property bool bordered: true
  property bool sheen: true
  // when the surface merges into the screen's top edge, hide the top hairline
  property bool topEdgeFlush: false

  // ---- interaction state (drive these from your hover/press handlers) ----
  property bool interactive: false
  property bool hovered: false
  property bool pressed: false
  property bool active: false

  // interactive surfaces lift their fill slightly; active leans on the accent
  readonly property color topColor: {
    if (root.pressed) return Qt.darker(root.fillTop, 1.12)
    if (root.hovered && root.interactive) return Qt.lighter(root.fillTop, 1.10)
    return root.fillTop
  }
  readonly property color botColor: {
    if (root.pressed) return Qt.darker(root.fillBot, 1.12)
    if (root.hovered && root.interactive) return Qt.lighter(root.fillBot, 1.10)
    return root.fillBot
  }

  radius: Config.radiusMd
  border.width: root.bordered ? 1 : 0
  border.color: root.active ? Config.accent : root.outlineColor

  gradient: Gradient {
    GradientStop { position: 0.0; color: root.topColor }
    GradientStop { position: 1.0; color: root.botColor }
  }

  Behavior on border.color { ColorAnimation { duration: Motion.fast; easing.type: Motion.easeStandard } }

  // flush-top surfaces hide the top 1px outline so they read as merged into the edge
  Rectangle {
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 1
    visible: root.topEdgeFlush && root.bordered
    color: root.topColor
  }

  // top sheen: a hairline highlight just inside the top edge
  Rectangle {
    anchors.top: parent.top
    anchors.topMargin: 1
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: Math.min(parent.radius * 0.6, parent.width / 3)
    anchors.rightMargin: Math.min(parent.radius * 0.6, parent.width / 3)
    height: 1
    visible: root.sheen && !root.active
    color: Config.sheen
  }
}
