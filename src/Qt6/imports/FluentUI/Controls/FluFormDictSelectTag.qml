import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    FluComboBox {
        id: control
        anchors.fill: parent
        model: ListModel {ListElement { text: ""; title: ""; value: "" }}
        textRole: "text"
        valueRole: "value"
        // property var dictItems: GlobalModel.sysAllDictItems[dictCode]
        property var dictCode: {
            var componentProps = config.componentProps
            if (componentProps && componentProps.dictCode) {
                // dictItemsMap[componentProps.dictCode] = true
                return componentProps.dictCode
            }
        }

        onActivated:{
            value = control.currentValue
        }

        // onDictItemsChanged: {
        Component.onCompleted: {
            var dictItems = GlobalModel.sysAllDictItems[dictCode]
            model.append(dictItems)
        }
    }

    function initDisplay() {
        for(var i = 0; i < control.model.count; i++) {
            var item = control.model.get(i)
            if (item.value === value) {
                control.currentIndex = i
                break
            }
        }
    }
}
