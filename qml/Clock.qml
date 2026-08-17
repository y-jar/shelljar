import QtQuick
import QtQuick.Layouts

// Big digital clock + date for the island center.
ColumnLayout {
  id: root

  property color textColor: Config.text
  property color dateColor: Config.subtext

  function pad(v) { return ("0" + v).slice(-2) }

  RowLayout {
    Layout.alignment: Qt.AlignHCenter
    spacing: 2

    Text {
      text: clock.hours
      color: root.textColor
      font.pixelSize: 20
      font.weight: Font.DemiBold
    }

    Text {
      // separator blinks on even seconds
      text: clock.blink ? ":" : " "
      color: root.dateColor
      font.pixelSize: 20
      font.weight: Font.DemiBold
    }

    Text {
      text: clock.minutes
      color: root.textColor
      font.pixelSize: 20
      font.weight: Font.DemiBold
    }
  }

  Text {
    text: clock.dateStr
    color: root.dateColor
    font.pixelSize: 11
    Layout.alignment: Qt.AlignHCenter
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