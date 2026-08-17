import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

// App launcher shown as a grid. Apps come from quickshell's DesktopEntries.
Rectangle {
  id: root

  property bool open: false
  width: Config.launcherWidth
  height: Config.launcherHeight
  radius: Config.cornerRadius
  color: Config.bg
  border.color: Qt.rgba(1, 1, 1, 0.08)

  property color textColor: Config.text
  property color subColor: Config.subtext

  property var allApps: [] // array of DesktopEntry
  property string filterText: ""
  property var filteredApps: []

  function rebuildFilter() {
    const q = root.filterText.toLowerCase().trim()
    const out = []
    for (const entry of root.allApps) {
      if (q === "" || entry.name.toLowerCase().includes(q)
        || entry.genericName.toLowerCase().includes(q)) out.push(entry)
    }
    root.filteredApps = out
  }

  Component.onCompleted: {
    const apps = DesktopEntries.applications.values
      .filter(e => !e.noDisplay)
    root.allApps = apps
    root.rebuildFilter()
  }

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
      border.color: Qt.rgba(1, 1, 1, 0.06)

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
          onTextChanged: { root.filterText = text; root.rebuildFilter() }
          Keys.onEscapePressed: root.open = false
        }
      }
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

      delegate: Item {
        required property var modelData
        width: grid.cellWidth
        height: grid.cellHeight

        Rectangle {
          anchors.fill: parent
          anchors.margins: 4
          radius: 10
          color: "transparent"

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
            onEntered: parent.color = Config.surface
            onExited: parent.color = "transparent"
            onClicked: {
              modelData.execute()
              root.open = false
            }
          }
        }
      }
    }
  }
}