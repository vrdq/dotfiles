pragma ComponentBehavior: Bound

import Quickshell

Scope {
    id: root

    FloatingWindow {
        id: surface

        title: "Screen Share Picker"
        color: "transparent"
        visible: content.windowModelReady
        implicitWidth: 800
        implicitHeight: 500

        PickerWindow {
            id: content

            anchors.fill: parent
            hostWindow: surface
        }

        onClosed: content.cancel()
    }
}
