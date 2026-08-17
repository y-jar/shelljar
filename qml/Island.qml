import qs.components
import QtQuick

// Minimized island pill = main-menu launcher (hosted in RootWindow).
// Right-click opens the main menu (noctalia-style). There is no hover-expand bar.
Item {
  id: root

  width: Math.round(56 * Config.uiScale)
  height: Math.round(26 * Config.uiScale)

  property color textColor: Config.text
  property color subColor: Config.subtext
  signal menuClicked

  Rectangle {
    id: pill
    anchors.fill: parent
    radius: height / 2
    color: Config.surface
    border.color: Qt.rgba(1,1,1,0.10)

    ShellText {
      anchors.centerIn: parent
      text: "☰"
      color: root.textColor
      font.pixelSize: Config.fsSmall
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.RightButton
      onEntered: pill.color = Config.surfaceAlt
      onExited: pill.color = Config.surface
      onClicked: root.menuClicked()
    }
  }
}