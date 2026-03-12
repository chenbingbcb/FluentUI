import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

Item {
    id: control
    property string listUrl: "/online/genFormHead/list"
    property alias displayText: textBox.text
    property alias placeholderText: textBox.placeholderText

    function formListRequest(queryParams, display) {
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + listUrl)
        .bind(control)
        .addHeader("S-Token", GlobalModel.token)

        for(var key in queryParams) {
            networkParams.addQuery(key, queryParams[key])
        }

        formListCallable.display = display
        networkParams.go(formListCallable)
    }

    FluNetworkCallable {
        id: formListCallable
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
                    showError(qsTr(listUrl + " failed: " + result))
                    return
                }

                formListResp(jsResult.result, display)
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
        title: qsTr("选择")
        choosedTitle: qsTr("已选")
        columnConfig: [
            {
                title: "表单名称",
                dataIndex: 'name',
                width: 300
            },
            {
                title: "表单编码",
                dataIndex: 'code',
                width: 200
            },
        ]
        isSingleSelect: true
        queryClickListener: queryClickImpl
        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
        onNegativeClicked: {
        }
        onPositiveClicked:
            (data)=>{
                textBox.text = data.map(function(item) {
                   return item["name"]
                }).join(", ")

                value = data.map(function(item) {
                   return item.id
                }).join(",")
            }

        function queryClickImpl() {
            var queryParams = {
                pageNo: selectBiz.getPageNo()
                , pageSize: selectBiz.getPageSize()
                , field: "id,name,code"
                , order: "desc"
                , colunm: "createTime"
            }
            var strId = selectBiz.getTextBoxId()
            if (strId !== "") {
                strId = "*" + strId + "*"
                queryParams["code"] = strId
            }
            var name = selectBiz.getTextBoxName()
            if (name !== "") {
                name = "*" + name + "*"
                queryParams["name"] = name
            }

            formListRequest(queryParams, false)
        }
    }

    function formListResp(result, display) {
        if (display) {
            var choosed = []
            textBox.text = result.records.map(function(item) {
                choosed.push(item)
                return item["name"]
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

        formListRequest(queryParams, true)
    }
}
