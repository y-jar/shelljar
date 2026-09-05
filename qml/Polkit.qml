/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Polkit
 *
 *   A small authentication dialog for privileged actions. When an app asks for
 *   an admin password it appears as a dim overlay with the request message, a
 *   password field and submit and cancel buttons, and reports pass or fail
 *   back to the requester.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Polkit

Item {
  id: root

  readonly property var flow: agent.flow
  visible: active

  // shown while a request is open
  property bool active: false
  property bool failed: false

  PolkitAgent {
    id: agent
    onAuthenticationRequestStarted: {
      root.active = true
      root.failed = false
    }
  }

  Connections {
    target: agent.flow
    function onAuthenticationSucceeded() { root.active = false }
    function onAuthenticationRequestCancelled() { root.active = false }
    function onAuthenticationFailed() { root.failed = true }
  }

  function submit() {
    const f = root.flow
    if (f && psk.text !== "") {
      try { f.submit(psk.text) } catch (e) {}
      psk.text = ""
    }
  }

  function cancel() {
    const f = root.flow
    try { if (f) f.cancelAuthenticationRequest() } catch (e) {}
    root.active = false
  }

  // dim backdrop
  Rectangle {
    anchors.fill: parent
    visible: root.active
    color: Config.scrimHeavy
    MouseArea { anchors.fill: parent }
  }

  Rectangle {
    id: dialog
    anchors.centerIn: parent
    visible: root.active
    width: Math.round(320 * Config.uiScale)
    implicitHeight: col.implicitHeight + 24
    radius: Config.cornerRadius
    color: Config.bgAlt
    border.color: Config.borderStrong

    ColumnLayout {
      id: col
      anchors.fill: parent
      anchors.margins: 14
      spacing: 10

      ShellText {
        Layout.fillWidth: true
        text: "Authentication"
        color: Config.text
        font.pixelSize: Config.fsMedium
        font.weight: Font.DemiBold
      }

      ShellText {
        Layout.fillWidth: true
        text: root.flow && root.flow.message ? root.flow.message : "An application needs permission"
        color: Config.subtext
        font.pixelSize: Config.fsSmall
        wrapMode: Text.WordWrap
      }

      TextField {
        id: psk
        Layout.fillWidth: true
        echoMode: TextInput.Password
        color: Config.text
        placeholderText: "••••••••"
        placeholderTextColor: Config.subtext
        background: Rectangle { color: Config.surface; radius: 6 }
        font.pixelSize: Config.fsSmall
        onAccepted: root.submit()
        focus: root.active
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 30
          radius: 8
          color: Config.surface
          border.color: Config.borderMid
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.cancel()
          }
          ShellText { anchors.centerIn: parent; text: "Cancel"; color: Config.text; font.pixelSize: Config.fsSmall }
        }
        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 30
          radius: 8
          color: Config.accent
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.submit()
          }
          ShellText { anchors.centerIn: parent; text: "Unlock"; color: Config.white; font.pixelSize: Config.fsSmall }
        }
      }

      ShellText {
        Layout.fillWidth: true
        visible: root.failed
        text: "Wrong password, try again"
        color: Config.red
        font.pixelSize: Config.fsTiny
      }
    }
  }
}