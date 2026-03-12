import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

Item {
    id: control
    property string listUrl: "/online/authHead/relButton"
    property string formId: ""
    property string tableId: ""
    property alias displayText: textBox.text
    property alias placeholderText: textBox.placeholderText

    function relButtonRequest(queryParams, display) {
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + listUrl)
        .bind(control)
        .addHeader("S-Token", GlobalModel.token)

        networkParams.addQuery("formId", formId)
        networkParams.addQuery("tableId", tableId)

        for(var key in queryParams) {
            networkParams.addQuery(key, queryParams[key])
        }

        relButtonCallable.display = display
        networkParams.go(relButtonCallable)
    }

    FluNetworkCallable {
        id: relButtonCallable
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

                relButtonResp(jsResult.result, display)
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
                title: "权限标识",
                dataIndex: 'permissionTag',
                width: 300
            },
            {
                title: "按钮code",
                dataIndex: 'code',
                width: 200
            },
        ]
        queryClickListener: queryClickImpl
        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
        onNegativeClicked: {
        }
        onPositiveClicked:
            (data)=>{
                textBox.text = data.map(function(item) {
                   return item["permissionTag"]
                }).join(", ")

                value = data.map(function(item) {
                   return item.code
                }).join(",")
            }

        function queryClickImpl() {
            var queryParams = {
                pageNo: selectBiz.getPageNo()
                , pageSize: selectBiz.getPageSize()
                , field: "id,permissionTag,code"
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
                queryParams["permissionTag"] = name
            }

            relButtonRequest(queryParams, false)
        }
    }

    function relButtonResp(result, display) {
        if (display) {
            var choosed = []
            textBox.text = result.records.map(function(item) {
                choosed.push(item)
                return item["permissionTag"]
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
            , code: textBox.text
        }

        relButtonRequest(queryParams, true)
    }
}
