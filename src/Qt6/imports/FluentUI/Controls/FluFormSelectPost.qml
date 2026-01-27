import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

Item {
    id: control
    property string sysPostListUrl: "/sys/sysPost/list"

    function sysPostListRequest(control, queryParams, display) {
        sysPostListCallable.control = control
        sysPostListCallable.display = display
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + sysPostListUrl)
        .bind(control)
        .addHeader("S-Token", GlobalModel.token)

        for(var key in queryParams) {
            networkParams.addQuery(key, queryParams[key])
        }

        networkParams.go(sysPostListCallable)
    }

    Component {
        id: sysPostListCallable
        FluNetworkCallable {
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
                        showError(qsTr(sysPostListUrl + " failed: " + result))
                        return
                    }

                    control.sysPostListResp(jsResult.result, display)
                }
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
        title: qsTr("职称选择")
        choosedTitle: qsTr("已选职称")
        columnConfig: [
            {
                title: "职称名称",
                dataIndex: 'name',
                width: 150
            },
            {
                title: "职称编码",
                dataIndex: 'code',
                width: 150
            },
            {
                title: "成员",
                dataIndex: 'member',
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
                , field: "id,name,code,member_dictText"
                , order: "desc"
                , colunm: "orgCode"
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

            sysPostListRequest(control, queryParams, false)
        }
    }

    function sysPostListResp(result, display) {
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
            , code: textBox.text
        }

        sysPostListRequest(control, queryParams, true)
    }
}
