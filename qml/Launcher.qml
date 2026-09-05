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
 *   highlight through the grid while enter launches the highlighted app.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
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

  function launch(index) {
    const apps = root.filteredApps
    if (index >= 0 && index < apps.length) {
      apps[index].execute()
      root.open = false
    }
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
      root.launch(root.currentEntry)
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

  Component.onCompleted: {
    const apps = DesktopEntries.applications.values
      .filter(e => !e.noDisplay)
    root.allApps = apps
    root.rebuildFilter()
  }

  Keys.onPressed: handleKey(event)
  Keys.onEscapePressed: root.open = false

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 14
    spacing: 10

    // search
    Rectangle {
      Layout.fillWidth: true
      implicitHeight: 32
      radius: 8
      color: Config.surface
      border.color: Config.borderSoft

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8
        ShellText { text: "🔍"; color: root.subColor; font.pixelSize: Config.fsMedium }
        TextField {
          id: searchBox
          Layout.fillWidth: true
          color: root.textColor
          placeholderText: "Search apps…"
          placeholderTextColor: root.subColor
          background: Item {}
          font.pixelSize: Config.fsMedium
          Keys.onUpPressed: root.nextEntry(-1)
          Keys.onDownPressed: root.nextEntry(1)
          Keys.onReturnPressed: root.launch(root.currentEntry)
          onTextChanged: { root.filterText = text; root.rebuildFilter() }
          focus: true
        }
      }
    }

    // empty state
    ShellText {
      Layout.fillWidth: true
      visible: root.filteredApps.length === 0
      text: "No apps match"
      color: root.subColor
      font.pixelSize: Config.fsSmall
      horizontalAlignment: Text.AlignHCenter
      Layout.preferredHeight: Math.round(40 * Config.uiScale)
    }

    // grid
    GridView {
      id: grid
      Layout.fillWidth: true
      Layout.fillHeight: true
      cellWidth: Math.round(96 * Config.uiScale)
      cellHeight: Math.round(88 * Config.uiScale)
      clip: true
      model: root.filteredApps
      boundsBehavior: Flickable.StopAtBounds
      interactive: false
      currentIndex: root.currentEntry
      highlightFollowsCurrentItem: true

      delegate: Item {
        required property var modelData
        required property int index
        width: grid.cellWidth
        height: grid.cellHeight

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
              Layout.preferredWidth: grid.cellWidth - 16
              horizontalAlignment: Text.AlignHCenter
            }
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.currentEntry = index
            onExited: if (root.currentEntry === index) root.currentEntry = -1
            onClicked: root.launch(index)
          }
        }
      }
    }
  }
}