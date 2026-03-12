import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluCheckComboBox {
    id: control
    anchors.fill: parent
    placeholderText: qsTr("请选择")
    listMore: true
    property var listUrl: qsTr("")
    property var valField: qsTr("")
    property var txtField: qsTr("")
    property var textValueMap: ({})
    signal dictItemsUpdated(string key, var dictItems) //字典数据更新通知

    Component.onCompleted: {
        var componentProps = config.componentProps
        if (componentProps) {
            listUrl = componentProps.listUrl
            valField = componentProps.valField
            txtField = componentProps.txtField
            listUrlRequest([valField, txtField], 1)
        }
    }

    onMoreButtonClicked: {
        listUrlRequest([valField, txtField], ++listPageNo)
    }

    onSelectionChanged: {
        var texts = control.displayText.split(", ")
        value = texts.map(function(text) {
            return textValueMap[text]
         }).join(",")
    }

    FluNetworkCallable{
        id: listUrlCallable
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
                    showError(qsTr(listUrl + " failed: " + result))
                    return
                }

                dictItemsUpdated(listUrl, jsResult.result)
            }
    }

    Connections{
        target: control
        function onDictItemsUpdated(key, dictItems) {
            if (control.listUrl === key) {
                control.model = control.model.concat(dictItems.records.map(function(item) {
                    var text = item[control.txtField]
                    var value = item[control.valField]
                    control.textValueMap[text] = value
                    return {text: text, value: value}
                }))
                control.update()
                initDisplay()
            }
        }
    }

    function listUrlRequest(fields, pageNo) {
        FluNetwork.get(GlobalModel.basicUrl + listUrl)
        .bind(control)
        .addHeader("S-Token",GlobalModel.token)
        .addQuery("superQueryMatchType", "or")
        .addQuery("field", fields.toString())
        .addQuery("pageNo", pageNo)
        .addQuery("pageSize", 20)
        .go(listUrlCallable)
    }

    function initDisplay() {
        if (!value) {
            return
        }

        control.selectedItems = []
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
