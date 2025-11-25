import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    FluMultilineTextBox {
        id: control
        anchors {
            left: parent.left
            right: parent.right
        }

        wrapMode: Text.WrapAnywhere

        onTextChanged: {
            value = control.text
        }
    }

    function initDisplay() {
        control.text = value
    }
}
