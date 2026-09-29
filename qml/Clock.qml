/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Clock
 *
 *   The big digital clock and date shown in the middle island. It renders the
 *   shared ClockService so the shell keeps one ticking timer for every screen;
 *   the separator blinks off a fixed-width slot so the row never shifts
 *   sideways.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property color textColor: Config.text
  property color dateColor: Config.subtext
  signal clicked

  // size the item to its content so it centers correctly and the click target covers it
  width: col.implicitWidth
  height: col.implicitHeight

  ColumnLayout {
    id: col
    anchors.fill: parent
    spacing: 0

    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: 2

      ShellText {
        text: ClockService.hours
        color: root.textColor
        font.pixelSize: Config.fsLarge
        font.weight: Font.DemiBold
      }

      // fixed width so the whole row stays centered whichever state the blink is in
      ShellText {
        Layout.preferredWidth: Math.round(9 * Config.uiScale)
        horizontalAlignment: Text.AlignHCenter
        text: ClockService.blink ? ":" : ""
        color: root.dateColor
        font.pixelSize: Config.fsLarge
        font.weight: Font.DemiBold
      }

      ShellText {
        text: ClockService.minutes
        color: root.textColor
        font.pixelSize: Config.fsLarge
        font.weight: Font.DemiBold
      }
    }

    ShellText {
      text: ClockService.dateStr
      color: root.dateColor
      font.pixelSize: Config.fsSmall
      Layout.alignment: Qt.AlignHCenter
    }
  }

  // overlay click area so the whole clock opens the calendar
  MouseArea {
    anchors.fill: parent
    z: 10
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
