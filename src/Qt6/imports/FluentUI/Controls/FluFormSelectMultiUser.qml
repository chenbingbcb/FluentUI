import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    id: root
    property string sysUserListUrl: "/sys/user/list"
    property var sysUserListListener: sysUserListRequest //用户控件查询回调

    function sysUserListRequest(control, queryParams, display) {
        var callable = comNetworkSysUserList.createObject(root, {control: control, display: display})
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + sysUserListUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)

        for(var key in queryParams) {
            networkParams.addQuery(key, queryParams[key])
        }

        networkParams.go(callable)
    }

    Component {
        id: comNetworkSysUserList
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
                        showError(qsTr(sysUserListUrl + " failed: " + result))
                        return
                    }

                    control.sysUserListResp(jsResult.result, display)
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

        function sysUserListResp(result, display) {
            if (display) {
                var choosed = []
                text = result.records.map(function(item) {
                    choosed.push({id: item.username, name: item.realname})
                    return item[display]
                 }).join(", ")
                selectBiz.initChoosed(choosed)
                return
            }

            result = Object.assign({}, result)
            result.records = result.records.map(function(item) {
                return {id: item.username, name: item.realname, orgCodeTxt: item.orgCodeTxt || ""}
            })
            selectBiz.loadData(result)
            selectBiz.open()
        }

        FluSelectBizDialog {
            id: selectBiz
            title: qsTr("用户选择")
            choosedTitle: qsTr("已选用户")
            strId: qsTr("账号")
            name: qsTr("姓名")
            orgCodeTxt: qsTr("部门")
            isMoreQuery: true
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

                sysUserListListener(control, queryParams)
            }
        }
    }

    function initDisplay() {
        control.text = value
        if (!control.text) {
            return
        }

        var display = "realname"
        var queryParams = {
            pageNo: 1
            , pageSize: control.text.split(",").length
            , username: control.text
        }

        sysUserListListener(control, queryParams, display)
    }
}
