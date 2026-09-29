/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Panel
 *
 *   The base every popout is built on: a Surface card with a gentle enter
 *   animation (fade + a small scale-up) and an inset content well. A caller
 *   sets `open`, sizes the item (usually by its Loader), and drops its layout
 *   straight between the braces; anything inside gets the standard margin so
 *   every panel lines up. Phase-1 surfaces replace their old `Rectangle { ... }`
 *   root with `Panel { ... }` and inherit the look and motion for free.
 ***/
import ".."
import QtQuick

Item {
  id: root

  property bool open: false
  property real inset: Config.spaceLg
  property real panelRadius: Config.radiusMd
  property color fillTop: Config.surfaceMid
  property color fillBot: Config.surfaceLow
  property color outlineColor: Config.outline
  property bool bordered: true

  // children drop into `body`; the card and motion are handled here
  default property alias content: body.data
  readonly property alias surface: card

  // enter animation: a small scale-up + fade driven straight off `open`
  opacity: root.open ? 1 : 0
  scale: root.open ? 1 : 0.97
  transformOrigin: Item.Center
  Behavior on opacity { NumberAnimation { duration: Motion.glide; easing.type: Motion.easeStandard } }
  Behavior on scale { NumberAnimation { duration: Motion.glide; easing.type: Motion.easeStandard } }

  Surface {
    id: card
    anchors.fill: parent
    radius: root.panelRadius
    fillTop: root.fillTop
    fillBot: root.fillBot
    outlineColor: root.outlineColor
    bordered: root.bordered
  }

  Item {
    id: body
    anchors.fill: parent
    anchors.margins: root.inset
  }
}
