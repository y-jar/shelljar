/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   ToggleTile
 *
 *   A quick-settings tile: a glyph over a short label in a Surface card that
 *   fills with the accent container when `checked`. Used for the control
 *   center's toggles (wifi, bluetooth, wallpaper, …). Drive `checked` from the
 *   real state and react to `clicked`; `enabled: false` dims it.
 ***/
import ".."
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property string glyph: ""
  property string label: ""
  property bool checked: false
  property bool enabled: true

  implicitWidth: Math.round(72 * Config.uiScale)
  implicitHeight: Math.round(56 * Config.uiScale)

  signal clicked

  Surface {
    anchors.fill: parent
    radius: Config.radiusMd
    interactive: root.enabled
    hovered: mouse.containsMouse
    active: root.checked
    fillTop: root.checked ? Config.accentContainer : Config.surfaceMid
    fillBot: root.checked ? Config.accentContainer : Config.surfaceLow
    opacity: root.enabled ? 1 : 0.4
  }

  ColumnLayout {
    anchors.centerIn: parent
    spacing: Math.round(3 * Config.uiScale)

    GlyphIcon {
      Layout.alignment: Qt.AlignHCenter
      width: Math.round(18 * Config.uiScale)
      height: width
      name: root.glyph
      color: root.checked ? Config.accentInk : Config.text
      stroke: 1.7
    }
    ShellText {
      Layout.alignment: Qt.AlignHCenter
      text: root.label
      color: root.checked ? Config.accentInk : Config.subtext
      font.pixelSize: Config.fsTiny
    }
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    enabled: root.enabled
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
