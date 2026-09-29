/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   Launcher
 *
 *   A search field over a ranked list of installed applications. Typing scores
 *   entries by a fuzzy match on the name (then generic name, comment, keywords
 *   and categories) boosted by how often each app has been launched, so the
 *   things you use float up. Arrow keys move the selection, Enter launches,
 *   right click pins to the strip up top.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

Panel {
  id: root
  anchors.fill: parent

  property color textColor: Config.text
  property color subColor: Config.subtext
  property var allApps: []
  property string filterText: ""
  property var filteredApps: []
  property int currentEntry: -1

  // pinned app ids, persisted to ~/.cache/shelljar/favorites
  property var pinned: []
  // launch counts, persisted to ~/.cache/shelljar/launcher-usage.json
  property var usage: ({})

  signal closeRequested

  readonly property string cacheDir: (Quickshell.env("HOME") || "/home/user") + "/.cache/shelljar"
  readonly property string favFile: root.cacheDir + "/favorites"
  readonly property string usageFile: root.cacheDir + "/launcher-usage.json"

  // ---- matching ----
  function matchScore(entry, q) {
    if (q === "") return 1
    const fields = [
      entry.name || "",
      entry.genericName || "",
      entry.comment || "",
      (entry.keywords || []).join(" "),
      (entry.categories || []).join(" ")
    ]
    let best = 0
    for (let i = 0; i < fields.length; i++) {
      const f = fields[i].toLowerCase()
      if (f === "") continue
      let s = 0
      if (f === q) s = 1000
      else if (f.indexOf(q) === 0) s = 600
      else if (f.indexOf(q) !== -1) s = 400 - Math.min(200, f.indexOf(q))
      else {
        let j = 0
        for (let k = 0; k < f.length && j < q.length; k++) { if (f[k] === q[j]) j++ }
        if (j === q.length) s = 120
      }
      s -= i * 10 // the name matters more than the category
      if (s > best) best = s
    }
    if (best > 0) best += (root.usage[entry.id] || 0) * 25
    return best
  }

  function rebuildFilter() {
    const q = root.filterText.toLowerCase().trim()
    const scored = []
    for (const entry of root.allApps) {
      const s = root.matchScore(entry, q)
      if (s > 0) scored.push({ e: entry, s: s })
    }
    if (q !== "") scored.sort((a, b) => b.s - a.s)
    else scored.sort((a, b) => (a.e.name || "").localeCompare(b.e.name || ""))
    root.filteredApps = scored.map(x => x.e)
    root.currentEntry = root.filteredApps.length > 0 ? 0 : -1
  }

  function byId(id) {
    for (const e of root.allApps) { if (e.id === id) return e }
    return null
  }

  function bumpUsage(id) {
    if (!id) return
    const u = Object.assign({}, root.usage)
    u[id] = (u[id] || 0) + 1
    root.usage = u
    usageStore.setText(JSON.stringify(u))
  }

  function launch(entry) {
    if (!entry) return
    root.bumpUsage(entry.id)
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

  function loadUsage(text) {
    try {
      root.usage = (text && text.length) ? JSON.parse(text) : ({})
    } catch (e) {
      root.usage = ({})
    }
  }

  function nextEntry(dir) {
    const n = root.filteredApps.length
    if (n === 0) return
    root.currentEntry = (root.currentEntry + dir + n) % n
    list.positionViewAtIndex(root.currentEntry, ListView.Contain)
  }

  function handleKey(event) {
    switch (event.key) {
    case Qt.Key_Return:
    case Qt.Key_Enter:
      event.accepted = true
      root.launchIndex(root.currentEntry)
      break
    case Qt.Key_Down:
      event.accepted = true; root.nextEntry(1); break
    case Qt.Key_Up:
      event.accepted = true; root.nextEntry(-1); break
    default:
      break
    }
  }

  function loadApps() {
    root.allApps = DesktopEntries.applications.values.filter(e => !e.noDisplay)
    root.rebuildFilter()
  }

  Component.onCompleted: {
    root.loadApps()
    if (typeof usageStore.text === "function") root.loadUsage(usageStore.text())
    usageStore.reload()
    favFileView.reload()
    Qt.callLater(() => searchBox.forceActiveFocus())
  }

  onOpenChanged: {
    if (root.open) {
      searchBox.text = ""
      root.filterText = ""
      root.rebuildFilter()
      Qt.callLater(() => searchBox.forceActiveFocus())
    }
  }

  // the application list arrives asynchronously, so reload it when it changes
  Connections {
    target: DesktopEntries && DesktopEntries.applications ? DesktopEntries.applications : null
    function onValuesChanged() { root.loadApps() }
  }

  FileView {
    id: favFileView
    path: root.favFile
    printErrors: false
    onLoaded: root.loadPinned(text())
  }

  FileView {
    id: usageStore
    path: root.usageFile
    blockLoading: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadUsage(text())
  }

  Keys.onPressed: root.handleKey(event)
  Keys.onEscapePressed: root.closeRequested()

  ColumnLayout {
    anchors.fill: parent
    spacing: Math.round(10 * Config.uiScale)

    // ---- search bar ----
    Surface {
      Layout.fillWidth: true
      implicitHeight: Math.round(36 * Config.uiScale)
      radius: Config.radiusSm
      fillTop: Config.surfaceHigh
      fillBot: Config.surfaceMid
      border.color: searchBox.activeFocus ? Config.accent : Config.outlineSoft

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Math.round(12 * Config.uiScale)
        anchors.rightMargin: Math.round(12 * Config.uiScale)
        spacing: Math.round(8 * Config.uiScale)

        GlyphIcon {
          Layout.alignment: Qt.AlignVCenter
          width: Math.round(15 * Config.uiScale)
          height: width
          name: "search"
          color: Config.subtext
          stroke: 1.8
        }

        TextField {
          id: searchBox
          Layout.fillWidth: true
          color: root.textColor
          placeholderText: "Search apps"
          placeholderTextColor: root.subColor
          background: Item {}
          font.pixelSize: Config.fsMedium
          verticalAlignment: Text.AlignVCenter
          Keys.onUpPressed: root.nextEntry(-1)
          Keys.onDownPressed: root.nextEntry(1)
          Keys.onReturnPressed: root.launchIndex(root.currentEntry)
          Keys.onEscapePressed: root.closeRequested()
          onTextChanged: { root.filterText = text; root.rebuildFilter() }
        }
      }
    }

    // ---- pinned strip (hidden when nothing is pinned or while searching) ----
    Flow {
      visible: root.pinned.length > 0 && root.filterText === ""
      Layout.fillWidth: true
      spacing: Math.round(8 * Config.uiScale)

      Repeater {
        model: root.pinned

        delegate: Item {
          required property string modelData
          readonly property var app: root.byId(modelData)
          width: Math.round(46 * Config.uiScale)
          height: width
          visible: app !== null

          Surface {
            anchors.fill: parent
            radius: Config.radiusSm
            interactive: true
            hovered: pinHover.containsMouse
            fillTop: Config.surfaceMid
            fillBot: Config.surfaceLow
          }

          IconImage {
            anchors.centerIn: parent
            width: Math.round(26 * Config.uiScale)
            height: Math.round(26 * Config.uiScale)
            asynchronous: true
            source: (app && app.icon) ? Quickshell.iconPath(app.icon, "image-missing") : ""
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

    // ---- results ----
    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      ShellText {
        anchors.centerIn: parent
        visible: root.filteredApps.length === 0
        text: root.filterText.length ? "No matches" : "No apps found"
        color: root.subColor
        font.pixelSize: Config.fsSmall
      }

      ListView {
        id: list
        anchors.fill: parent
        clip: true
        model: root.filteredApps
        spacing: Math.round(4 * Config.uiScale)
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: root.currentEntry

        delegate: Surface {
          id: row
          required property var modelData
          required property int index
          width: list.width
          height: Math.round(44 * Config.uiScale)
          radius: Config.radiusSm
          interactive: true
          hovered: rowArea.containsMouse
          active: index === root.currentEntry
          fillTop: index === root.currentEntry ? Config.surfaceHigh : Config.surfaceMid
          fillBot: index === root.currentEntry ? Config.surfaceHigh : Config.surfaceLow

          Item {
            anchors.fill: parent
            anchors.leftMargin: Math.round(10 * Config.uiScale)
            anchors.rightMargin: Math.round(10 * Config.uiScale)

            IconImage {
              id: appIcon
              anchors.verticalCenter: parent.verticalCenter
              width: Math.round(26 * Config.uiScale)
              height: width
              asynchronous: true
              source: modelData.icon ? Quickshell.iconPath(modelData.icon, "image-missing") : ""
            }

            ColumnLayout {
              anchors.left: appIcon.right
              anchors.leftMargin: Math.round(10 * Config.uiScale)
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: 0

              ShellText {
                Layout.fillWidth: true
                text: modelData.name
                color: root.textColor
                font.pixelSize: Config.fsSmall
                elide: Text.ElideRight
              }
              ShellText {
                Layout.fillWidth: true
                visible: text.length > 0
                text: modelData.genericName || (modelData.categories ? modelData.categories.join(", ") : "")
                color: root.subColor
                font.pixelSize: Config.fsTiny
                elide: Text.ElideRight
              }
            }

            GlyphIcon {
              anchors.verticalCenter: parent.verticalCenter
              anchors.right: parent.right
              width: Math.round(12 * Config.uiScale)
              height: width
              visible: root.isPinned(modelData.id)
              name: "pin"
              color: Config.accent
              stroke: 2
            }
          }

          MouseArea {
            id: rowArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onPositionChanged: if (hoverEnabled && containsMouse) root.currentEntry = index
            onClicked: event => {
              if (event.button === Qt.RightButton) { root.togglePinned(modelData); root.currentEntry = index }
              else root.launchIndex(index)
            }
          }
        }
      }
    }

    // ---- hint ----
    ShellText {
      Layout.fillWidth: true
      text: "Psst.. Right-click an app to pin it <Jar!~>"
      color: root.subColor
      font.pixelSize: Config.fsTiny
      horizontalAlignment: Text.AlignHCenter
    }
  }
}
