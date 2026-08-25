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

      onClicked: mouse => {
        if (!modelData) return
        // Anchor the StatusNotifier menu relative to the enclosing bar window.
        const win = itm.Window.window
        const pos = win ? itm.mapToItem(win, 0, 0) : { x: 0, y: 0 }
        const x = Math.round(pos.x)
        const y = Math.round(pos.y + itm.height)
        if (modelData.hasMenu) {
          modelData.display(win, x, y)
        } else if (mouse.button === Qt.LeftButton) {
          modelData.activate()
        } else {
          modelData.secondaryActivate()
        }
      }

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onWheel: event => { if (modelData) modelData.scroll(event.angleDelta.y > 0 ? 1 : -1, false) }
    }
  }

  Item { Layout.fillWidth: true }
}