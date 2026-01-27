import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluComboBox {
    id: control
    anchors.fill: parent
    model: ListModel {ListElement { text: ""; title: ""; value: "" }}
    textRole: "text"
    valueRole: "value"

    onActivated:{
        value = control.currentValue
    }

    Component.onCompleted: {
        var componentProps = config.componentProps
        if (componentProps && componentProps.dictCode) {
            var dictItems = GlobalModel.sysAllDictItems[componentProps.dictCode]
            model.append(dictItems)
        }
    }

    function initDisplay() {
        for(var i = 0; i < control.model.count; i++) {
            var item = control.model.get(i)
            if (item.value + "" === value + "") { //都转成字符串判断 因为web端"1"和1相等
                control.currentIndex = i
                break
            }
        }
    }
}
