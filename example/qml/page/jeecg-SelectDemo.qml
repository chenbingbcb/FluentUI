import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import example 1.0
import "../global"

FluContentPage{

    id:root
    title: qsTr("SelectDemo")
    height: 60

    property string dictCode: "/secure_train_type"
    property string sysPostListUrl: "/sys/sysPost/list"
    property string sysDepartListUrl: "/sys/sysDepart/list"
    property string sysUserListUrl: "/sys/user/list"
    property int sysPostPageNo: 0
    property var sysPostList: []

    Component.onCompleted: {
        FluNetwork.get(GlobalModel.basicUrl + "/sys/dict/getDictItems" + dictCode)
        .addHeader("S-Token",GlobalModel.token)
        .bind(root)
        .go(getDictItemsCallable)

        sysPostListRequest()
    }

    function sysPostListRequest() {
        FluNetwork.get(GlobalModel.basicUrl + sysPostListUrl)
        .addHeader("S-Token",GlobalModel.token)
        .addQuery("superQueryMatchType", "or")
        .addQuery("field", "code,name")
        .addQuery("pageNo", ++sysPostPageNo)
        .addQuery("pageSize", 5)
        .bind(root)
        .go(sysPostListCallable)
    }

    function sysDepartListRequest() {
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + sysDepartListUrl)
        .addHeader("S-Token",GlobalModel.token)
        .addQuery("superQueryParams", encodeURI('[{"rule":"like","type":"input","val":"125000","field":"orgCode"},{"rule":"like","type":"input","val":"105008","field":"orgCode"}]'))
        .addQuery("superQueryMatchType", "or")
        .addQuery("field", "id,,departName,id")
        .addQuery("order", "desc")
        .addQuery("column", "orgCode")
        .addQuery("pageNo", selectBizDialogDepart.getPageNo())
        .addQuery("pageSize", selectBizDialogDepart.getPageSize())
        .bind(root)

        var strId = selectBizDialogDepart.getTextBoxId()
        if (strId !== "") {
            strId = "*" + strId + "*"
            networkParams.addQuery("id", strId)
        }
        var name = selectBizDialogDepart.getTextBoxName()
        if (name !== "") {
            name = "*" + name + "*"
            networkParams.addQuery("departName", name)
        }

        networkParams.go(sysDepartListCallable)
    }

    function sysUserListRequest() {
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + sysUserListUrl)
        .addHeader("S-Token",GlobalModel.token)
        .addQuery("field", "id,realname,username,orgCodeTxt")
        .addQuery("order", "desc")
        .addQuery("column", "createTime")
        .addQuery("pageNo", selectBizDialogUser.getPageNo())
        .addQuery("pageSize", selectBizDialogUser.getPageSize())
        .bind(root)

        var strId = selectBizDialogUser.getTextBoxId()
        if (strId !== "") {
            strId = "*" + strId + "*"
            networkParams.addQuery("username", strId)
        }
        var name = selectBizDialogUser.getTextBoxName()
        if (name !== "") {
            name = "*" + name + "*"
            networkParams.addQuery("realname", name)
        }
        var sex = selectBizDialogUser.getComboBoxSex()
        if (sex !== 0) {
            networkParams.addQuery("sex", sex)
        }
        var strBirthday = selectBizDialogUser.getCalendarBirthday()
        if (strBirthday !== "") {
            networkParams.addQuery("birthday", strBirthday)
        }
        var strPhone = selectBizDialogUser.getTextBoxPhone()
        if (strPhone !== "") {
            strPhone = "*" + strPhone + "*"
            networkParams.addQuery("phone", strPhone)
        }

        networkParams.go(sysUserListCallable)
    }

    FluNetworkCallable{
        id:getDictItemsCallable
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
                    showError(qsTr("getDictItems failed: " + result))
                    return
                }

                // rowDictSelectTag.comboBoxArray.append(jsResult.result)
                // if (rowDictSelectTag.comboBoxArray.count > 0) {
                //     comboBoxDictSelectTag.currentIndex = 0
                // }
                comboBoxDictSelectTag.model.append(jsResult.result)
                comboMultiSelectTag.model = jsResult.result
            }
    }

    FluNetworkCallable{
        id:sysPostListCallable
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
                    showError(qsTr(sysPostListUrl + " failed: " + result))
                    return
                }

                sysPostList = sysPostList.concat(jsResult.result.records.map(function(item) {
                    return {text: item.code.concat(" + " + item.name), value: item.code}
                }))
                comboSearchSelect.model = sysPostList
                comboSearchSelect.update()
            }
    }

    FluNetworkCallable{
        id:sysDepartListCallable
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
                    showError(qsTr(sysDepartListUrl + " failed: " + result))
                    return
                }

                jsResult.result.records = jsResult.result.records.map(function(item) {
                    return {id: item.id, name: item.departName}
                })
                selectBizDialogDepart.loadData(jsResult.result)
                selectBizDialogDepart.open()
            }
    }

    FluNetworkCallable{
        id:sysUserListCallable
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
                    showError(qsTr(sysDepartListUrl + " failed: " + result))
                    return
                }

                jsResult.result.records = jsResult.result.records.map(function(item) {
                    return {id: item.username, name: item.realname, orgCodeTxt: item.orgCodeTxt || ""}
                })
                selectBizDialogUser.loadData(jsResult.result)
                selectBizDialogUser.open()
            }
    }

    Row {
        id:rowDictSelectTag
        spacing: 10
        anchors{
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: 20
        }

        FluText{
            height: 32
            text: qsTr("单选字典下拉:")
            verticalAlignment: Qt.AlignVCenter
        }

        FluComboBox {
            id:comboBoxDictSelectTag
            model: ListModel {ListElement { text: "" }}
            // delegate: ItemDelegate {
            //     width: parent.width
            //     text: modelData.text
            // }
            // displayText: currentIndex === 0 ? "" : model.get(currentIndex).text
            onActivated: {
                if(index === 0) {
                    textDictSelectTag.text = qsTr("选中值: 类型object")
                } else {
                    var value = model.get(index).value
                    textDictSelectTag.text = qsTr("选中值: ") + value + qsTr("类型") + typeof value
                }
            }
        }

        FluText{
            id:textDictSelectTag
            height: 32
            text: qsTr("选中值: 类型object")
            verticalAlignment: Qt.AlignVCenter
        }
    }

    Row {
        id:rowMultiSelectTag
        spacing: 10
        anchors{
            left: parent.left
            right: parent.right
            top: rowDictSelectTag.bottom
            topMargin: 5
        }

        FluText{
            height: 32
            text: qsTr("多选字典下拉:")
            verticalAlignment: Qt.AlignVCenter
        }

        FluCheckComboBox {
            id: comboMultiSelectTag
            placeholder: qsTr("请做出你的选择")
            onSelectionChanged: {
                console.log("选中项:", selectedItems)
                var str = selectedItems.map(function(item) {
                    return item.value
                }).join(",")
                textMultiSelectTag.text = qsTr("选中值: ") + str
            }
        }

        FluText{
            id:textMultiSelectTag
            height: 32
            text: qsTr("选中值:")
            verticalAlignment: Qt.AlignVCenter
        }
    }

    Row {
        id:rowSearchSelect
        spacing: 10
        anchors{
            left: parent.left
            right: parent.right
            top: rowMultiSelectTag.bottom
            topMargin: 5
        }

        FluText{
            height: 32
            text: qsTr("字典搜索-url:")
            verticalAlignment: Qt.AlignVCenter
        }

        FluCheckComboBox {
            id: comboSearchSelect
            listMore: true
            placeholder: qsTr("请做出你的选择")
            onSelectionChanged: {
                console.log("选中项:", selectedItems)
                var str = selectedItems.map(function(item) {
                    return item.value
                }).join(",")
                textSearchSelect.text = qsTr("选中值: ") + str
            }
            onMoreButtonClicked: {
                sysPostListRequest()
            }
        }

        FluText{
            id:textSearchSelect
            height: 32
            text: qsTr("选中值:")
            verticalAlignment: Qt.AlignVCenter
        }
    }

    Row {
        id:rowSysDepart
        spacing: 10
        anchors{
            left: parent.left
            right: parent.right
            top: rowSearchSelect.bottom
            topMargin: 5
        }

        FluText{
            height: 32
            text: qsTr("选择部门(不展示组织架构):")
            verticalAlignment: Qt.AlignVCenter
        }

        FluMultilineTextBox {
            id: textBoxSysDepart
            readOnly: true
            placeholderText: "请点击选择"
            onPressed:{
                sysDepartListRequest()
            }
        }

        // FluIconButton{
        //     iconSource: FluentIcons.Search
        //     iconSize: 15
        //     text: qsTr("选择")
        //     display: Button.TextBesideIcon
        //     onClicked:{
        //         sysDepartListRequest()
        //     }
        // }

        FluText{
            id:textSysDepart
            height: 32
            text: qsTr("选中值:")
            verticalAlignment: Qt.AlignVCenter
        }

        FluSelectBizDialog{
            id: selectBizDialogDepart
            title: qsTr("部门选择")
            choosedTitle: qsTr("已选部门")
            strId: qsTr("部门代号")
            name: qsTr("部门名称")
            queryClickListener: sysDepartListRequest
            buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
            onNegativeClicked: {
            }
            onPositiveClicked:
                (data)=>{
                    var textBox = data.map(function(item) {
                       return item.name
                    }).join(", ")
                    textBoxSysDepart.text = textBox

                    var text = data.map(function(item) {
                       return item.id
                    }).join(", ")
                    textSysDepart.text = qsTr("选中值:") + text
                }
        }
    }

    Row {
        id:rowUser
        spacing: 10
        anchors{
            left: parent.left
            right: parent.right
            top: rowSysDepart.bottom
            topMargin: 5
        }

        FluText{
            height: 32
            text: qsTr("选择用户:")
            verticalAlignment: Qt.AlignVCenter
        }

        FluMultilineTextBox {
            id: textBoxUser
            readOnly: true
            placeholderText: "请点击选择"
            onPressed:{
                sysUserListRequest()
            }

            FluSelectBizDialog{
                id: selectBizDialogUser
                title: qsTr("用户选择")
                choosedTitle: qsTr("已选用户")
                strId: qsTr("账号")
                name: qsTr("姓名")
                orgCodeTxt: qsTr("部门")
                isMoreQuery: true
                isSingleSelect: true
                queryClickListener: sysUserListRequest
                buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
                onNegativeClicked: {
                }
                onPositiveClicked:
                    (data)=>{
                        var textBox = data.map(function(item) {
                           return item.name
                        }).join(", ")
                        textBoxUser.text = textBox

                        var text = data.map(function(item) {
                           return item.id
                        }).join(", ")
                        textUser.text = qsTr("选中值:") + text
                    }
            }
        }

        // FluIconButton{
        //     iconSource: FluentIcons.Search
        //     iconSize: 15
        //     text: qsTr("选择")
        //     display: Button.TextBesideIcon
        //     onClicked:{
        //         sysUserListRequest()
        //     }
        // }

        FluText{
            id:textUser
            height: 32
            text: qsTr("选中值:")
            verticalAlignment: Qt.AlignVCenter
        }
    }
}
