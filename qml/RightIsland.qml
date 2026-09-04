import qs.components
import QtQuick
import QtQuick.Layouts

// Right auto-hiding island: [battery | brightness]. Collapsed = a slim horizontal
// handle on the right edge; right-click expands into a single-row card.
Item {
  id: root

  readonly property real stripW: Math.max(48, Math.round(60 * Config.uiScale))
  width: open ? Math.max(Config.minDockWidth, (content ? content.implicitWidth + 16 : stripW))
              : (Config.stripHeight)
  height: open ? Config.dockHeight : Config.stripHeight

  property bool open: false
  signal batteryPanelRequested
  signal brightnessPanelRequested
  signal osdBrightnessHoverRequested
  signal osdBrightnessValueChanged

  Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
  Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

  Rectangle {
    id: card
    anchors.fill: parent
    radius: Config.cornerRadius
    color: Config.bg
    border.color: Qt.rgba(1, 1, 1, 0.10)

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.RightButton
      onClicked: root.open = !root.open
    }

    Rectangle {
      anchors.centerIn: parent
      visible: !root.open
      width: 4
      height: Math.round(parent.width * 0.4)
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