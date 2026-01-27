import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

RowLayout {
    anchors.fill: parent
    FluToggleSwitch {
        id: control
        Layout.alignment: Qt.AlignHCenter
        onClicked: {
            value = checked ? "true" : "false"
        }
    }

    function initDisplay() {
        if (typeof value === "string") {
            control.checked = value.toLowerCase() === "true"
        } else {
            control.checked = false
        }
    }
}
