import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluPasswordBox {
    id: control
    anchors.fill: parent
    placeholderText: qsTr("请输入")

    onTextChanged: {
        value = control.text
    }

    Component.onCompleted: {
        var componentProps = config.componentProps
        if (componentProps && componentProps.placeholderText) {
            control.placeholderText = componentProps.placeholderText
        }
    }

    function initDisplay() {
        control.text = value
        control.ensureVisible(0) //文字太多超框时 让开头可见 而非结尾
    }
}
