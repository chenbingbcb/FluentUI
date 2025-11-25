import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    FluTextBox {
        id: control
        anchors.fill: parent
        placeholderText: qsTr("请输入")

        onTextChanged: {
            value = control.text
        }
    }

    function initDisplay() {
        control.text = value
    }
}
