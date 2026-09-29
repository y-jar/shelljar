/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   IconButton
 *
 *   One round/rounded glyph button used across the bar and islands. It carries
 *   the shared hover, pressed and checked feedback (with animated colour and a
 *   small press scale) and an optional tooltip, so every control in the shell
 *   behaves and animates the same way.
 ***/
import ".."
import QtQuick

Item {
  id: root

  property string glyph: ""
  property bool checked: false
  property bool circular: true
  property string tooltip: ""
  property string tooltipDesc: ""
  property real buttonSize: Config.iconButtonSize
  property color glyphColor: Config.text
  property color checkedFill: Config.accent
  property color checkedGlyph: Config.accentInk

  implicitWidth: buttonSize
  implicitHeight: buttonSize

  signal clicked
  signal rightClicked
  signal scrolled(int direction)

  readonly property bool hovered: mouse.containsMouse

  Rectangle {
    id: bg
    anchors.fill: parent
    radius: root.circular ? width / 2 : Config.radiusSm
    color: root.checked ? root.checkedFill
      : mouse.pressed ? Qt.darker(Config.surfaceHigh, 1.10)
      : root.hovered ? Config.surfaceHigh
      : "transparent"
    border.width: root.checked ? 0 : 1
    border.color: Config.outlineSoft
    clip: true
    Behavior on color { ColorAnimation { duration: Motion.fast; easing.type: Motion.easeStandard } }
    Behavior on border.color { ColorAnimation { duration: Motion.fast; easing.type: Motion.easeStandard } }

    Ripple {
      id: ripple
      color: root.checked ? Config.accentInk : Config.text
    }
  }

  GlyphIcon {
    anchors.centerIn: parent
    width: Config.iconMd
    height: width
    name: root.glyph
    color: root.checked ? root.checkedGlyph : root.glyphColor
    stroke: 1.8
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onPressed: ripple.fire(mouse.x, mouse.y)
    onClicked: event => {
      if (event.button === Qt.RightButton) root.rightClicked()
      else root.clicked()
    }
    onWheel: event => root.scrolled(event.angleDelta.y > 0 ? 1 : -1)
  }

  Tooltip {
    s: Config.uiScale
    title: root.tooltip
    desc: root.tooltipDesc
    show: root.hovered && root.tooltip !== ""
    placement: "below"
  }

  scale: mouse.pressed ? 0.94 : (root.hovered ? 1.04 : 1)
  Behavior on scale { NumberAnimation { duration: Motion.fast; easing.type: Motion.easeStandard } }
}
