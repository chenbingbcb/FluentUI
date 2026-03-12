import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI

ColumnLayout {
    id:root
    property var treeConfig //树配置 支持json
    property var formConfig //表单配置 支持json
    property string listUrl: ""
    property string deleteUrl: ""
    property string addUrl: ""
    property string editUrl: ""
    property string queryByIdUrl: ""
    property var listCallback: listRequest //获取列表数据回调
    property var deleteCallback: deleteRequest //删除单行数据回调
    property var addCallback: addRequest //新增单行数据回调
    property var editCallback: editRequest //更新单行数据回调
    property var queryByIdCallback: queryByIdRequest //获取单行数据回调
    property string treeTitle: ""
    property var rowActionDelegate: comRowAction //行操作委托
    property int treeViewHeight: defaultCellHeight * 10 + 42 //42为表头高度
    property int defaultCellWidth: 200
    property int defaultCellHeight: 50
    property string actionName: "action" //默认操作列字段名
    property var _to
    property var treeView
    Layout.fillWidth: true

    Component.onDestruction: {
        if (_to && _to.close) { //关闭关联的form窗口
            _to.close()
        }
    }

    Component.onCompleted: {
    }

    onTreeConfigChanged: {
        loaderTreeView.sourceComponent = comTreeView
    }

    function procTreeList(treeList) {
        if (!treeList || !treeList.length) {
            return [];
        }

        return treeList.map(node => {
            node._key = node.id || node.key
            node[actionName] = treeView.customItem(rowActionDelegate)

            // 如果存在children，则递归处理
            if (node.children && treeList.length) {
                node.children = procTreeList(node.children);
            }

            return node;
        });
    }

    function listRequest() {
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + listUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("order", "desc")
        .addQuery("column", "createTime")
        .addQuery("pageNo", gagination.pageCurrent)
        .addQuery("pageSize", gagination.__itemPerPage)

        networkParams.go(listCallable)
    }

    FluNetworkCallable{
        id: listCallable
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

                var treeList = []
                if (jsResult.result.records) {
                    treeList = jsResult.result.records
                    gagination.itemCount = jsResult.result.total || 0
                    gagination.__itemPerPage = jsResult.result.size || 10
                } else {
                    treeList = jsResult.result
                }

                treeView.dataSource = procTreeList(treeList)
                treeView.allCollapse()
            }
    }

    function deleteRequest(row) {
        var obj = treeView.getRow(row)
        var networkParams = FluNetwork.deleteJson(GlobalModel.basicUrl + deleteUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("id", obj.id)
        .go(deleteCallable)
    }

    FluNetworkCallable{
        id: deleteCallable
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
                    showError(qsTr(deleteUrl + " failed: " + result))
                    return
                }

                listCallback()
            }
    }

    function addRequest(params) {
        var networkParams = FluNetwork.postJson(GlobalModel.basicUrl + addUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        // .openLog(true)

        for(var key in params) {
            networkParams.add(key, params[key])
        }

        networkParams.go(addCallable)
    }

    FluNetworkCallable{
        id: addCallable
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
                    showError(qsTr(addUrl + " failed: " + result))
                    return
                }

                listCallback()
            }
    }

    function editRequest(params) {
        var networkParams = FluNetwork.putJson(GlobalModel.basicUrl + editUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        // .openLog(true)

        for(var key in params) {
            networkParams.add(key, params[key])
        }

        networkParams.go(editCallable)
    }

    FluNetworkCallable{
        id: editCallable
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
                    showError(qsTr(editUrl + " failed: " + result))
                    return
                }

                listCallback()
            }
    }

    function queryByIdRequest(rowDataId, formTitle) {
        queryByIdCallable.formTitle = formTitle
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + queryByIdUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("id", rowDataId)
        .go(queryByIdCallable)
    }

    FluNetworkCallable{
        id: queryByIdCallable
        property string formTitle: ""
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
                    showError(qsTr(queryByIdUrl + " failed: " + result))
                    return
                }

                openFormWindow(jsResult.result, formTitle)
            }
    }

    RowLayout {
        Layout.fillWidth: true
        // Layout.alignment: Qt.AlignRight

        FluText {
            text: treeTitle
            font: FluTextStyle.Subtitle
        }

        Item {
            Layout.fillWidth: true
        }

        FluFilledButton {
            visible: true
            text: qsTr("新增")
            onClicked: {
                openFormWindow({pid: "0"}, qsTr("新增"))
            }
        }
    }

    FluLoader {
        id: loaderTreeView
        Layout.topMargin: -6
        Layout.fillWidth: true
        Layout.preferredHeight: treeViewHeight
        onLoaded: {
            treeView = item
            listCallback()
        }
    }

    Component {
        id: comTreeView
        FluTreeView {
            cellHeight: 42
            showLine: false
            columnSource: {
                var temp = []
                treeConfig.columns.forEach(function(item) {
                    if (item.ifShow !== false) {
                        // var dataIndex = typeof item.format === "string" && item.format.startsWith("column|") ? item.format.slice(7) : item.dataIndex
                        temp.push({
                            title: item.title,
                            dataIndex: item.dataIndex,
                            width: item.width || defaultCellWidth,
                            minimumWidth: item.width || defaultCellWidth,
                            align: item.align,
                            format: item.format,
                        })
                    }
                })

                //最后一列操作列固定
                if (typeof treeConfig.actionColumn === "object") {
                    var actionColumn = treeConfig.actionColumn
                    actionName = actionColumn.dataIndex
                    temp.push({
                        title: actionColumn.title,
                        dataIndex: actionName,
                        width: actionColumn.width || defaultCellWidth,
                        // minimumWidth: actionColumn.width || defaultCellWidth,
                        frozen: true
                    })
                }

                if (temp.length === 0) {
                    return
                }

                return temp
            }
        }
    }

    Component{
        id: comRowAction
        Item{
            RowLayout{
                anchors.centerIn: parent
                spacing: 0
                Component.onCompleted: {
                }

                FluIconButton{
                    id: editButton
                    iconSource: FluentIcons.Edit
                    iconSize: 15
                    onClicked: {
                        var obj = treeView.getRow(row)
                        queryByIdCallback(obj.id, qsTr("修改"))
                    }
                }

                FluIconButton{
                    id: addChildButton
                    iconSource: FluentIcons.Add
                    iconSize: 15
                    onClicked: {
                        var obj = treeView.getRow(row)
                        openFormWindow({pid: obj.id}, qsTr("新增"))
                    }
                }

                FluIconButton{
                    iconSource: FluentIcons.Delete
                    iconSize: 15
                    onClicked: {
                        deleteDialog.open()
                    }
                    FluContentDialog {
                        id: deleteDialog
                        title: qsTr("删除")
                        message: qsTr("是否确认删除?")
                        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
                        negativeText: qsTr("取消")
                        positiveText: qsTr("确认")
                        onPositiveClicked:{
                            var rowObj = treeView.getRow(row)
                            if (rowObj.id) {
                                deleteCallback(row)
                            }

                            treeView.removeRow(row)
                        }
                    }
                }
            }
        }
    }

    FluPagination{
        id: gagination
        Component.onCompleted: {

        }
        Layout.fillWidth: true
        pageCurrent: 1
        pageButtonCount: 7
        __itemPerPage: 10
        previousText: qsTr("<")
        nextText: qsTr(">")
        onRequestPage:
            (page,count)=> {
                // treeView.resetPosition()
                listCallback()
            }
    }

    Item {
        Layout.fillHeight: true
    }

    function openFormWindow(rowFormData, formTitle) {
        FluRouter.navigate("/onlineFormWindow", {
                               formPaneData: {
                                   formConfig: formConfig
                                   , formData: rowFormData
                                   , title: formTitle
                                   , parent: root
                               }
                           }, root)
    }
}
