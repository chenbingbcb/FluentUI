import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

Rectangle {
    anchors.fill: parent
    radius: 4
    color: FluTheme.dark ? Qt.rgba(62/255,62/255,62/255,1) : Qt.rgba(254/255,254/255,254/255,1)
    FluRadioButtons {
        id: control
        anchors.verticalCenter: parent.verticalCenter
        orientation: Qt.Horizontal

        Component.onCompleted: {
            var dictItems = []
            var componentProps = config.componentProps
            if (componentProps) {
                if (componentProps.dictCode) {
                    dictItems = GlobalModel.sysAllDictItems[componentProps.dictCode] || []
                } else if (componentProps.options && componentProps.options.length) {
                    dictItems = componentProps.options.map(function(option) {
                        return { text: option.label, value: option.value }
                     })
                }
            }

            dictItems.forEach(function(item) {
                var obj = Qt.createQmlObject("import FluentUI; FluRadioButton{property var value}", control)
                obj.text = item.text
                obj.value = item.value
                obj.clickListener = function() {
                    for(var i = 0; i < control.buttons.length; i++){
                        var button = control.buttons[i]
                        if(this === button){
                            control.currentIndex = i
                            value = button.value
                            break
                        }
                    }
                }
                control.buttons.push(obj)
            })
        }
    }

    function initDisplay() {
        for(var i = 0; i < control.buttons.length; i++){
            var button = control.buttons[i]
            if (button.value === value) {
                control.currentIndex = i
                break
            }
        }
    }
}
