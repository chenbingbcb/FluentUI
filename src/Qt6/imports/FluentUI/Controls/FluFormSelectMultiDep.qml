import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    id: control
    property string sysDepartListUrl: "/sys/sysDepart/list"

    function sysDepartListRequest(control, queryParams, display) {
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + sysDepartListUrl)
        .bind(control)
        .addHeader("S-Token", GlobalModel.token)

        for(var key in queryParams) {
            networkParams.addQuery(key, queryParams[key])
        }

        sysDepartListCallable.control = control
        sysDepartListCallable.display = display
        networkParams.go(sysDepartListCallable)
    }

    FluNetworkCallable {
        id: sysDepartListCallable
        property var control
        property var display
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
                    showError(qsTr(sysDepartListUrl + " failed: " + result))
                    return
                }

                control.sysDepartListResp(jsResult.result, display)
            }
    }

    Flickable {
        id: scroll
        clip: true
        anchors.fill: parent
        ScrollBar.vertical: srcollBar
        boundsBehavior: Flickable.StopAtBounds
        TextArea.flickable: FluMultilineTextBox {
            id: textBox
            placeholderText: "请选择"
            readOnly: true
            wrapMode: Text.WrapAnywhere
            activeFocusOnPress: false
            verticalAlignment: TextInput.AlignVCenter
            rightPadding: 12
            onPressed: {
                selectBiz.queryClickImpl()
                selectBiz.open()
            }
        }
    }

    FluScrollBar {
        id: srcollBar
        policy: scroll.contentHeight > scroll.height + 2 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        anchors{
            right: scroll.right
            rightMargin: 1
            top: scroll.top
            bottom: scroll.bottom
            topMargin: 3
            bottomMargin: 3
        }
    }

    FluSelectBizDialog {
        id: selectBiz
        title: qsTr("部门选择")
        choosedTitle: qsTr("已选部门")
        columnConfig: [
            {
                title: "部门名称",
                dataIndex: 'departName',
                width: 300
            },
            {
                title: "部门代号",
                dataIndex: 'id',
                width: 200
            }
        ]
        queryClickListener: queryClickImpl
        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
        onNegativeClicked: {
        }
        onPositiveClicked:
            (data)=>{
                textBox.text = data.map(function(item) {
                   return item[selectBiz.nameKey]
                }).join(", ")

                value = data.map(function(item) {
                   return item[selectBiz.idKey]
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

            sysDepartListRequest(control, queryParams, false)
        }
    }

    function sysDepartListResp(result, display) {
        if (display) {
            var choosed = []
            textBox.text = result.records.map(function(item) {
                choosed.push(item)
                return item["departName"]
             }).join(", ")
            selectBiz.initChoosed(choosed)
            return
        }

        selectBiz.loadData(result)
    }

    function initDisplay() {
        textBox.text = value
        if (!textBox.text) {
            return
        }

        var queryParams = {
            pageNo: 1
            , pageSize: textBox.text.split(",").length
            , id: textBox.text
        }

        sysDepartListRequest(control, queryParams, true)
    }
}
