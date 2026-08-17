import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import Quickshell.Widgets

// App launcher shown as a grid. Fed by scripts/shjapps (TSV: Name Exec Icon).
Rectangle {
  id: root

  property bool open: false
  width: Config.launcherWidth
  height: Config.launcherHeight
  radius: Config.cornerRadius
  color: Config.bg
  border.color: Qt.rgba(1,1,1,0.08)

  property color textColor: Config.text
  property color subColor: Config.subtext

  property var allApps: []       // array of [name, exec, icon]
  property string filterText: ""
  property var filteredApps: []

  function loadApps() { appProc.exec(["sh", "-c", "shjapps"]) }
  function applyFilter() {
    const q = root.filterText.toLowerCase().trim()
    const out = []
    for (const a of root.allApps) {
      if (q === "" || a[0].toLowerCase().includes(q)) out.push(a)
    }
    root.filteredApps = out
  }

  Component.onCompleted: loadApps()

  Process {
    id: appProc
    stdout: StdioCollector {
      onStreamFinished: {
        const out = []
        for (const ln of (text || "").split("\n")) {
          const p = ln.split("\t")
          if (p.length >= 2 && p[0] !== "") out.push(p)
        }
        root.allApps = out
        root.applyFilter()
      }
    }
  }

  Process { id: launchProc }

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
      border.color: Qt.rgba(1,1,1,0.06)

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8
        Text { text: "🔍"; color: root.subColor; font.pixelSize: 12 }
        TextField {
          id: searchBox
          Layout.fillWidth: true
          color: root.textColor
          placeholderText: "Search apps…"
          placeholderTextColor: root.subColor
          background: Item {}
          font.pixelSize: 12
          onTextChanged: { root.filterText = text; root.applyFilter() }
          Keys.onEscapePressed: root.open = false
        }
      }
    }

    // grid
    GridView {
      id: grid
      Layout.fillWidth: true
      Layout.fillHeight: true
      cellWidth: 96
      cellHeight: 88
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
              Layout.preferredWidth: 36
              Layout.preferredHeight: 36
              source: modelData.length >= 3 ? modelData[2] : ""
            }
            Text {
              text: modelData[0]
              color: root.textColor
              font.pixelSize: 10
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
              launchProc.exec(["sh", "-c", modelData[1]])
              root.open = false
            }
          }
        }
      }
    }
  }
}