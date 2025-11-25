import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    FluCheckComboBox {
        id: control
        anchors.fill: parent
        placeholder: qsTr("请选择")
        model: {
            var dictItems = GlobalModel.sysAllDictItems[dictCode]
            model = dictItems.map(function(item) {
                textValueMap[item.text] = item.value
                return {text: item.text, value: item.value}
            })
        }

        property var textValueMap: ({})
        // property var dictItems: GlobalModel.sysAllDictItems[dictCode]
        property var dictCode: {
            var componentProps = config.componentProps
            if (componentProps && componentProps.dictCode) {
                // dictItemsMap[componentProps.dictCode] = true
                return componentProps.dictCode
            }
        }

        onSelectionChanged: {
            var texts = control.displayText.split(", ")
            value = texts.map(function(text) {
                return textValueMap[text]
             }).join(",")
        }

        // onDictItemsChanged: {
        // Component.onCompleted: {
        //     var dictItems = GlobalModel.sysAllDictItems[dictCode]
        //     model = dictItems.map(function(item) {
        //         textValueMap[item.text] = item.value
        //         return {text: item.text, value: item.value}
        //     })
        // }
    }

    function initDisplay() {
        if (!value) {
            return
        }

        // clearValues()
        // var dictItems = GlobalModel.sysAllDictItems[dictCode]
        // model = dictItems.map(function(item) {
        //     textValueMap[item.text] = item.value
        //     return {text: item.text, value: item.value}
        // })

        var values = value.split(",")
        values.forEach(function(v) {
            for(var i = 0; i < control.model.length; i++) {
                if (control.model[i].value === v) {
                    control.toggleSelection(control.model[i])
                    break
                }
            }
        })
    }
}
