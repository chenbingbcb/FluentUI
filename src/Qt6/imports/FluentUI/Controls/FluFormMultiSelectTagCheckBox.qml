import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    Rectangle {
        anchors.fill: parent
        radius: 4
        color: FluTheme.dark ? Qt.rgba(62/255,62/255,62/255,1) : Qt.rgba(254/255,254/255,254/255,1)
        RowLayout {
            id: control
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            spacing: 12

            property list<QtObject> buttons

            Component.onCompleted: {
                var componentProps = config.componentProps
                if (componentProps && componentProps.dictCode) {
                    var dictItems = GlobalModel.sysAllDictItems[componentProps.dictCode] || []
                    dictItems.forEach(function(item) {
                        var obj = Qt.createQmlObject("import FluentUI; FluCheckBox{property var value}", control)
                        obj.text = item.text
                        obj.value = item.value
                        obj.Layout.alignment = Qt.AlignVCenter
                        obj.clickListener = function() {
                            obj.checked = !obj.checked
                            value = value || ""
                            if (obj.checked) {
                                if (value.length > 0) {
                                    value += ","
                                }
                                value += obj.value
                            } else {
                                var values = value.split(",")
                                var index = values.indexOf(obj.value)
                                if (index > -1) {
                                    values.splice(index, 1)
                                    value = values.join(",") || null
                                }
                            }
                        }
                        buttons.push(obj)
                    })
                }
            }
        }
    }

    function initDisplay() {
        if (!value) {
            return
        }

        var values = value.split(",")
        values.forEach(function(v) {
            for(var i = 0; i < control.buttons.length; i++) {
                if (control.buttons[i].value === v) {
                    control.buttons[i].checked = true
                    break
                }
            }
        })
    }
}
