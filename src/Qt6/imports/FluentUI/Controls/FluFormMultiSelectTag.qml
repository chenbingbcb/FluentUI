import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    FluCheckComboBox {
        id: control
        anchors.fill: parent
        placeholder: qsTr("请选择")
        property var textValueMap: ({})

        Component.onCompleted: {
            var componentProps = config.componentProps
            if (componentProps && componentProps.dictCode) {
                var dictItems = GlobalModel.sysAllDictItems[componentProps.dictCode] || []
                model = dictItems.map(function(item) {
                    textValueMap[item.text] = item.value
                    return {text: item.text, value: item.value}
                })
            }
        }

        onSelectionChanged: {
            var texts = control.displayText.split(", ")
            value = texts.map(function(text) {
                return textValueMap[text]
             }).join(",")
        }
    }

    function initDisplay() {
        if (!value) {
            return
        }

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
