/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Divider
 *
 *   A hairline separator that fades to transparent at both ends, so a row of
 *   widgets can be grouped without a hard line cutting through the card. Set
 *   `vertical` to separate a column instead.
 ***/
import ".."
import QtQuick

Item {
  id: root

  property bool vertical: false
  property color color: Config.outlineSoft
  property real thickness: 1

  implicitWidth: root.vertical ? thickness : 0
  implicitHeight: root.vertical ? 0 : thickness

  Rectangle {
    anchors.fill: parent
    gradient: Gradient {
      orientation: root.vertical ? Gradient.Vertical : Gradient.Horizontal
      GradientStop { position: 0.0; color: "transparent" }
      GradientStop { position: 0.5; color: root.color }
      GradientStop { position: 1.0; color: "transparent" }
    }
  }
}
