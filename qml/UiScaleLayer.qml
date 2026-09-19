/***
 *  ╃
 *  .▀▀█▀▀ .
 *    :▓.:
 *  . ▀▀ : ╃
 *   shelljar
 *
 *   UiScaleLayer
 *
 *   Full-screen UI scale calibrator (opened from the control center button).
 *   Keyboard first: A/D or Left/Right nudge the scale in 0.05 steps while the
 *   center preview shows the real clock, pills and a mock menu card at the
 *   current size. Big Small/Large buttons flank the screen edges for mouse
 *   users. Enter saves (persists via ColorService), Esc / clicking away
 *   reverts to the scale the layer opened with.
 ***/
import qs.components
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property bool open: false
  property real initialScale: Config.userScale
  property bool saved: false

  readonly property real minScale: 0.6
  readonly property real maxScale: 2.0
  readonly property real stepSize: 0.05

  // keyboard: arrows or A/D adjust, Enter saves, Esc reverts
  // (generic onPressed: the Keys attached object has no per-letter handlers)
  focus: root.open
  Keys.onPressed: event => {
    switch (event.key) {
    case Qt.Key_Left:
    case Qt.Key_A:
      root.nudge(-1)
      event.accepted = true
      break
    case Qt.Key_Right:
    case Qt.Key_D:
      root.nudge(1)
      event.accepted = true
      break
    case Qt.Key_Return:
    case Qt.Key_Enter:
      root.save()
      event.accepted = true
      break
    case Qt.Key_Escape:
      root.close()
      event.accepted = true
      break
    }
  }

  function nudge(dir) {
    const v = Math.max(root.minScale, Math.min(root.maxScale, Config.userScale + dir * root.stepSize))
    Config.userScale = Math.round(v * 100) / 100
  }

  function save() {
    root.saved = true
    ColorService.setUiScale(Config.userScale)
    root.open = false
  }

  function close() {
    root.open = false
  }

  onOpenChanged: {
    if (root.open) {
      root.saved = false
      root.initialScale = Config.userScale
    } else if (!root.saved) {
      // closed without saving: revert to the scale we opened with
      ColorService.setUiScale(root.initialScale)
    }
  }

  // ---- live preview: real clock + pills + a mock menu card ----
  ColumnLayout {
    anchors.centerIn: parent
    spacing: Math.round(24 * Config.uiScale)

    Clock { Layout.alignment: Qt.AlignHCenter }

    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: Math.round(10 * Config.uiScale)
      VolumeWidget { }
      BatteryWidget { }
      BrightnessWidget { }
    }

    // mock menu card: shows how the pop-out panels will size
    Rectangle {
      Layout.alignment: Qt.AlignHCenter
      width: Config.controlCenterWidth
      implicitHeight: menuPreview.implicitHeight + Math.round(24 * Config.uiScale)
      radius: Config.cornerRadius
      color: Config.bgAlt
      border.color: Config.borderMid

      ColumnLayout {
        id: menuPreview
        anchors.fill: parent
        anchors.margins: Math.round(12 * Config.uiScale)
        spacing: Math.round(8 * Config.uiScale)

        ShellText {
          text: "Menu preview"
          color: root.open ? Config.text : Config.subtext
          font.pixelSize: Config.fsMedium
          font.weight: Font.DemiBold
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: Config.borderSoft }
        ShellText { text: "Volume"; color: Config.subtext; font.pixelSize: Config.fsTiny }
        // static sample bar (not interactive, just shows sizing)
        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: Math.round(12 * Config.uiScale)
          radius: height / 2
          color: Config.surfaceAlt
          Rectangle {
            width: parent.width * 0.55
            height: parent.height
            radius: height / 2
            color: Config.accent
          }
        }
        ShellText {
          text: "Aa Menu rows and text scale too"
          color: Config.text
          font.pixelSize: Config.fsSmall
        }
      }
    }

    // prompt bar: current value + keys hint
    Rectangle {
      Layout.alignment: Qt.AlignHCenter
      width: promptRow.implicitWidth + Math.round(28 * Config.uiScale)
      implicitHeight: promptRow.implicitHeight + Math.round(14 * Config.uiScale)
      radius: Config.cornerRadius
      color: Config.bg
      border.color: Config.borderStrong

      RowLayout {
        id: promptRow
        anchors.centerIn: parent
        spacing: Math.round(10 * Config.uiScale)

        ShellText {
          text: "UI scale " + Math.round(Config.userScale * 100) + "%"
          color: Config.accent
          font.pixelSize: Config.fsSmall
          font.weight: Font.DemiBold
        }
        ShellText {
          text: "·  A/D or ←/→ adjust  ·  Enter save  ·  Esc cancel"
          color: Config.subtext
          font.pixelSize: Config.fsSmall
        }
      }
    }
  }

  // block interaction with the preview widgets (wheel/clicks must not change
  // real volume/brightness while calibrating); clicks fall to the scrim below
  MouseArea {
    anchors.fill: parent
    enabled: root.open
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    onClicked: event => {
      // only swallow: clicking the empty space should cancel via the scrim,
      // so re-post nothing and let it pass by not accepting
      event.accepted = false
    }
    onWheel: event => { event.accepted = true }
  }

  // ---- Small / Large side buttons (power-menu look, label only) ----
  component SideButton: Rectangle {
    id: btn
    property string label
    property int dir
    width: Config.sessionButtonSize
    height: Config.sessionButtonSize
    radius: Math.round(Config.cornerRadius * 1.5)
    color: btnHover.containsMouse ? Config.surfaceAlt : Config.surface
    border.width: 1
    border.color: Config.borderStrong
    // dim when the scale is pinned at that bound
    opacity: (dir < 0 && Config.userScale <= root.minScale + 0.001)
      || (dir > 0 && Config.userScale >= root.maxScale - 0.001) ? 0.45 : 1

    ShellText {
      anchors.centerIn: parent
      text: btn.label
      color: Config.text
      font.pixelSize: Config.fsMedium + 2
      font.weight: Font.DemiBold
    }

    MouseArea {
      id: btnHover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.nudge(btn.dir)
    }
  }

  SideButton {
    label: "Small"
    dir: -1
    anchors.left: parent.left
    anchors.leftMargin: Math.round(32 * Config.uiScale)
    anchors.verticalCenter: parent.verticalCenter
  }

  SideButton {
    label: "Large"
    dir: 1
    anchors.right: parent.right
    anchors.rightMargin: Math.round(32 * Config.uiScale)
    anchors.verticalCenter: parent.verticalCenter
  }
}
