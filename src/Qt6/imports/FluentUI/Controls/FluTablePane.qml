import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI

ColumnLayout {
    id:root
    property var tableConfig //列表配置 支持json
    property var formConfig //表单配置 支持json
    property string tableId: "" //列表id
    property string formId: "" //表单id
    property string menuId: "" //菜单id
    property string columnsUrl: "/online/genFormAPI/getColumns/%1/%2".arg(tableId).arg(menuId) //获取列表配置url
    property string formConfigUrl: "/online/genFormAPI/getFormConfig/%1/%2".arg(formId).arg(menuId) //获取表单配置url
    property string listUrl: "/online/genFormAPI/getTableData/" + tableId //获取列表数据url
    property string deleteUrl: "/online/genFormAPI/delDataByParams/" + tableId //删除单行数据url
    property string addUrl: "/online/genFormAPI/addFormData/" + tableId //新增单行数据url
    property string editUrl: "/online/genFormAPI/updateFormData/" + tableId //更新单行数据url
    property string queryByIdUrl: "/online/genFormAPI/getDataByParams/" + tableId //获取单行数据url
    property string updateAllUrl: "/demo/testDemo2/updateAll" //更新全部数据url 临时配置
    property var listCallback: listRequest //获取列表数据回调
    property var deleteCallback: deleteRequest //删除单行数据回调
    property var addCallback: addRequest //新增单行数据回调
    property var editCallback: editRequest //更新单行数据回调
    property var queryByIdCallback: queryByIdRequest //获取单行数据回调
    property var updateAllCallback: updateAllRequest //更新全部数据回调
    property var relatedFields: [] //关联字段
    property var relatedRowData //关联行数据
    property string tableTitle: ""
    property var rowActionDelegate: comRowAction //行操作委托组件
    property var tableActionDelegate //列表操作委托组件
    property var formBelowDelegate //表单下面委托组件
    property var childTableCustomConfig: [] //子表自定义配置

    property int tableViewHeight: defaultCellHeight * 10 + 42 //42为表头高度
    property int defaultCellWidth: 200
    property int defaultCellHeight: 50
    //modalSingleModel:弹窗单行保存(默认) modalAllModel:弹窗一起保存 editSingleModel:可编辑单行保存 editAllModel:可编辑一起保存
    property string tableModel: tableConfig && tableConfig.tableModel ? tableConfig.tableModel : "modalSingleModel"
    property var defaultButtons: tableConfig && tableConfig.defaultButtons ? tableConfig.defaultButtons : ({})
    property var queryFormConfig: tableConfig && tableConfig.formConfig ? tableConfig.formConfig : ({}) //查询表单配置
    property var editFieldColumn: ({})
    property string actionName: "action" //默认操作列字段名
    property var queryParams: ({}) //查询字段参数
    property var formPane //子表所关联的FluFormPane对象 有值则表示当前为子表
    property var removeRecords: [] //删除的table记录
    property var _to
    property var tableView
    Layout.fillWidth: true

    Component.onDestruction: {
        if (_to && _to.close) { //关闭关联的form窗口
            _to.close()
        }
    }

    Component.onCompleted: {
        if (!tableConfig) {
            columnsRequest()
        }

        if (!formConfig) {
            formConfigRequest()
        }
    }

    onTableConfigChanged: {
        loaderTableView.sourceComponent = comTableView
    }

    function columnsRequest() {
        FluNetwork.get(GlobalModel.basicUrl + columnsUrl)
        .addHeader("S-Token", GlobalModel.token)
        .bind(root)
        .go(columnsCallable)
    }

    FluNetworkCallable{
        id: columnsCallable
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
                    showError(qsTr(columnsUrl + " failed: " + result))
                    return
                }

                tableConfig = jsResult.result
            }
    }

    function formConfigRequest() {
        if (tableModel === "editSingleModel" || tableModel === "editAllModel") {
            return
        }

        FluNetwork.get(GlobalModel.basicUrl + formConfigUrl)
        .addHeader("S-Token", GlobalModel.token)
        .bind(root)
        .go(formConfigCallable)
    }

    FluNetworkCallable{
        id: formConfigCallable
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
                    showError(qsTr(formConfigUrl + " failed: " + result))
                    return
                }

                formConfig = jsResult.result
            }
    }

    function listRequest() {
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + listUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("order", "desc")
        .addQuery("column", "createTime")
        .addQuery("pageNo", gagination.pageCurrent)
        .addQuery("pageSize", gagination.__itemPerPage)

        if (relatedFields.length === 2 && relatedRowData && !queryParams.hasOwnProperty(relatedFields[1])) { //避免重复添加
            networkParams.addQuery(relatedFields[1], relatedRowData[relatedFields[0]])
        }

        for(var field in queryParams) {
            var loaderItem = queryParams[field]
            if (loaderItem.value) {
                networkParams.addQuery(field, loaderItem.value)
            }
        }

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

                var tableData = jsResult.result
                var dataSource = []
                tableData.records.forEach(function(record) {
                    record._key = FluTools.uuid()
                    record._minimumHeight = defaultCellHeight
                    record[actionName] = tableView.customItem(rowActionDelegate)
                    dataSource.push(record)
                })

                tableView.dataSource = dataSource
                tableView.editedRows = {}
                gagination.itemCount = tableData.total || 0
                gagination.__itemPerPage = tableData.size || 10
            }
    }

    function deleteRequest(row) {
        var obj = tableView.getRow(row)
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

    function addRequest(params, noRefresh) {
        var networkParams = FluNetwork.postJson(GlobalModel.basicUrl + addUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        // .openLog(true)

        for(var key in params) {
            networkParams.add(key, params[key])
        }

        addCallable.noRefresh = noRefresh
        networkParams.go(addCallable)
    }

    FluNetworkCallable{
        id: addCallable
        property var noRefresh
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

                if (!noRefresh) {
                    listCallback()
                }
            }
    }

    function editRequest(params, noRefresh) {
        var networkParams = FluNetwork.putJson(GlobalModel.basicUrl + editUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        // .openLog(true)

        for(var key in params) {
            networkParams.add(key, params[key])
        }

        editCallable.noRefresh = noRefresh
        networkParams.go(editCallable)
    }

    FluNetworkCallable{
        id: editCallable
        property var noRefresh //默认刷新
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

                if (!noRefresh) {
                    listCallback()
                }
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

    function updateAllRequest(params) {
        var networkParams = FluNetwork.putJson(GlobalModel.basicUrl + updateAllUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        // .openLog(true)

        for(var key in params) {
            networkParams.add(key, params[key])
        }

        networkParams.go(updateAllCallable)
    }

    FluNetworkCallable{
        id: updateAllCallable
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
                    showError(qsTr(updateAllUrl + " failed: " + result))
                    return
                }

                listCallback()
            }
    }

    Component {
        id: comDelegate
        Item {
            property var columnSpan: modelData.colProps ? (modelData.colProps.span || 8) : 8
            property alias loaderItem: loader
            visible: modelData.ifShow !== false
            Layout.columnSpan: columnSpan
            Layout.preferredWidth: parent.width / (24 / columnSpan)
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            Layout.preferredHeight: loader.item instanceof FluFormTextArea ? 48 : 32
            Layout.fillWidth: true

            FluText {
                id: label
                anchors{
                    left: parent.left
                    top: parent.top
                }
                text: {
                    if (modelData.required === true) {
                        return "<font color='red'>*</font>" + modelData.label
                    } else {
                        return modelData.label
                    }
                }
                width: 80
                height: 32
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignRight
                wrapMode: Text.WrapAnywhere
            }

            FluLoader {
                id: loader
                anchors{
                    left: label.right
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 5
                    rightMargin: 5
                }
                enabled: !modelData.dynamicDisabled
                property var config: modelData
                property var value: null
                sourceComponent: getComponentByType(config.component, config.componentProps)
            }
        }
    }

    FluFrame{
        Layout.fillWidth: true
        visible: queryFormConfig.schemas !== undefined && queryFormConfig.schemas.length > 0

        GridLayout{
            columns: 24
            columnSpacing: 0
            anchors{
                left: parent.left
                right: parent.right
            }

            Repeater {
                model: queryFormConfig.schemas
                delegate: comDelegate
                onItemAdded: (index, item) => {
                                 var field = model[index].field.trim()
                                 if (relatedFields.length === 2 && relatedFields[1] === field && relatedRowData) {
                                     item.loaderItem.value = relatedRowData[relatedFields[0]]
                                     item.loaderItem.item.initDisplay()
                                 }
                                 queryParams[field] = item.loaderItem
                             }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                anchors{ //使控件位于GridLayout右下方
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: queryFormConfig.schemas && queryFormConfig.schemas.length > 0 ? 5 : 0
                }

                FluButton{
                    text: qsTr("重置")
                    onClicked: {
                        for(var field in queryParams) {
                            var loaderItem = queryParams[field]
                            loaderItem.value = null
                            var config = loaderItem.config
                            loaderItem.sourceComponent = getComponentByType(config.component, config.componentProps)
                            if (relatedFields.length === 2 && relatedFields[1] === field && relatedRowData) {
                                loaderItem.value = relatedRowData[relatedFields[0]]
                                loaderItem.item.initDisplay()
                            }
                        }
                        listCallback()
                    }
                }

                FluButton{
                    text: qsTr("查询")
                    onClicked: {
                        listCallback()
                    }
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        // Layout.alignment: Qt.AlignRight

        FluText {
            text: tableTitle
            font: FluTextStyle.Subtitle
        }

        Item {
            Layout.fillWidth: true
        }

        FluFilledButton {
            visible: defaultButtons.add ? defaultButtons.add.visible : true
            text: qsTr("新增")
            onClicked: {
                if (tableModel === "editSingleModel" || tableModel === "editAllModel") {
                    var uuid = FluTools.uuid()
                    var rowObj = {
                        _key: uuid
                        , _minimumHeight: defaultCellHeight
                    }
                    rowObj[actionName] = tableView.customItem(rowActionDelegate, {newRow: uuid})

                    for (var field in editFieldColumn) {
                        rowObj[field] = ""
                        if (relatedFields.length === 2 && relatedFields[1] === field && relatedRowData) {
                            rowObj[field] = relatedRowData[relatedFields[0]]
                        }
                    }

                    for (var key in tableView.editedRows) {
                        var row = tableView.editedRows[key]
                        if (row !== undefined) {
                            tableView.editedRows[key] = row + 1
                        }
                    }
                    tableView.editedRows[uuid] = 0
                    tableView.insertRow(0, rowObj)
                } else {
                    var rowFormData = null
                    if (relatedFields.length === 2 && relatedRowData) {
                        rowFormData = {}
                        rowFormData[relatedFields[1]] = relatedRowData[relatedFields[0]]
                    }
                    openFormWindow(rowFormData, qsTr("新增"))
                }
            }
        }

        FluFilledButton {
            visible: tableModel === "editAllModel" && !formPane //子表的保存跟表单一起
            text: qsTr("保存")
            onClicked: {
                // if (tableModel === "modalAllModel") {
                //     showError(qsTr("弹窗一起保存模式暂未支持"))
                //     return
                // }

                var updateObj = {
                    insertRecords: []
                    , updateRecords: []
                    // , removeRecords: removeRecords
                }
                var sysUpdateFieldNames = {}
                for (var key in tableView.editedRows) {
                    var row = tableView.editedRows[key]
                    var rowObj = tableView.getRow(row)
                    var temp = {}
                    for (var field in editFieldColumn) {
                        var column = editFieldColumn[field]
                        if (column === -1) {
                            continue
                        }

                        var config = tableView.columnSource[column]
                        if (config.required === true && !rowObj[field]) {
                            showError(config.title + qsTr("不能为空"))
                            return
                        }
                        temp[field] = rowObj[field]
                        sysUpdateFieldNames[field] = true
                    }

                    if (rowObj.id) {
                        temp.id = rowObj.id //必须
                        updateObj.sysUpdateFieldNames = Object.keys(sysUpdateFieldNames)
                        updateObj.updateRecords.push(temp)
                    } else {
                        updateObj.insertRecords.push(temp)
                    }
                }

                if (updateObj.updateRecords.length <= 0 && updateObj.insertRecords.length <= 0/* && updateObj.removeRecords.length <= 0*/) {
                    return
                }

                tableView.editedRows = {}
                updateAllCallback(updateObj)
            }
        }

        FluLoader {
            sourceComponent: tableActionDelegate
        }
    }

    FluLoader {
        id: loaderTableView
        Layout.topMargin: -6
        Layout.fillWidth: true
        Layout.preferredHeight: tableViewHeight
        onLoaded: {
            tableView = item
            listCallback()
        }
    }

    Component {
        id: comTableView
        FluTableView {
            startRowIndex: (gagination.pageCurrent - 1) * gagination.__itemPerPage + 1
            columnSource: {
                var temp = []
                tableConfig.columns.forEach(function(item) {
                    editFieldColumn[item.dataIndex] = -1
                    if (item.ifShow !== false) {
                        if (item.editRow === true) { //ifShow和editRow都要符合
                            editFieldColumn[item.dataIndex] = temp.length //记录在columnSource中的位置
                        }

                        // var dataIndex = typeof item.format === "string" && item.format.startsWith("column|") ? item.format.slice(7) : item.dataIndex
                        temp.push({
                            title: item.title,
                            dataIndex: item.dataIndex,
                            width: item.width || defaultCellWidth,
                            minimumWidth: item.width || defaultCellWidth,
                            align: item.align,
                            format: item.format,
                            editRow: item.editRow,
                            required: item.editRule,
                            componentProps: item.editComponentProps,
                            editDelegate: getComponentByType(item.editComponent, item.editComponentProps)
                        })
                    }
                })

                //最后一列操作列固定
                if (typeof tableConfig.actionColumn === "object") {
                    var actionColumn = tableConfig.actionColumn
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
                    if (tableModel === "editSingleModel" || tableModel === "editAllModel") {
                        if (tableView.editedRows[model.rowModel._key] !== row) {
                            return
                        }

                        if (tableModel === "editSingleModel") {
                            editButton.visible = false
                            saveButton.visible = true
                            cancelButton.visible = true
                        }
                    }
                }

                FluIconButton{
                    id: editButton
                    visible: defaultButtons.edit ? defaultButtons.edit.visible : true
                    iconSource: FluentIcons.Edit
                    iconSize: 15
                    onClicked: {
                        if (tableModel === "editSingleModel" || tableModel === "editAllModel") {
                            if (tableView.editedRows[model.rowModel._key] === row) {
                                return
                            }

                            if (tableModel === "editSingleModel") {
                                visible = false
                                saveButton.visible = true
                                cancelButton.visible = true
                            }
                            tableView.editedRows = Object.defineProperty(tableView.editedRows, model.rowModel._key, {value: row, writable: true, enumerable: true})
                        } else {
                            var obj = tableView.getRow(row)
                            queryByIdCallback(obj.id, qsTr("修改"))
                        }
                    }
                }

                FluIconButton{
                    visible: tableModel === "modalSingleModel" || tableModel === "modalAllModel"
                    iconSource: FluentIcons.BulletedList
                    iconSize: 15
                    onClicked: {
                        var obj = tableView.getRow(row)
                        queryByIdCallback(obj.id, qsTr("详情"))
                    }
                }

                FluIconButton{
                    visible: (defaultButtons.delete ? defaultButtons.delete.visible : true) && editButton.visible
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
                            var rowObj = tableView.getRow(row)
                            if (rowObj.id) {
                                if (formPane && formPane.childTableConfig.length > 0 && tableModel === "editAllModel") {
                                    removeRecords.push(rowObj)
                                } else {
                                    deleteCallback(row)
                                }
                            }

                            if (tableView.editedRows[model.rowModel._key] === row) {
                                delete tableView.editedRows[model.rowModel._key]
                            }
                            tableView.removeRow(row)
                        }
                    }
                }

                FluIconButton{
                    id: saveButton
                    visible: false
                    iconSource: FluentIcons.Save
                    iconSize: 15
                    onClicked: {
                        var rowObj = tableView.getRow(row)
                        var updateObj = {}
                        var sysUpdateFieldNames = []
                        for (var field in editFieldColumn) {
                            var column = editFieldColumn[field]
                            if (column === -1) {
                                continue
                            }

                            var config = tableView.columnSource[column]
                            if (config.required === true && !rowObj[field]) {
                                showError(config.title + qsTr("不能为空"))
                                return
                            }
                            updateObj[field] = rowObj[field]
                            sysUpdateFieldNames.push(field)
                        }

                        if (rowObj.id) {
                            updateObj.id = rowObj.id //必须
                            updateObj.sysUpdateFieldNames = sysUpdateFieldNames
                            editCallback(updateObj)
                        } else {
                            addCallback(updateObj)
                        }

                        editButton.visible = true
                        saveButton.visible = false
                        cancelButton.visible = false
                        tableView.editedRows = Object.defineProperty(tableView.editedRows, model.rowModel._key, {value: undefined, writable: true, enumerable: true})
                    }
                }

                FluIconButton{
                    id: cancelButton
                    visible: false
                    iconSource: FluentIcons.Cancel
                    iconSize: 15
                    onClicked: {
                        cancelDialog.open()
                    }

                    FluContentDialog{
                        id: cancelDialog
                        title: qsTr("取消确认")
                        message: qsTr("是否取消编辑?")
                        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
                        negativeText: qsTr("取消")
                        positiveText: qsTr("确认")
                        onPositiveClicked:{
                            editButton.visible = true
                            saveButton.visible = false
                            cancelButton.visible = false
                            tableView.editedRows = Object.defineProperty(tableView.editedRows, model.rowModel._key, {value: undefined, writable: true, enumerable: true})
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
                // tableView.closeEditor()
                tableView.editedRows = {}
                tableView.resetPosition()
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
                                   , childTableCustomConfig: childTableCustomConfig
                                   , formBelowDelegate: formBelowDelegate
                               }
                           }, root)
    }
}
