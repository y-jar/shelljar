import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.SystemTray

// StatusNotifier system tray cluster.
RowLayout {
  id: root

  property color hoverBg: Config.surface
  property int iconSize: 18
  spacing: 2

  // Referencing the singleton turns on tray tracking.
  SystemTray { id: tray }

  Repeater {
    id: items
    model: tray.items

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

      onWheel: { if (modelData) modelData.scroll(wheel.angleDelta.y > 0 ? 1 : -1, false) }
    }
  }

  Item { Layout.fillWidth: true }
}