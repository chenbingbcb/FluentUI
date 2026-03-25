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
            var obj = Qt.createQmlObject("import FluentUI; FluRadioButton{property var value}", control)
            obj.text = item.text
            obj.value = item.value
            obj.clickListener = function() {
                for(var i = 0; i < control.buttons.length; i++){
                    var button = control.buttons[i]
                    if(this === button){
                        value = button.value
                        control.currentIndex = i
                        break
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

    FluRadioButtons {
        id: control
        anchors.verticalCenter: parent.verticalCenter
        orientation: Qt.Horizontal

        onCurrentIndexChanged: {
            if (config.updateSchema) {
                updateSchema(value)
            }
        }

        Component.onCompleted: {
            var componentProps = config.componentProps
            if (componentProps) {
                if (componentProps.dictCode) {
                    var dictItems = GlobalModel.sysAllDictItems[componentProps.dictCode]
                    if (dictItems) {
                        root.dictItems = dictItems
                    } else {
                        getDictItemsCallable.httpRequest(componentProps.dictCode)
                    }
                } else if (componentProps.options && componentProps.options.length) {
                    root.dictItems = componentProps.options.map(function(option) {
                        return { text: option.label, value: option.value }
                     })
                }
            }
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
