//@ pragma AppId quickshell-share-picker

import QtQuick
import Quickshell

ShellRoot {
    Loader {
        source: Quickshell.env("QSP_SMOKE_MODE") === "1"
            ? "PickerSmokeWindow.qml"
            : "PickerFloatingWindow.qml"
    }
}
