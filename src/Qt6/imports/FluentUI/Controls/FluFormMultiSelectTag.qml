import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluCheckComboBox {
    id: control
    anchors.fill: parent
    placeholder: qsTr("请选择")
    property var textValueMap: ({})
    property var dictItems

    Component.onCompleted: {
        var componentProps = config.componentProps
        if (componentProps && componentProps.dictCode) {
            var dictItems = GlobalModel.sysAllDictItems[componentProps.dictCode]
            if (dictItems) {
                control.dictItems = dictItems
            } else {
                getDictItemsCallable.httpRequest(componentProps.dictCode)
            }
        }
    }

    onSelectionChanged: {
        var texts = control.displayText.split(", ")
        value = texts.map(function(text) {
            return textValueMap[text]
         }).join(",")
    }

    onDictItemsChanged: {
        model = dictItems.map(function(item) {
            textValueMap[item.text] = item.value
            return {text: item.text, value: item.value}
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
