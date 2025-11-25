import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    id: root
    property string sysDepartListUrl: "/sys/sysDepart/list"
    property var sysDepartListListener: sysDepartListRequest //部门控件查询回调

    function sysDepartListRequest(control, queryParams, display) {
        var callable = comNetworkSysDepartList.createObject(root, {control: control, display: display})
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + sysDepartListUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)

        for(var key in queryParams) {
            networkParams.addQuery(key, queryParams[key])
        }

        networkParams.go(callable)
    }

    Component {
        id: comNetworkSysDepartList
        FluNetworkCallable{
            property var control
            property var display
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
                        showError(qsTr(sysDepartListUrl + " failed: " + result))
                        return
                    }

                    control.sysDepartListResp(jsResult.result, display)
                }
        }
    }

    FluMultilineTextBox {
        id: control
        anchors.fill: parent
        readOnly: true
        placeholderText: "请选择"
        onPressed: {
            selectBiz.queryClickImpl()
            selectBiz.open()
        }

        function sysDepartListResp(result, display) {
            if (display) {
                var choosed = []
                text = result.records.map(function(item) {
                    choosed.push({id: item.id, name: item.departName})
                    return item[display]
                 }).join(", ")
                selectBiz.initChoosed(choosed)
                return
            }

            result = Object.assign({}, result)
            result.records = result.records.map(function(item) {
                return {id: item.id, name: item.departName}
            })
            selectBiz.loadData(result)
        }

        FluSelectBizDialog{
            id: selectBiz
            title: qsTr("部门选择")
            choosedTitle: qsTr("已选部门")
            strId: qsTr("部门代号")
            name: qsTr("部门名称")
            queryClickListener: queryClickImpl
            buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
            onNegativeClicked: {
            }
            onPositiveClicked:
                (data)=>{
                    control.text = data.map(function(item) {
                       return item.name
                    }).join(", ")

                    value = data.map(function(item) {
                       return item.id
                    }).join(",")
                }

            function queryClickImpl() {
                var queryParams = {
                    pageNo: selectBiz.getPageNo()
                    , pageSize: selectBiz.getPageSize()
                    , field: "id,departName"
                    , order: "desc"
                    , colunm: "orgCode"
                }
                var strId = selectBiz.getTextBoxId()
                if (strId !== "") {
                    strId = "*" + strId + "*"
                    queryParams["id"] = strId
                }
                var name = selectBiz.getTextBoxName()
                if (name !== "") {
                    name = "*" + name + "*"
                    queryParams["departName"] = name
                }

                sysDepartListListener(control, queryParams)
            }
        }
    }

    function initDisplay() {
        control.text = value
        if (!control.text) {
            return
        }

        var display = "departName"
        var queryParams = {
            pageNo: 1
            , pageSize: control.text.split(",").length
            , id: control.text
        }

        sysDepartListListener(control, queryParams, display)
    }
}
