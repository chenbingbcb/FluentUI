import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    Rectangle {
        anchors.fill: parent
        FluRadioButtons {
            id: radioButtons
            orientation: Qt.Horizontal
            // property var dictItems: GlobalModel.sysAllDictItems[dictCode]
            property var dictCode: {
                var componentProps = config.componentProps
                if (componentProps && componentProps.dictCode) {
                    // dictItemsMap[componentProps.dictCode] = true
                    return componentProps.dictCode
                }
            }

            // onDictItemsChanged: {
            Component.onCompleted: {
                radioButtons.buttons = []
                var dictItems = GlobalModel.sysAllDictItems[dictCode] || []
                dictItems.forEach(function(item) {
                    var obj = Qt.createQmlObject("import FluentUI; FluRadioButton{property var value}", radioButtons)
                    obj.text = item.text
                    obj.value = item.value
                    obj.clickListener = function() {
                        for(var i = 0; i < radioButtons.buttons.length; i++){
                            var button = radioButtons.buttons[i]
                            if(this === button){
                                radioButtons.currentIndex = i
                                value = button.value
                                break
                            }
                        }
                    }
                    radioButtons.buttons.push(obj)
                })
            }
        }
    }

    function initDisplay() {
        for(var i = 0; i < radioButtons.buttons.length; i++){
            var button = radioButtons.buttons[i]
            if (button.value === value) {
                radioButtons.currentIndex = i
                break
            }
        }
    }
}
