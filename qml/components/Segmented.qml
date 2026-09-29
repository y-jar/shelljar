/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Segmented
 *
 *   A small segmented control: one Surface pill per option, the active one
 *   filled with the accent container. `options` is an array of
 *   `{ value, label }`; set `value` to the active option and react to
 *   `selected(value)`.
 ***/
import ".."
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property var options: []
  property var value: undefined
  property real itemHeight: Math.round(30 * Config.uiScale)

  implicitHeight: root.itemHeight
  implicitWidth: row.implicitWidth

  signal selected(var value)

  RowLayout {
    id: row
    anchors.fill: parent
    spacing: Math.round(4 * Config.uiScale)

    Repeater {
      model: root.options

      delegate: Surface {
        required property var modelData
        Layout.fillWidth: true
        Layout.preferredHeight: root.itemHeight
        radius: Config.radiusSm
        interactive: true
        hovered: segHover.containsMouse
        fillTop: root.value === modelData.value ? Config.accentContainer : Config.surfaceMid
        fillBot: root.value === modelData.value ? Config.accentContainer : Config.surfaceLow

        ShellText {
          anchors.centerIn: parent
          text: modelData.label
          color: root.value === modelData.value ? Config.accentInk : Config.text
          font.pixelSize: Config.fsTiny
        }

        MouseArea {
          id: segHover
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.selected(modelData.value)
        }
      }
    }
  }
}
