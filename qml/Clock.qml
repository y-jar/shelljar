/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Clock
 *
 *   The big digital clock and date shown in the middle island. It keeps a
 *   fixed width for the blinking separator so the row never shifts sideways
 *   every second, and it refreshes on a one second timer.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property color textColor: Config.text
  property color dateColor: Config.subtext
  signal clicked

  function pad(v) { return ("0" + v).slice(-2) }

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: 2

      ShellText {
        text: clock.hours
        color: root.textColor
        font.pixelSize: Config.fsLarge
        font.weight: Font.DemiBold
      }

      // fixed width so the whole row stays centered whichever state the blink is in
      ShellText {
        Layout.preferredWidth: Math.round(9 * Config.uiScale)
        horizontalAlignment: Text.AlignHCenter
        text: clock.blink ? ":" : ""
        color: root.dateColor
        font.pixelSize: Config.fsLarge
        font.weight: Font.DemiBold
      }

      ShellText {
        text: clock.minutes
        color: root.textColor
        font.pixelSize: Config.fsLarge
        font.weight: Font.DemiBold
      }
    }

    ShellText {
      text: clock.dateStr
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

  Timer {
    id: clock
    property string hours: "00"
    property string minutes: "00"
    property string dateStr: ""
    property bool blink: false

    interval: 1000
    repeat: true
    running: true
    onTriggered: update()

    function update() {
      const now = new Date()
      hours = root.pad(now.getHours())
      minutes = root.pad(now.getMinutes())
      blink = (now.getSeconds() % 2) === 0
      dateStr = Qt.formatDate(now, "dddd MMM d")
    }
  }
}