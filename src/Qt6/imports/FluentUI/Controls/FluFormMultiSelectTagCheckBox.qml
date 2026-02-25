import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

Rectangle {
    id: root
    anchors.fill: parent
    radius: 4
    color: FluTheme.dark ? Qt.rgba(62/255,62/255,62/255,1) : Qt.rgba(254/255,254/255,254/255,1)
    property var dictItems

    onDictItemsChanged: {
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
            control.buttons.push(obj)
        })
    }

    FluNetworkCallable{
        id: getDictItemsCallable
        property string dictCode: ""
        onStart: {
            showLoading()
        }
        onFinish: {
            hideLoading()
        }
        onError:
            (status,errorString,result)=>{
                showError(qsTr(status+";"+errorString+";"+result))
            }
        onSuccess:
            (result)=>{
                var jsResult = JSON.parse(result)
                console.debug(JSON.stringify(jsResult, null, 2))
                if (jsResult.code !== 200) {
                    showError(qsTr(dictCode + " failed: " + result))
                    return
                }

                GlobalModel.sysAllDictItems[dictCode] = jsResult.result
                dictItems = jsResult.result
            }

        function httpRequest(dictCode) {
            getDictItemsCallable.dictCode = dictCode
            FluNetwork.get(GlobalModel.basicUrl + "/sys/dict/getDictItems/" + dictCode)
            .bind(root)
            .addHeader("S-Token",GlobalModel.token)
            .go(getDictItemsCallable)
        }
    }

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
                var dictItems = GlobalModel.sysAllDictItems[componentProps.dictCode]
                if (dictItems) {
                    root.dictItems = dictItems
                } else {
                    getDictItemsCallable.httpRequest(componentProps.dictCode)
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
