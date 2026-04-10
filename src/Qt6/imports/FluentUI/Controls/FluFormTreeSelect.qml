import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluTreeComboBox {
    id: control
    anchors.fill: parent

    Component.onCompleted: {
        var componentProps = config.componentProps || {}
        var replaceFields = componentProps.replaceFields || {}
        if (replaceFields.text) {
            control.textRole = replaceFields.text
        }
        if (replaceFields.value) {
            control.valueRole = replaceFields.value
        }

        if (config.treeList && config.treeList.length) {
            treeView.dataSource = config.treeList
            treeView.allCollapse()
        }

        initDisplay()
    }

    onCurrentValueChanged: {
        value = control.currentValue
    }

    function initDisplay() {
        for(var i = 0; i < control.model.count; i++) {
            var item = control.model.get(i)
            if (item[control.valueRole] === value) { //都转成字符串判断 因为web端"1"和1相等
                control.currentIndex = i
                break
            }
        }
    }
}
