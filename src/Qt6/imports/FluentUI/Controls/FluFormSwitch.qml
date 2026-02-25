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
            //value真假值各种形式都有
            if (typeof value === "string") {
                value = checked ? "true" : "false"
            } else {
                value = checked ? 1 : 0
            }
        }
    }

    function initDisplay() {
        //value真假值各种形式都有
        if (typeof value === "string") {
            control.checked = value.toLowerCase() === "true"
        } else {
            control.checked = value ? true : false
        }
    }
}
