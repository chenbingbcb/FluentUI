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

    onActivated:{
        value = control.currentValue
    }

    onDictItemsChanged: {
        model.append(dictItems)
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
        for(var i = 0; i < control.model.count; i++) {
            var item = control.model.get(i)
            if (item.value + "" === value + "") { //都转成字符串判断 因为web端"1"和1相等
                control.currentIndex = i
                break
            }
        }
    }
}
