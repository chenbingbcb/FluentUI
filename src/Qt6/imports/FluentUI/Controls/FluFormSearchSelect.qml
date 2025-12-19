import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    id: root
    signal dictItemsUpdated(string key, var dictItems) //字典数据更新通知

    function listUrlRequest(listUrl, fields, pageNo) {
        var callable = comNetworkListUrl.createObject(root, {listUrl: listUrl})
        FluNetwork.get(GlobalModel.basicUrl + listUrl)
        .bind(root)
        .addHeader("S-Token",GlobalModel.token)
        .addQuery("superQueryMatchType", "or")
        .addQuery("field", fields.toString())
        .addQuery("pageNo", pageNo)
        .addQuery("pageSize", 20)
        .go(callable)
    }

    Component {
        id: comNetworkListUrl
        FluNetworkCallable{
            property var listUrl
            onStart: {
                showLoading()
            }
            onFinish: {
                hideLoading()
                FluTools.deleteLater(this)
            }
            onError:
                (status,errorString,result)=>{
                    showError(qsTr(status+";"+errorString+";"+result))
                }
            onCache:
                (result)=>{
                    console.debug("onCache: "+result)
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
    }

    FluCheckComboBox {
        id: control
        anchors.fill: parent
        placeholder: qsTr("请选择")
        listMore: true
        property var textValueMap: ({})

        Component.onCompleted: {
            var componentProps = config.componentProps
            if (componentProps) {
                listUrl = componentProps.listUrl
                valField = componentProps.valField
                txtField = componentProps.txtField
                listUrlRequest(listUrl, [valField, txtField], 1)
            }
        }

        onMoreButtonClicked: {
            listUrlRequest(listUrl, [valField, txtField], ++listPageNo)
        }

        onSelectionChanged: {
            var texts = control.displayText.split(", ")
            value = texts.map(function(text) {
                return textValueMap[text]
             }).join(",")
        }
    }

    Connections{
        target: root
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
