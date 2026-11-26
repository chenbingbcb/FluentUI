import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id: root

    Component.onCompleted: {
        loaderTablePane.sourceComponent = comTablePane
    }

    FluLoader {
        id: loaderTablePane
        Layout.fillWidth: true
    }

    Component {
        id: comTablePane
        FluTablePane {
            columnsUrl: "/online/genFormAPI/getColumns/1943596327446851585/1"
            formConfigUrl: "/online/genFormAPI/getFormConfig/1944657991611301890/1"
            listUrl: "/online/sysReportHead/list"
            deleteUrl: "/online/sysReportHead/deleteByParams"
            addUrl: "/online/sysReportHead/add"
            editUrl: "/online/sysReportHead/updateMainSub"
            queryByIdUrl: "/online/sysReportHead/queryByParams"
            updateAllUrl: "/online/sysReportHead/updateAll"
            formActionDelegate: comFormCustomAction
            formRepeaterBottomDelegate: comRepeaterBottom
        }
    }

    Component {
        id: comFormCustomAction
        RowLayout {
            Layout.fillWidth: true

            FluFilledButton {
                text: qsTr("解析sql")
                visible: formPane.title === qsTr("修改")
                onClicked: {
                    parseSqlCallable.httpRequest()
                }
            }

            FluNetworkCallable{
                id: parseSqlCallable
                property string postfixUrl: "/online/sysReportHead/parseSql"
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
                            loaderTablePane.item._to.showError(qsTr(postfixUrl + " failed: " + result))
                            return
                        }

                        if (!jsResult.result || !jsResult.result.length) {
                            return
                        }

                        var columnMap = {}
                        var childTablePane = formPane.tablePanes[0]
                        var tableView = childTablePane.tableView
                        for (var i = 0; i < tableView.rows; i++) {
                            var obj = tableView.getRow(i)
                            columnMap[obj.fieldName] = obj
                        }

                        jsResult.result.forEach(function(item) {
                            if (!columnMap[item.fieldName]) { //无需二次数组遍历
                                var uuid = FluTools.uuid()
                                var rowObj = {
                                    _key: uuid
                                    , _minimumHeight: childTablePane.defaultCellHeight
                                    , action: tableView.customItem(childTablePane.rowActionDelegate, {newRow: uuid})
                                }

                                for (var field in childTablePane.editFieldColumn) {
                                    rowObj[field] = item[field] || null
                                }

                                tableView.editedRows[uuid] = tableView.sourceModel.rowCount
                                tableView.appendRow(rowObj)
                            }
                        })
                    }

                function httpRequest() {
                    var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
                    .bind(root)
                    .addHeader("S-Token", GlobalModel.token)

                    var formData = formPane.formData
                    if (formData) {
                        networkParams.addQuery("reportId", formData.id)
                    }
                    networkParams.go(parseSqlCallable)
                }
            }
        }
    }

    Component {
        id: comRepeaterBottom
        FluText {
            text: "1)字段名对应数据库字段;
2)数据库为oracle时,字段名需要大写;
3)groupby最后一个字段非字符型,会被转成字符型"
        }
    }
}
