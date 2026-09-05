/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Launcher
 *
 *   A grid of installed applications with a search box. Typing filters the apps
 *   by name, generic name, keywords and categories, and the arrow keys move a
 *   highlight through the grid while enter launches the highlighted app. Right
 *   clicking an app pins it to the Pinned strip, which is saved between runs.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

Rectangle {
  id: root

  property bool open: false
  width: Config.launcherWidth
  height: Config.launcherHeight
  radius: Config.cornerRadius
  color: Config.bg
  border.color: Config.borderMid

  property color textColor: Config.text
  property color subColor: Config.subtext
  property var allApps: [] // array of DesktopEntry
  property string filterText: ""
  property var filteredApps: []
  property int currentEntry: -1

  // pinned app ids, persisted to ~/.cache/shelljar/favorites
  property var pinned: []
  property real cellW: Math.round(96 * Config.uiScale)
  property real cellH: Math.round(88 * Config.uiScale)
  readonly property int columns: Math.max(1, Math.floor((width - 28) / root.cellW))

  readonly property string favFile: (Quickshell.env("HOME") || "/home/user") + "/.cache/shelljar/favorites"

  signal closeRequested

  function matches(entry, q) {
    if (q === "") return true
    if (entry.name.toLowerCase().includes(q)) return true
    if (entry.genericName && entry.genericName.toLowerCase().includes(q)) return true
    if (entry.comment && entry.comment.toLowerCase().includes(q)) return true
    if (entry.keywords) for (const k of entry.keywords) if (k.toLowerCase().includes(q)) return true
    if (entry.categories) for (const c of entry.categories) if (c.toLowerCase().includes(q)) return true
    return false
  }

  function rebuildFilter() {
    const q = root.filterText.toLowerCase().trim()
    const out = []
    for (const entry of root.allApps) {
      if (root.matches(entry, q)) out.push(entry)
    }
    root.filteredApps = out
    root.currentEntry = out.length > 0 ? 0 : -1
  }

  function byId(id) {
    for (const e of root.allApps) { if (e.id === id) return e }
    return null
  }

  function launch(entry) {
    if (!entry) return
    entry.execute()
    root.closeRequested()
  }
  function launchIndex(index) {
    const apps = root.filteredApps
    if (index >= 0 && index < apps.length) root.launch(apps[index])
  }

  function isPinned(id) { return root.pinned.indexOf(id) !== -1 }

  function togglePinned(entry) {
    if (!entry) return
    const arr = root.pinned.slice()
    const i = arr.indexOf(entry.id)
    if (i === -1) arr.push(entry.id)
    else arr.splice(i, 1)
    root.pinned = arr
    root.savePinned()
  }

  // persist pinned ids, one per line, then re-read so they're canonical
  function savePinned() {
    Quickshell.execDetached(["sh", "-c",
      "mkdir -p \"$HOME/.cache/shelljar\" && : > \"$HOME/.cache/shelljar/favorites\" && for f in \"$@\"; do echo \"$f\"; done >> \"$HOME/.cache/shelljar/favorites\"",
      "shelljar-fav"].concat(root.pinned))
  }

  function loadPinned(text) {
    const out = []
    for (const line of (text || "").split("\n")) {
      const t = line.trim()
      if (t !== "") out.push(t)
    }
    root.pinned = out
  }

  function nextEntry(dir) {
    const n = root.filteredApps.length
    if (n === 0) return
    root.currentEntry = (root.currentEntry + dir + n) % n
    grid.positionViewAtIndex(root.currentEntry, GridView.Center)
  }

  function handleKey(event) {
    switch (event.key) {
    case Qt.Key_Return:
    case Qt.Key_Enter:
      event.accepted = true
      root.launchIndex(root.currentEntry)
      break
    case Qt.Key_Down:
      event.accepted = true; root.currentEntry = (root.currentEntry + 1) % Math.max(1, root.filteredApps.length); break
    case Qt.Key_Up:
      event.accepted = true; root.currentEntry = (root.currentEntry - 1 + root.filteredApps.length) % Math.max(1, root.filteredApps.length); break
    case Qt.Key_Right:
      event.accepted = true
      root.currentEntry = Math.min(root.currentEntry + 1, root.filteredApps.length - 1)
      break
    case Qt.Key_Left:
      event.accepted = true
      root.currentEntry = Math.max(root.currentEntry - 1, 0)
      break
    default:
      break
    }
  }

  function loadApps() {
    const apps = DesktopEntries.applications.values
      .filter(e => !e.noDisplay)
    root.allApps = apps
    root.rebuildFilter()
  }

  Component.onCompleted: {
    root.loadApps()
    favFileView.reload()
  }

  // the application list arrives asynchronously, so reload it when it changes
  Connections {
    target: DesktopEntries && DesktopEntries.applications ? DesktopEntries.applications : null
    function onValuesChanged() { root.loadApps() }
  }

  // read pinned ids from disk
  FileView {
    id: favFileView
    path: root.favFile
    printErrors: false
    onLoaded: root.loadPinned(text())
  }

  // reset + grab focus whenever the launcher is shown/hidden
  onVisibleChanged: {
    if (root.visible) {
      searchBox.forceActiveFocus()
    } else {
      root.filterText = ""
      searchBox.text = ""
    }
  }

  Keys.onPressed: handleKey(event)
  Keys.onEscapePressed: root.closeRequested()

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 14
    spacing: 10

    // ---- search bar (no emoji; just a friendly placeholder) ----
    Rectangle {
      Layout.fillWidth: true
      implicitHeight: 32
      radius: 8
      color: Config.surface
      border.color: Config.borderSoft

      TextField {
        id: searchBox
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        verticalAlignment: Text.AlignVCenter
        color: root.textColor
        placeholderText: "Search apps... :)"
        placeholderTextColor: root.subColor
        background: Item {}
        font.pixelSize: Config.fsMedium
        Keys.onUpPressed: root.nextEntry(-1)
        Keys.onDownPressed: root.nextEntry(1)
        Keys.onReturnPressed: root.launchIndex(root.currentEntry)
        Keys.onEscapePressed: root.closeRequested()
        onTextChanged: { root.filterText = text; root.rebuildFilter() }
        focus: true
      }
    }

    // ---- pinned strip (hidden when nothing is pinned) ----
    ColumnLayout {
      visible: root.pinned.length > 0
      Layout.fillWidth: true
      spacing: 6

      ShellText {
        text: "Pinned"
        color: root.subColor
        font.pixelSize: Config.fsTiny
        font.weight: Font.DemiBold
      }

      Flow {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
          model: root.pinned

          delegate: Item {
            required property string modelData
            readonly property var app: root.byId(modelData)
            width: Math.round(56 * Config.uiScale)
            height: Math.round(56 * Config.uiScale)
            visible: app !== null

            Rectangle {
              anchors.fill: parent
              radius: 12
              color: pinHover.containsMouse ? Config.surfaceAlt : Config.surface
              border.color: Config.borderSoft

              IconImage {
                anchors.centerIn: parent
                width: Math.round(30 * Config.uiScale)
                height: Math.round(30 * Config.uiScale)
                asynchronous: true
                source: app ? Quickshell.iconPath(app.icon, "image-missing") : ""
              }

              MouseArea {
                id: pinHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: event => {
                  if (event.button === Qt.RightButton) root.togglePinned(app)
                  else root.launch(app)
                }
              }
            }
          }
        }
      }
    }

    // ---- empty state ----
    ShellText {
      Layout.fillWidth: true
      visible: root.filteredApps.length === 0
      text: "No apps match"
      color: root.subColor
      font.pixelSize: Config.fsSmall
      horizontalAlignment: Text.AlignHCenter
      Layout.preferredHeight: Math.round(40 * Config.uiScale)
    }

    // ---- app grid (centered block, vertical scroll) ----
    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      GridView {
        id: grid
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.columns * root.cellW
        cellWidth: root.cellW
        cellHeight: root.cellH
        clip: true
        model: root.filteredApps
        boundsBehavior: Flickable.StopAtBounds
        interactive: true
        currentIndex: root.currentEntry
        highlightFollowsCurrentItem: true

        delegate: Item {
          required property var modelData
          required property int index
          width: root.cellW
          height: root.cellH

          Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: 10
            color: root.currentEntry === index ? Config.surface : "transparent"
            border.width: root.currentEntry === index ? 2 : 0
            border.color: Config.accent

            ColumnLayout {
              anchors.centerIn: parent
              spacing: 6
              IconImage {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.round(36 * Config.uiScale)
                Layout.preferredHeight: Math.round(36 * Config.uiScale)
                asynchronous: true
                source: Quickshell.iconPath(modelData.icon, "image-missing")
              }
              ShellText {
                text: modelData.name
                color: root.textColor
                font.pixelSize: Config.fsSmall
                elide: Text.ElideRight
                Layout.preferredWidth: root.cellW - 16
                horizontalAlignment: Text.AlignHCenter
              }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onEntered: root.currentEntry = index
              onExited: if (root.currentEntry === index) root.currentEntry = -1
              onClicked: event => {
                if (event.button === Qt.RightButton) { root.togglePinned(modelData); root.currentEntry = index }
                else root.launchIndex(index)
              }
            }
          }
        }
      }
    }

    // ---- silly bottom tip ----
    ShellText {
      Layout.fillWidth: true
      text: "psst... right click an app to pin it up top :)"
      color: root.subColor
      font.pixelSize: Config.fsTiny
      horizontalAlignment: Text.AlignHCenter
    }
  }
}