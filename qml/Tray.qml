/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Tray
 *
 *   A row of status notifier icons for the left island. Left click activates
 *   an item, right click opens its menu anchored below the icon and the wheel
 *   scrolls through menus where supported.
 ***/
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

RowLayout {
  id: root

  property color hoverBg: Config.surface
  property int iconSize: Math.round(18 * Config.uiScale)
  spacing: 2

  // Referencing the SystemTray singleton turns on tray tracking.
  Repeater {
    id: items
    model: SystemTray.items

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
            // QsWindow is quickshell's attached window (a real NativeWindow).
            // itemPosition() gives this icon's coordinates relative to it, so the
            // StatusNotifier menu anchors just below the icon.
            const win = QsWindow.window
            const pos = win ? win.itemPosition(itm) : { x: 0, y: 0 }
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