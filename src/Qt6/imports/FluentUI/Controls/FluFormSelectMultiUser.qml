import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

Item {
    id: control
    property string listUrl: "/sys/user/list"
    property alias displayText: textBox.text
    property alias placeholderText: textBox.placeholderText

    function sysUserListRequest(queryParams, display) {
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + listUrl)
        .bind(control)
        .addHeader("S-Token", GlobalModel.token)

        for(var key in queryParams) {
            networkParams.addQuery(key, queryParams[key])
        }

        sysUserListCallable.display = display
        networkParams.go(sysUserListCallable)
    }

    FluNetworkCallable {
        id: sysUserListCallable
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

                sysUserListResp(jsResult.result, display)
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
        title: qsTr("用户选择")
        choosedTitle: qsTr("已选用户")
        columnConfig: [
            {
                title: "姓名",
                dataIndex: 'realname',
                width: 150
            },
            {
                title: "账号",
                dataIndex: 'username',
                width: 150
            },
            {
                title: "部门",
                dataIndex: 'orgCodeTxt',
                width: 200
            }
        ]
        isMoreQuery: true
        queryClickListener: queryClickImpl
        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
        onNegativeClicked: {
        }
        onPositiveClicked:
            (data)=>{
                textBox.text = data.map(function(item) {
                   return item["realname"]
                }).join(", ")

                value = data.map(function(item) {
                   return item.username
                }).join(",")
            }

        function queryClickImpl() {
            var queryParams = {
                pageNo: selectBiz.getPageNo()
                , pageSize: selectBiz.getPageSize()
                , field: "id,realname,username,orgCodeTxt"
                , order: "desc"
                , colunm: "createTime"
            }
            var strId = selectBiz.getTextBoxId()
            if (strId !== "") {
                strId = "*" + strId + "*"
                queryParams["username"] = strId
            }
            var name = selectBiz.getTextBoxName()
            if (name !== "") {
                name = "*" + name + "*"
                queryParams["realname"] = name
            }
            var sex = selectBiz.getComboBoxSex()
            if (sex !== 0) {
                queryParams["sex"] = sex
            }
            var strBirthday = selectBiz.getCalendarBirthday()
            if (strBirthday !== "") {
                queryParams["birthday"] = strBirthday
            }
            var strPhone = selectBiz.getTextBoxPhone()
            if (strPhone !== "") {
                strPhone = "*" + strPhone + "*"
                queryParams["phone"] = strPhone
            }

            sysUserListRequest(queryParams, false)
        }
    }

    function sysUserListResp(result, display) {
        if (display) {
            var choosed = []
            textBox.text = result.records.map(function(item) {
                choosed.push(item)
                return item["realname"]
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
            , username: textBox.text
        }

        sysUserListRequest(queryParams, true)
    }
}
