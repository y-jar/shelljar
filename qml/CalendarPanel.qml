/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   CalendarPanel
 *
 *   A small month calendar that pops out under the clock. It shows today in a
 *   ring, lets you page through months with the arrow buttons and highlights
 *   the currently selected day. A click on any day selects it.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root

  property bool open: false
  signal closeRequested

  width: Config.popupWidth
  height: Math.round(300 * Config.uiScale)
  radius: Config.cornerRadius
  color: Config.bgAlt
  border.color: Config.borderStrong

  property date cursor: new Date()
  property var selectedDay: null

  function monthLabel(d) {
    return Qt.formatDate(d, "MMMM yyyy")
  }

  // 42 cells covering the 6 possible weeks of the month
  property var dayModel: []

  function rebuild() {
    const y = root.cursor.getFullYear()
    const m = root.cursor.getMonth()
    const first = new Date(y, m, 1)
    const start = first.getDay() // 0 = Sunday
    const days = new Date(y, m + 1, 0).getDate()
    const out = []
    for (let i = 0; i < start; i++) out.push(null)
    for (let d = 1; d <= days; d++) out.push(new Date(y, m, d))
    while (out.length % 7 !== 0) out.push(null)
    root.dayModel = out
  }

  function prev() { root.cursor = new Date(root.cursor.getFullYear(), root.cursor.getMonth() - 1, 1); root.rebuild() }
  function next() { root.cursor = new Date(root.cursor.getFullYear(), root.cursor.getMonth() + 1, 1); root.rebuild() }

  function isToday(d) {
    if (!d) return false
    const t = new Date()
    return d.getFullYear() === t.getFullYear() && d.getMonth() === t.getMonth() && d.getDate() === t.getDate()
  }

  onOpenChanged: if (root.open) root.rebuild()
  Component.onCompleted: root.rebuild()

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8

    // header: month + arrows
    RowLayout {
      Layout.fillWidth: true
      ShellText {
        text: root.monthLabel(root.cursor)
        color: Config.text
        font.pixelSize: Config.fsMedium
        font.weight: Font.DemiBold
      }
      Item { Layout.fillWidth: true }
      RowLayout {
        spacing: 4
        Rectangle {
          width: Math.round(20 * Config.uiScale); height: width; radius: 5; color: Config.surface
          MouseArea { anchors.fill: parent; onClicked: root.prev() }
          ShellText { anchors.centerIn: parent; text: "◀"; color: Config.text; font.pixelSize: Config.fsTiny }
        }
        Rectangle {
          width: Math.round(20 * Config.uiScale); height: width; radius: 5; color: Config.surface
          MouseArea { anchors.fill: parent; onClicked: root.next() }
          ShellText { anchors.centerIn: parent; text: "▶"; color: Config.text; font.pixelSize: Config.fsTiny }
        }
      }
      ShellText {
        text: "✕"
        color: Config.subtext
        font.pixelSize: Config.fsSmall
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.closeRequested()
        }
      }
    }

    // weekday headers
    GridLayout {
      Layout.fillWidth: true
      columns: 7
      columnSpacing: 4
      rowSpacing: 4
      Repeater {
        model: ["S", "M", "T", "W", "T", "F", "S"]
        delegate: ShellText {
          Layout.fillWidth: true
          text: modelData
          color: Config.subtext
          font.pixelSize: Config.fsTiny
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }

    // day grid
    GridLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      columns: 7
      columnSpacing: 4
      rowSpacing: 4

      Repeater {
        model: root.dayModel

        delegate: Item {
          required property var modelData
          Layout.fillWidth: true
          Layout.fillHeight: true

          Rectangle {
            anchors.fill: parent
            radius: 6
            color: root.isToday(modelData) ? Config.accent : (thisDayHover.containsMouse || root.selectedDay === modelData ? Config.surface : "transparent")

            ShellText {
              anchors.centerIn: parent
              text: modelData ? String(modelData.getDate()) : ""
              color: modelData
                ? (root.isToday(modelData) ? Config.white : Config.text)
                : Config.subtext
              font.pixelSize: Config.fsTiny
            }
            MouseArea {
              id: thisDayHover
              anchors.fill: parent
              hoverEnabled: true
              visible: !!modelData
              cursorShape: Qt.PointingHandCursor
              onClicked: root.selectedDay = modelData
            }
          }
        }
      }
    }
  }
}