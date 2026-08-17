import QtQuick
import Quickshell

// ---- shelljar entry ----
// The config root IS the full-screen RootWindow (a PanelWindow), so quickshell
// doesn't wrap it in a FloatingWindow (which showed as a white window).
RootWindow {}