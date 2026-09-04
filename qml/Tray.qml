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
        if (mouse.button === Qt.RightButton) {
          if (modelData.hasMenu) {
            // Anchor the StatusNotifier menu below the icon, relative to the bar
            // window. mapToItem must target an Item (contentItem), not the window.
            const win = itm.Window.window
            const pos = win ? itm.mapToItem(win.contentItem, 0, 0) : { x: 0, y: 0 }
            modelData.display(win, Math.round(pos.x), Math.round(pos.y + itm.height))
          } else {
            modelData.secondaryActivate()
          }
        } else if (mouse.button === Qt.LeftButton) {
          if (!modelData.onlyMenu) modelData.activate()
        }
      }

      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onWheel: event => { if (modelData) modelData.scroll(event.angleDelta.y > 0 ? 1 : -1, false) }
    }
  }

  Item { Layout.fillWidth: true }
}