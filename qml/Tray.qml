import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.SystemTray

// StatusNotifier system tray cluster.
RowLayout {
  id: root

  property color hoverBg: Config.surface
  property int iconSize: Math.round(18 * Config.uiScale)
  spacing: 2

  // Referencing the SystemTray singleton turns on tray tracking.
  Repeater {
    id: items
    model: SystemTray.items.values

    delegate: MouseArea {
      required property var modelData
      id: itm

      width: root.iconSize + 10
      height: width
      hoverEnabled: true

      Rectangle {
        anchors.fill: parent
        radius: 6
        color: parent.containsMouse ? root.hoverBg : "transparent"
      }

      IconImage {
        anchors.centerIn: parent
        source: modelData ? modelData.icon : ""
        width: root.iconSize
        height: root.iconSize
      }

      onClicked: {
        if (!modelData) return
        if (containsMouse && modelData.hasMenu) modelData.display(itm, 0, itm.height)
        else modelData.activate()
      }

      onWheel: event => { if (modelData) modelData.scroll(event.angleDelta.y > 0 ? 1 : -1, false) }
    }
  }

  Item { Layout.fillWidth: true }
}