import qs.components
import QtQuick
import QtQuick.Layouts

// Right auto-hiding island: [battery | brightness]. Collapsed = a slim horizontal
// bar (like the middle island); right-click expands into a single-row card.
Item {
  id: root

  readonly property real stripW: Math.max(120, Math.round(150 * Config.uiScale))
  width: open ? Math.max(Config.minDockWidth, (content ? content.implicitWidth + 16 : stripW))
              : stripW
  height: open ? Config.dockHeight : Config.stripHeight

  property bool open: false
  signal batteryPanelRequested
  signal brightnessPanelRequested

  Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
  Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

  Rectangle {
    id: card
    anchors.fill: parent
    radius: Config.cornerRadius
    color: Config.bg
    border.color: Qt.rgba(1, 1, 1, 0.10)
    clip: true

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.RightButton
      onClicked: root.open = !root.open
    }

    Rectangle {
      anchors.centerIn: parent
      visible: !root.open
      width: Math.round(parent.width * 0.5)
      height: 4
      radius: 2
      color: Config.surfaceAlt
    }

    RowLayout {
      id: content
      anchors.fill: parent
      anchors.margins: 8
      spacing: 6
      visible: root.open

      BatteryWidget {
        onBatteryClicked: root.batteryPanelRequested()
      }
      BrightnessWidget {
        onHoverRequested: root.osdBrightnessHoverRequested()
        onValueChanged: root.osdBrightnessValueChanged()
        onBrightnessPanelRequested: root.brightnessPanelRequested()
      }
    }
  }
}