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
        control.ensureVisible(0) //文字太多超框时 让开头可见 而非结尾
    }
}
