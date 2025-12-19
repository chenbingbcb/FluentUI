import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id:root
    property var tableConfig
    property string tableId: ""
    property string formId: ""
    property string menuId: ""

    property string getColumnsUrl: "/online/genFormAPI/getColumns/%1/%2".arg(tableId).arg(menuId)
    property string getDictItemsUrl: "/sys/dict/getDictItems/"
    property var getDictItemsListener: getDictItemsRequest //字典编码查询回调
    // property var dictItemsMap: ({}) //字典数据
    // property var listUrlMap: ({}) //url数据

    function getColumnsRequest() {
        FluNetwork.get(GlobalModel.basicUrl + getColumnsUrl)
        .addHeader("S-Token", GlobalModel.token)
        .bind(root)
        .go(getColumnsCallable)
    }

    FluNetworkCallable{
        id: getColumnsCallable
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
        onCache:
            (result)=>{
                console.debug("onCache: "+result)
            }
        onSuccess:
            (result)=>{
                var jsResult = JSON.parse(result)
                console.debug(JSON.stringify(jsResult, null, 2))
                if (jsResult.code !== 200) {
                    showError(qsTr(getColumnsUrl + " failed: " + result))
                    return
                }

                tableConfig = jsResult.result
                loaderTablePane.sourceComponent = comTablePane
                loaderTablePane.item.getFormConfigRequest()
            }
    }

    function getDictItemsRequest(dictCode) {
        var callable = comNetworkDictCode.createObject(root, {dictCode: dictCode})
        FluNetwork.get(GlobalModel.basicUrl + getDictItemsUrl + dictCode)
        .addHeader("S-Token",GlobalModel.token)
        .bind(root)
        .go(callable)
    }

    Component {
        id: comNetworkDictCode
        FluNetworkCallable{
            property var dictCode
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
                        showError(qsTr(getDictItemsUrl + " failed: " + result))
                        return
                    }

                    dictItemsUpdated(dictCode, jsResult.result)
                }
        }
    }

    onPageConfigChanged: {
        var paths = pageConfig.path.split("/")
        if (paths && paths.length > 1) {
            formId = paths[paths.length - 1]
            tableId = paths[paths.length - 2]
        }
        menuId = pageConfig.meta.menuId || pageConfig.id
        getColumnsRequest()
    }

    FluLoader {
        id: loaderTablePane
        Layout.fillWidth: true
    }

    Component {
        id: comTablePane
        FluTablePane {
            tableConfig: root.tableConfig
            tableId: root.tableId
            formId: root.formId
            menuId: root.menuId
        }
    }
}
