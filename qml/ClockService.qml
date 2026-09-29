/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   ClockService
 *
 *   One shared ticking clock for the whole shell. Every Clock view reads its
 *   hours/minutes/date/blink from here, so there is a single one-second timer
 *   no matter how many screens show a clock (the bar on each monitor, the UI
 *   scale preview).
 ***/
pragma Singleton
import QtQuick
import Quickshell

Item {
  id: root

  property string hours: "00"
  property string minutes: "00"
  property string dateStr: ""
  property bool blink: false

  function pad(v) { return ("0" + v).slice(-2) }

  function update() {
    const now = new Date()
    root.hours = root.pad(now.getHours())
    root.minutes = root.pad(now.getMinutes())
    root.blink = (now.getSeconds() % 2) === 0
    root.dateStr = Qt.formatDate(now, "dddd MMM d")
  }

  Timer {
    interval: 1000
    repeat: true
    running: true
    onTriggered: root.update()
  }

  Component.onCompleted: root.update()
}
