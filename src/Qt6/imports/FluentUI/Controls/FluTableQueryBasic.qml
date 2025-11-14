import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI

FluScrollablePage{
    id:root
    anchors.fill: parent

    property var tableConfig/*: { //查询列表配置
        formConfig: {} //查询字段配置
        columns: [] //列表表头配置
    }*/
    property var tableData/*: { //列表数据
        records: []
    }*/
    property var formConfig/*: { //编辑表单配置
        schemas: [] //控件配置
    }*/
    property var rowFormData/*: { //单行表单数据
    }*/
    property var windowFormData //新建窗口表单数据
    property var tabConfig: ({}) //标签配置
    property var childTableConfig: [] //子表配置
    property int tableIndex: 0 //当前table索引
    property string tableId: ""
    property string formId: ""
    property string menuId: ""

    property string getColumnsUrl: "/online/genFormAPI/getColumns/%1/%2".arg(tableId).arg(menuId)
    property string getTableDataUrl: "/online/genFormAPI/getTableData/" + tableId
    property string getFormConfigUrl: "/online/genFormAPI/getFormConfig/%1/%2".arg(formId).arg(menuId)
    property string getDataByParamsUrl: "/online/genFormAPI/getDataByParams/" + tableId
    property string delDataByParamsUrl: "/online/genFormAPI/delDataByParams/" + tableId
    property string addFormDataUrl: "/online/genFormAPI/addFormData/"
    property string updateFormDataUrl: "/online/genFormAPI/updateFormData/"
    property string updateAllUrl: "/demo/testDemo2/updateAll" //临时配置
    property string getDictItemsUrl: "/sys/dict/getDictItems/"
    property string sysUserListUrl: "/sys/user/list"
    property string sysDepartListUrl: "/sys/sysDepart/list"
    property var getColumnsListener: getColumnsRequest //列表配置回调
    property var getTableDataListener: getTableDataRequest //列表数据回调
    property var getFormConfigListener: getFormConfigRequest //表单配置回调
    property var getDataByParamsListener: getDataByParamsRequest //单行表单数据回调
    property var delDataByParamsListener: delDataByParamsRequest //删除回调
    property var addFormDataListener: addFormDataRequest //新增回调
    property var updateFormDataListener: updateFormDataRequest //更新回调
    property var updateAllListener: updateAllRequest //批量更新回调
    property var getDictItemsListener: getDictItemsRequest //字典编码查询回调
    property var listUrlListener: listUrlRequest //组件请求数据回调
    property var sysUserListListener: sysUserListRequest //用户控件查询回调
    property var sysDepartListListener: sysDepartListRequest //部门控件查询回调

    signal dictItemsUpdated(string key, var dictItems) //字典数据更新通知
    property int defaultCellWidth: 100
    property int defaultCellHeight: 50
    property string tableModel: "modalSingleModel" //modalSingleModel:弹窗单行保存 modalAllModel:弹窗一起保存 editSingleModel:可编辑单行保存 editAllModel:可编辑一起保存
    property var tablePanes: ({}) //子表面板map 子表数组索引做key
    property var tablePane
    property var tableView: tablePane ? tablePane.tableView : undefined
    property var pageNo: tablePane ? tablePane.gagination.pageCurrent : 1
    property var pageSize: tablePane ? tablePane.gagination.__itemPerPage : 10
    property var parentTableForm
    property var dictItemsMap: ({}) //字典数据
    // property var listUrlMap: ({}) //url数据
    property string formTitle: ""

    function procRequestConfig(tableIndexParam) {
        if (!getColumnsUrl) {
            return
        }

        tableIndex = tableIndexParam || 0
        getColumnsListener()
    }

    function getColumnsRequest() {
        FluNetwork.get(GlobalModel.basicUrl + getColumnsUrl)
        .addHeader("S-Token", GlobalModel.token)
        .bind(root)
        .go(getColumnsCallable)
    }

    FluNetworkCallable{
        id: getColumnsCallable
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
                    showError(qsTr(getColumnsUrl + " failed: " + result))
                    return
                }

                tableConfig = jsResult.result
                getTableDataListener()
            }
    }

    function getTableDataRequest() {
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + getTableDataUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("order", "desc")
        .addQuery("column", "createTime")
        .addQuery("pageNo", pageNo)
        .addQuery("pageSize", pageSize)
        if (windowFormData && windowFormData.relatedField && windowFormData.rowFormData) {
            networkParams.addQuery(windowFormData.relatedField, windowFormData.rowFormData.id)
        }

        if (tablePane) {
            for(var key in tablePane.queryParams) {
                if (tablePane.queryParams[key].text !== "") {
                    networkParams.addQuery(key, tablePane.queryParams[key].text)
                }
            }
        }

        networkParams.go(getTableDataCallable)
    }

    FluNetworkCallable{
        id: getTableDataCallable
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
                    showError(qsTr(getTableDataUrl + " failed: " + result))
                    return
                }

                tableData = jsResult.result
                getFormConfigListener()
            }
    }

    function getFormConfigRequest() {
        if (formConfig || !formId || (tableModel === "editSingleModel" || tableModel === "editAllModel")) {
            return
        }

        FluNetwork.get(GlobalModel.basicUrl + getFormConfigUrl)
        .addHeader("S-Token", GlobalModel.token)
        .bind(root)
        .go(getFormConfigCallable)
    }

    FluNetworkCallable{
        id: getFormConfigCallable
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
                    showError(qsTr(getFormConfigUrl + " failed: " + result))
                    return
                }

                formConfig = jsResult.result
            }
    }

    function getDataByParamsRequest(row) {
        var obj = tableView.getRow(row)
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + getDataByParamsUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("id", obj.id)
        .go(getDataByParamsCallable)
    }

    FluNetworkCallable{
        id: getDataByParamsCallable
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
                    showError(qsTr(getDataByParamsUrl + " failed: " + result))
                    return
                }

                rowFormData = jsResult.result
            }
    }

    function delDataByParamsRequest(row) {
        var obj = tableView.getRow(row)
        var networkParams = FluNetwork.deleteJson(GlobalModel.basicUrl + delDataByParamsUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("id", obj.id)
        .go(delDataByParamsCallable)
    }

    FluNetworkCallable{
        id: delDataByParamsCallable
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
                    showError(qsTr(delDataByParamsUrl + " failed: " + result))
                    return
                }

                getTableDataListener()
            }
    }

    function addFormDataRequest(tableId, updateObj, noRefresh) {
        var networkParams = FluNetwork.postJson(GlobalModel.basicUrl + addFormDataUrl + tableId)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        // .openLog(true)

        for(var key in updateObj) {
            networkParams.add(key, updateObj[key])
        }

        addFormDataCallable.tableId = tableId
        addFormDataCallable.noRefresh = noRefresh
        networkParams.go(addFormDataCallable)
    }

    FluNetworkCallable{
        id: addFormDataCallable
        property var tableId
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
        onCache:
            (result)=>{
                console.debug("onCache: "+result)
            }
        onSuccess:
            (result)=>{
                var jsResult = JSON.parse(result)
                console.debug(JSON.stringify(jsResult, null, 2))
                if (jsResult.code !== 200) {
                    showError(qsTr(addFormDataUrl + tableId + " failed: " + result))
                    return
                }

                if (!noRefresh) {
                    if (windowFormData) {
                        if (_windowRegister && _windowRegister.getTableDataListener) { //若有父表 则更新父表显示
                            _windowRegister.getTableDataListener()
                        }
                        close()
                    } else {
                        getTableDataListener()
                    }
                }
            }
    }

    function updateFormDataRequest(tableId, updateObj, noRefresh) {
        var networkParams = FluNetwork.putJson(GlobalModel.basicUrl + updateFormDataUrl + tableId)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        // .openLog(true)

        for(var key in updateObj) {
            networkParams.add(key, updateObj[key])
        }

        updateFormDataCallable.tableId = tableId
        updateFormDataCallable.noRefresh = noRefresh
        networkParams.go(updateFormDataCallable)
    }

    FluNetworkCallable{
        id: updateFormDataCallable
        property var tableId
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
        onCache:
            (result)=>{
                console.debug("onCache: "+result)
            }
        onSuccess:
            (result)=>{
                var jsResult = JSON.parse(result)
                console.debug(JSON.stringify(jsResult, null, 2))
                if (jsResult.code !== 200) {
                    showError(qsTr(updateFormDataUrl + tableId + " failed: " + result))
                    return
                }

                if (!noRefresh) {
                    if (windowFormData) {
                        if (_windowRegister && _windowRegister.getTableDataListener) { //若有父表 则更新父表显示
                            _windowRegister.getTableDataListener()
                        }
                        // close()
                    } else {
                        getTableDataListener()
                    }
                }
            }
    }

    function updateAllRequest(updateObj) {
        var networkParams = FluNetwork.putJson(GlobalModel.basicUrl + updateAllUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        // .openLog(true)

        for(var key in updateObj) {
            networkParams.add(key, updateObj[key])
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
        onCache:
            (result)=>{
                console.debug("onCache: "+result)
            }
        onSuccess:
            (result)=>{
                var jsResult = JSON.parse(result)
                console.debug(JSON.stringify(jsResult, null, 2))
                if (jsResult.code !== 200) {
                    showError(qsTr(updateAllUrl + " failed: " + result))
                    return
                }

                getTableDataListener()
            }
    }

    function getDictItemsRequest(dictCode) {
        var callable = comNetworkDictCode.createObject(root, {dictCode: dictCode})
        FluNetwork.get(GlobalModel.basicUrl + getDictItemsUrl + dictCode)
        .addHeader("S-Token",GlobalModel.token)
        .bind(root)
        .go(callable)
    }

    Component {
        id: comNetworkDictCode
        FluNetworkCallable{
            property var dictCode
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
                        showError(qsTr(getDictItemsUrl + " failed: " + result))
                        return
                    }

                    dictItemsUpdated(dictCode, jsResult.result)
                }
        }
    }

    function listUrlRequest(listUrl, fields, pageNo) {
        var callable = comNetworkListUrl.createObject(root, {listUrl: listUrl})
        FluNetwork.get(GlobalModel.basicUrl + listUrl)
        .bind(root)
        .addHeader("S-Token",GlobalModel.token)
        .addQuery("superQueryMatchType", "or")
        .addQuery("field", fields.toString())
        .addQuery("pageNo", pageNo)
        .addQuery("pageSize", 20)
        .go(callable)
    }

    Component {
        id: comNetworkListUrl
        FluNetworkCallable{
            property var listUrl
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
                        showError(qsTr(listUrl + " failed: " + result))
                        return
                    }

                    dictItemsUpdated(listUrl, jsResult.result)
                }
        }
    }

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

    Shortcut {
        sequence: "F5" //按F5刷新
        context: Qt.WindowShortcut
        onActivated: {
            rootLayout.data = []
            if (windowFormData) {
                windowFormData = Object.assign({}, windowFormData)
            } else {
                pageConfig = Object.assign({}, pageConfig)
            }
        }
    }

    onPageConfigChanged: {
        var paths = pageConfig.path.split("/")
        if (paths && paths.length > 1) {
            formId = paths[paths.length - 1]
            tableId = paths[paths.length - 2]
        }
        menuId = pageConfig.meta.menuId || pageConfig.id
        procRequestConfig(0)
    }

    onWindowFormDataChanged: {
        parentTableForm = comParentTableForm.createObject(rootLayout)
        parentTableForm.title = windowFormData.formTitle

        for (var i = 0; i < windowFormData.childTableConfig.length; i++) { //子表
            var componentProps = windowFormData.childTableConfig[i].componentProps
            tableId = componentProps.genTableHeadId || componentProps.defaultValue
            menuId = componentProps.genMenuId || 0
            var fieldStr = componentProps.relatedField || ""
            var fields = fieldStr.split(":")
            if (fields.length > 1) {
                windowFormData.relatedField = fields[1]
            }
            procRequestConfig(i)
            break
        }
    }

    onTableConfigChanged: {
        if (windowFormData) {
            tableModel = "editAllModel" //web端写死
        } else {
            tableModel = tableConfig.tableModel
        }

        var editFieldColumn = {}
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
                    format: item.format,
                    width: item.width || defaultCellWidth,
                    minimumWidth: item.width || defaultCellWidth,
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
            temp.push({
                title: actionColumn.title,
                dataIndex: "action",
                width: actionColumn.width || defaultCellWidth,
                minimumWidth: actionColumn.width || defaultCellWidth,
                frozen: true
            })
        }

        tablePane = comTablePane.createObject(rootLayout, {columnSource: temp
                                                            , editFieldColumn: editFieldColumn
                                                            , queryFormConfig: tableConfig.formConfig
                                                        })
        tablePanes[tableIndex] = tablePane
    }

    onTableDataChanged: {
        var dataSource = []
        tableData.records.forEach(function(record) {
            record._key = FluTools.uuid()
            record._minimumHeight = defaultCellHeight
            record.action = tableView.customItem(com_action)
            dataSource.push(record)
        })

        tableView.dataSource = dataSource
        if (tablePane) {
            tablePane.gagination.itemCount = tableData.total || 0
            tablePane.gagination.__itemPerPage = tableData.size || 10
        }
    }

    onFormConfigChanged: {
        formConfig.schemas = formConfig.schemas || []
        for (var i = formConfig.schemas.length - 1; i >= 0; i--) {
            var schema = formConfig.schemas[i];
            //分离不同类型的配置
            if (schema.component === "Tab") {
                tabConfig = schema
                formConfig.schemas.splice(i, 1);
            } else if (schema.component === "childTable") {
                if (schema.ifShow !== false) {
                    childTableConfig.unshift(schema);
                }
                formConfig.schemas.splice(i, 1);
            } else if (schema.ifShow === false) {
                formConfig.schemas.splice(i, 1);
            }
        }
        // parentTableForm = comParentTableForm.createObject(root)
    }

    onRowFormDataChanged: {
        // parentTableForm.rowFormData = rowFormData
        // parentTableForm.open()
        openFormWindow(false)
    }

    ColumnLayout {
        id: rootLayout
    }

    Component{
        id:com_action
        Item{
            RowLayout{
                anchors.centerIn: parent
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
                            getDataByParamsListener(row)
                            formTitle = qsTr("编辑")
                        }

                        // for (var listUrl in listUrlMap) {
                        //     listUrlListener(listUrl, listUrlMap[listUrl], 1)
                        // }
                    }
                }
                FluIconButton{
                    visible: tableModel === "modalSingleModel" || tableModel === "modalAllModel"
                    iconSource: FluentIcons.BulletedList
                    iconSize: 15
                    onClicked: {
                        getDataByParamsListener(row)
                        // for (var listUrl in listUrlMap) {
                        //     listUrlListener(listUrl, listUrlMap[listUrl], 1)
                        // }

                        formTitle = qsTr("详情")
                    }
                }
                FluIconButton{
                    visible: editButton.visible
                    iconSource: FluentIcons.Delete
                    iconSize: 15
                    onClicked: {
                        deleteDialog.open()
                    }
                    FluContentDialog{
                        id: deleteDialog
                        title: qsTr("删除确认")
                        message: qsTr("是否确认删除?")
                        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
                        negativeText: qsTr("取消")
                        positiveText: qsTr("确认")
                        onPositiveClicked:{
                            var rowObj = tableView.getRow(row)
                            if (rowObj.id) {
                                if (windowFormData && windowFormData.childTableConfig.length > 0) {
                                    tablePane.removeRecords.push(rowObj)
                                } else {
                                    delDataByParamsListener(row)
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
                        for (var field in tablePane.editFieldColumn) {
                            var column = tablePane.editFieldColumn[field]
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
                            updateFormDataListener(tableId, updateObj, true)
                        } else {
                            addFormDataListener(tableId, updateObj, true)
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

    Component {
        id: comTablePane
        ColumnLayout {
            Layout.fillWidth: true
            property var queryParams: ({}) //查询字段参数
            property var queryFormConfig: ({}) //查询表单配置
            property var editFieldColumn: ({})
            property var removeRecords: [] //删除的table记录
            property alias tableView: tableView
            property alias columnSource: tableView.columnSource
            property alias gagination: gagination

            FluFrame{
                Layout.fillWidth: true

                GridLayout{
                    columns: 24
                    columnSpacing: 0
                    anchors{
                        left: parent.left
                        right: parent.right
                    }

                    Repeater {
                        model: queryFormConfig.schemas
                        delegate: Item {
                            Layout.columnSpan: modelData.colProps.span
                            Layout.preferredWidth: parent.width / (24 / modelData.colProps.span)
                            Layout.alignment: Qt.AlignRight
                            Layout.topMargin: 5
                            Layout.bottomMargin: 5
                            height: label.height
                            property alias queryParam: textBoxQueryParam
                            FluText{
                                id: label
                                anchors{
                                    left: parent.left
                                    top: parent.top
                                    bottom: parent.bottom
                                }
                                text: modelData.label
                                height: 32
                                width: queryFormConfig.labelWidth | 120
                                verticalAlignment: Qt.AlignVCenter
                                horizontalAlignment: Qt.AlignRight
                            }

                            FluTextBox {
                                id: textBoxQueryParam
                                anchors{
                                    left: label.right
                                    right: parent.right
                                    top: parent.top
                                    bottom: parent.bottom
                                    leftMargin: 5
                                    rightMargin: 5
                                }
                                placeholderText: qsTr("请输入")
                            }
                        }
                        onItemAdded: (index, item) => {
                                         queryParams[model[index].field.trim()] = item.queryParam
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
                                for(var key in queryParams) {
                                    queryParams[key].text = ""
                                }
                                getTableDataListener()
                            }
                        }

                        FluButton{
                            text: qsTr("查询")
                            onClicked: {
                                getTableDataListener()
                            }
                        }
                    }
                }
            }

            RowLayout{
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight

                FluFilledButton{
                    text: qsTr("新增")
                    onClicked: {
                        if (tableModel === "editSingleModel" || tableModel === "editAllModel") {
                            var uuid = FluTools.uuid()
                            var rowObj = {
                                _key: uuid
                                , _minimumHeight: defaultCellHeight
                                , action: tableView.customItem(com_action, {newRow: uuid})
                            }
                            for (var field in tablePane.editFieldColumn) {
                                rowObj[field] = ""
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
                            // if (parentTableForm) {
                            //     parentTableForm.rowFormData = {}
                            //     // parentTableForm.open()
                            // }
                            formTitle = qsTr("编辑")
                            openFormWindow(true)
                        }

                        // for (var listUrl in listUrlMap) {
                        //     listUrlListener(listUrl, listUrlMap[listUrl], 1)
                        // }
                    }
                }

                FluFilledButton{
                    visible: (tableModel === "modalAllModel" || tableModel === "editAllModel") && !windowFormData //子表的保存跟表单一起
                    text: qsTr("保存")
                    onClicked: {
                        var updateObj = tableUpdateAll(tablePane)
                        if (!updateObj) {
                            return
                        }
                        updateAllListener(updateObj)
                    }
                }
            }

            FluTableView{
                id: tableView
                Layout.topMargin: -6
                Layout.fillWidth: true
                // Layout.fillHeight: true
                Layout.preferredHeight: defaultCellHeight * 10 + 42 //42为表头高度
                startRowIndex: (gagination.pageCurrent - 1) * gagination.__itemPerPage + 1
            }

            FluPagination{
                id:gagination
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
                        getTableDataListener()
                    }
            }
        }
    }

    //form弹窗
    Component {
        id: comParentTableForm
        ColumnLayout{
            id: control
            Layout.fillWidth: true
            property string title: qsTr("编辑")
            property var tabFields: []

            Component.onCompleted: {
                var fields = []
                var tabConfig = windowFormData.tabConfig
                var tabPanels = tabConfig.componentProps.tabPanels || []
                tabPanels.forEach(function(panel, i) {
                    var obj = Qt.createQmlObject("import FluentUI; FluToggleButton{}", tabButtons)
                    obj.text = panel.tab
                    obj.controlBackground.border.width = 0
                    obj.controlBackground.gradient = null
                    obj.clickListener = function() {
                        for(var i = 0; i < tabButtons.buttons.length; i++) {
                            var button = tabButtons.buttons[i]
                            if(this === button){
                                tabButtons.currentIndex = i
                                break
                            }
                        }

                        for (var k = 0; k < tabRepeater.count; k++) {
                            var tabItem = tabRepeater.itemAt(k)
                            tabItem.visible = tabButtons.currentIndex === tabFields[k].tabIndex
                        }
                    }
                    tabButtons.buttons.push(obj)

                    if(tabConfig.componentProps.activeKey === panel.key){
                        tabButtons.currentIndex = i
                    }
                    for (var j = 0; j < panel.fields.length; j++) {
                        var field = panel.fields[j]
                        field.tabIndex = i
                        fields.push(field)
                    }
                })
                tabFields = fields
                // control.onOpened //提前加载tabFields的控件

                var loaderItem
                for (var i = 0; i < tabRepeater.count; i++) {
                    loaderItem = tabRepeater.itemAt(i).loaderItem
                    loaderItem.value = windowFormData.rowFormData[loaderItem.config.field] || null
                    if (loaderItem.item.initDisplay) {
                        loaderItem.item.initDisplay()
                    }
                }

                for (var j = 0; j < repeater.count; j++) {
                    loaderItem = repeater.itemAt(j).loaderItem
                    loaderItem.value = windowFormData.rowFormData[loaderItem.config.field] || null
                    if (loaderItem.item.initDisplay) {
                        loaderItem.item.initDisplay()
                    }
                }
            }

            // Connections{
            //     target: root
            //     function onDictItemsUpdated(key, dictItems) {
            //         var loaderItem
            //         for (var i = 0; i < tabRepeater.count; i++) {
            //             loaderItem = tabRepeater.itemAt(i).loaderItem
            //             if (loaderItem.item.dictCode === key) {
            //                 loaderItem.item.dictItems = dictItems
            //             }
            //         }

            //         for (var j = 0; j < repeater.count; j++) {
            //             loaderItem = repeater.itemAt(j).loaderItem
            //             if (loaderItem.item.dictCode === key) {
            //                 loaderItem.item.dictItems = dictItems
            //             }
            //         }
            //     }
            // }

            // onOpened: {

            // }


            RowLayout{
                Layout.fillWidth: true

                FluText{
                    font: FluTextStyle.Subtitle
                    text: title
                    leftPadding: 10
                }

                Item {
                    Layout.fillWidth: true
                }

                FluFilledButton{
                    visible: title === qsTr("编辑")
                    Layout.rightMargin: 10
                    text: qsTr("保存")
                    onClicked: {
                        // control.close()
                        var newData = Object.assign({}, windowFormData.rowFormData)
                        var sysUpdateFieldNames = []
                        var loaderItem
                        for (var i = 0; i < tabRepeater.count; i++) {
                            loaderItem = tabRepeater.itemAt(i).loaderItem
                            if (loaderItem.config.required === true && !loaderItem.value) {
                                showError(loaderItem.config.label + qsTr("不能为空"))
                                return
                            }

                            if (newData.id) {
                                if (newData[loaderItem.config.field] !== loaderItem.value) {
                                    newData[loaderItem.config.field] = loaderItem.value
                                    sysUpdateFieldNames.push(loaderItem.config.field)
                                }
                            } else {
                                if (loaderItem.value) {
                                    newData[loaderItem.config.field] = loaderItem.value
                                }
                            }
                        }

                        for (var j = 0; j < repeater.count; j++) {
                            loaderItem = repeater.itemAt(j).loaderItem
                            if (loaderItem.config.required === true && !loaderItem.value) {
                                showError(loaderItem.config.label + qsTr("不能为空"))
                                return
                            }

                            if (newData.id) {
                                if (newData[loaderItem.config.field] !== loaderItem.value) {
                                    newData[loaderItem.config.field] = loaderItem.value
                                    sysUpdateFieldNames.push(loaderItem.config.field)
                                }
                            } else {
                                if (loaderItem.value) {
                                    newData[loaderItem.config.field] = loaderItem.value
                                }
                            }
                        }

                        if (newData.id) {
                            var childTableUpdate = false //子表是否有更新
                            if (windowFormData && windowFormData.childTableConfig.length > 0) {
                                for (var k = 0; k < windowFormData.childTableConfig.length; k++) {
                                    if (!tablePanes[k]) {
                                        continue
                                    }

                                    var updateObj = tableUpdateAll(tablePanes[k])
                                    if (updateObj === false) { //当且仅当为false时 表示出错
                                        return
                                    }

                                    if (!updateObj) {
                                        continue
                                    }

                                    var config = windowFormData.childTableConfig[k]
                                    var field = config.field
                                    newData[field] = updateObj
                                    childTableUpdate = true
                                }
                            }

                            if (sysUpdateFieldNames.length <= 0 && !childTableUpdate) {
                                return
                            }
                            newData.sysUpdateFieldNames = sysUpdateFieldNames
                            updateFormDataListener(windowFormData.parentTableId, newData)
                        } else {
                            addFormDataListener(windowFormData.parentTableId, newData)
                        }
                    }
                }

                // FluIconButton{
                //     iconSource: FluentIcons.ChromeClose
                //     iconSize: 15
                //     text: qsTr("Close")
                //     display: Button.IconOnly
                //     onClicked:{
                //         // control.close()
                //     }
                // }
            }

            FluRadioButtons{
                id: tabButtons
                spacing: 0
                orientation: Qt.Horizontal
            }

            FluDivider{
                Layout.fillWidth: true
            }

            GridLayout{
                id: tabPanel
                columns: 24
                columnSpacing: 0
                Layout.fillWidth: true

                Repeater {
                    id: tabRepeater
                    model: tabFields
                    delegate: comDelegate
                    onItemAdded: (index, item) => {
                                     // //顺序在repeater.onItemAdded之后 全部添加完后执行字典编码查询回调
                                     // if (index === model.length - 1) {
                                     //     for (var dictCode in dictItemsMap) {
                                     //         getDictItemsListener(dictCode)
                                     //     }
                                     // }
                                     if (model[index].tabIndex !== tabButtons.currentIndex) {
                                         item.visible = false
                                     }
                                 }
                    Component.onCompleted: {

                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            GridLayout{
                columns: 24
                columnSpacing: 0
                Layout.fillWidth: true

                Repeater {
                    id: repeater
                    model: windowFormData.formConfig.schemas
                    delegate: comDelegate
                    onItemAdded: (index, item) => {

                                 }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            //子表
            FluLoader {
                Layout.fillWidth: true
                sourceComponent: windowFormData.childTableConfig.length > 0 ? comChildTableTab : undefined
            }

            Component {
                id: comChildTableTab
                ColumnLayout {
                    FluRadioButtons{
                        id: tableButtons
                        spacing: 0
                        orientation: Qt.Horizontal
                        Component.onCompleted: {
                            for (var i = 0; i < windowFormData.childTableConfig.length; i++) {
                                var config = windowFormData.childTableConfig[i]
                                var obj = Qt.createQmlObject("import FluentUI; FluToggleButton{}", tableButtons)
                                obj.text = config.label
                                obj.controlBackground.border.width = 0
                                obj.controlBackground.gradient = null
                                obj.clickListener = function() {
                                    for(var i = 0; i < tableButtons.buttons.length; i++) {
                                        var button = tableButtons.buttons[i]
                                        if(this === button) {
                                            tableButtons.currentIndex = i
                                            if (tablePanes[i]) {
                                                tablePane = tablePanes[i]
                                                tablePane.visible = true
                                            } else {
                                                var componentProps = windowFormData.childTableConfig[i].componentProps
                                                tableId = componentProps.genTableHeadId || componentProps.defaultValue
                                                menuId = componentProps.genMenuId || 0
                                                var fieldStr = componentProps.relatedField || ""
                                                var fields = fieldStr.split(":")
                                                if (fields.length > 1) {
                                                    windowFormData.relatedField = fields[1]
                                                }
                                                procRequestConfig(i)
                                            }
                                        } else if (tablePanes[i]) {
                                            tablePanes[i].visible = false
                                        }
                                    }
                                }
                                tableButtons.buttons.push(obj)
                            }
                            tableButtons.currentIndex = 0
                        }
                    }

                    FluDivider{
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    Component {
        id: comDelegate
        Item {
            Layout.columnSpan: modelData.colProps.span
            Layout.preferredWidth: parent.width / (24 / modelData.colProps.span)
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            Layout.preferredHeight: loader.item instanceof FluMultilineTextBox ? loader.item.contentHeight + 16 : 32
            Layout.fillWidth: true
            property alias loaderItem: loader

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
                width: 120
                height: 32
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignRight
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

    Component {
        id: comTextBox
        FluTextBox {
            id: control
            placeholderText: qsTr("请输入")

            onTextChanged: {
                value = control.text
            }

            function initDisplay() {
                control.text = value
            }
        }
    }

    Component {
        id: comMultilineTextBox
        FluMultilineTextBox {
            id: control
            wrapMode: Text.WrapAnywhere

            onTextChanged: {
                value = control.text
            }

            function initDisplay() {
                control.text = value
            }
        }
    }

    Component {
        id: comToggleSwitch
        RowLayout {
            FluToggleSwitch {
                id: control
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    value = checked ? "true" : "false"
                }
            }

            function initDisplay() {
                if (typeof value === "string") {
                    control.checked = value.toLowerCase() === "true"
                } else {
                    control.checked = false
                }
            }
        }
    }

    Component {
        id: comCalendarPicker
        FluCalendarPicker {
            onAccepted: {
                value = current.toLocaleString(FluApp.locale,"yyyy-MM-dd hh:mm:ss")
            }

            function initDisplay() {
                current = Date.fromLocaleString(FluApp.locale, value, "yyyy-MM-dd hh:mm:ss")
            }
        }
    }

    Component {
        id: comCalendarTimePicker
        RowLayout {
            spacing: -1
            FluCalendarPicker{
                id: calendarPicker
                // Layout.fillWidth: true

                onAccepted: {
                    var date = calendarPicker.text
                    var time = timePicker.current.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
                    var split = time.split(":")
                    if (split.length < 3) {
                        return
                    }
                    value = date + " " + split[0] +":" + split[1] +":" + split[2]
                }
            }

            FluTimePicker {
                id: timePicker
                Layout.fillWidth: true
                hourFormat:FluTimePickerType.HH
                hourText: ""
                minuteText: ""
                cancelText: qsTr("取消")
                okText: qsTr("确定")

                onAccepted: {
                    var date = calendarPicker.text
                    var time = timePicker.current.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
                    var split = time.split(":")
                    if (split.length < 3) {
                        return
                    }
                    value = date + " " + split[0] +":" + split[1] +":" + split[2]
                }
            }

            function initDisplay() {
                calendarPicker.current = Date.fromLocaleString(FluApp.locale, value, "yyyy-MM-dd hh:mm:ss")
                if (calendarPicker.current) { //相当于格式校验
                    var time = calendarPicker.current.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
                    var split = time.split(":")
                    if (split.length < 2) {
                        return
                    }
                    timePicker.hourText = split[0]
                    timePicker.minuteText = split[1]
                }
            }
        }
    }

    Component {
        id: comTimePicker
        FluTimePicker {
            hourFormat:FluTimePickerType.HH
            hourText: ""
            minuteText: ""
            cancelText: qsTr("取消")
            okText: qsTr("确定")

            onAccepted: {
                var whole = Date.fromLocaleString(FluApp.locale, value, "yyyy-MM-dd hh:mm:ss")
                if (whole) { //相当于格式校验
                    var date = whole.toLocaleDateString(FluApp.locale, "yyyy-MM-dd")
                    var time = current.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
                    var split = time.split(":")
                    if (split.length < 3) {
                        return
                    }
                    value = date + " " + split[0] +":" + split[1] +":" + split[2]
                }
            }

            function initDisplay() {
                var whole = Date.fromLocaleString(FluApp.locale, value, "yyyy-MM-dd hh:mm:ss")
                if (whole) { //相当于格式校验
                    var time = whole.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
                    var split = time.split(":")
                    if (split.length < 2) {
                        return
                    }
                    hourText = split[0]
                    minuteText = split[1]
                }
            }
        }
    }

    Component {
        id: comSearchSelect
        FluCheckComboBox {
            id: control
            placeholder: qsTr("请选择")
            listMore: true
            listUrl: {
                // var componentProps = config.componentProps
                // if (componentProps && componentProps.listUrl) {
                //     listUrlMap[componentProps.listUrl] = [componentProps.valField, componentProps.txtField]
                //     return componentProps.listUrl
                // }
                if (config.componentProps) {
                    return config.componentProps.listUrl
                }
            }
            valField: {
                if (config.componentProps) {
                    return config.componentProps.valField
                }
            }
            txtField: {
                if (config.componentProps) {
                    return config.componentProps.txtField
                }
            }

            property var textValueMap: ({})
            property var dictItems
            property var componentProps: config.componentProps || {}

            Component.onCompleted: {
                listUrlListener(listUrl, [valField, txtField], 1)
            }

            onMoreButtonClicked: {
                listUrlListener(listUrl, [valField, txtField], ++listPageNo)
            }

            onSelectionChanged: {
                var texts = control.displayText.split(", ")
                value = texts.map(function(text) {
                    return textValueMap[text]
                 }).join(",")
            }

            // onDictItemsChanged: {
            //     model = model.concat(dictItems.records.map(function(item) {
            //         var text = item[txtField]
            //         var value = item[valField]
            //         textValueMap[text] = value
            //         return {text: text, value: value}
            //     }))
            //     update()
            //     initDisplay()
            // }

            Connections{
                target: root
                function onDictItemsUpdated(key, dictItems) {
                    if (listUrl === key) {
                        // control.dictItems = dictItems
                        model = model.concat(dictItems.records.map(function(item) {
                            var text = item[txtField]
                            var value = item[valField]
                            textValueMap[text] = value
                            return {text: text, value: value}
                        }))
                        update()
                        initDisplay()
                    }
                }
            }

            function initDisplay() {
                if (!value) {
                    return
                }

                var values = value.split(",")
                values.forEach(function(v) {
                    for(var i = 0; i < model.length; i++) {
                        if (model[i].value === v) {
                            toggleSelection(model[i])
                            break
                        }
                    }
                })
            }
        }
    }

    Component {
        id: comDictSelectTag
        FluComboBox {
            model: ListModel {ListElement { text: ""; title: ""; value: "" }}
            textRole: "text"
            valueRole: "value"
            // property var dictItems: GlobalModel.sysAllDictItems[dictCode]
            property var dictCode: {
                var componentProps = config.componentProps
                if (componentProps && componentProps.dictCode) {
                    dictItemsMap[componentProps.dictCode] = true
                    return componentProps.dictCode
                }
            }

            onActivated:{
                value = currentValue
            }

            function initDisplay() {
                for(var i = 0; i < model.count; i++) {
                    var item = model.get(i)
                    if (item.value === value) {
                        currentIndex = i
                        break
                    }
                }
            }

            // onDictItemsChanged: {
            Component.onCompleted: {
                var dictItems = GlobalModel.sysAllDictItems[dictCode]
                model.append(dictItems)
            }
        }
    }

    Component {
        id: comDictSelectTagRadio
        Rectangle {
            FluRadioButtons {
                id: radioButtons
                orientation: Qt.Horizontal
                // property var dictItems: GlobalModel.sysAllDictItems[dictCode]
                property var dictCode: {
                    var componentProps = config.componentProps
                    if (componentProps && componentProps.dictCode) {
                        dictItemsMap[componentProps.dictCode] = true
                        return componentProps.dictCode
                    }
                }

                // onDictItemsChanged: {
                Component.onCompleted: {
                    radioButtons.buttons = []
                    var dictItems = GlobalModel.sysAllDictItems[dictCode] || []
                    dictItems.forEach(function(item) {
                        var obj = Qt.createQmlObject("import FluentUI; FluRadioButton{property var value}", radioButtons)
                        obj.text = item.text
                        obj.value = item.value
                        obj.clickListener = function() {
                            for(var i = 0; i < radioButtons.buttons.length; i++){
                                var button = radioButtons.buttons[i]
                                if(this === button){
                                    radioButtons.currentIndex = i
                                    value = button.value
                                    break
                                }
                            }
                        }
                        radioButtons.buttons.push(obj)
                    })
                }
            }

            function initDisplay() {
                for(var i = 0; i < radioButtons.buttons.length; i++){
                    var button = radioButtons.buttons[i]
                    if (button.value === value) {
                        radioButtons.currentIndex = i
                        break
                    }
                }
            }
        }
    }

    Component {
        id: comMultiSelectTag
        FluCheckComboBox {
            id: control
            placeholder: qsTr("请选择")
            model: {
                var dictItems = GlobalModel.sysAllDictItems[dictCode]
                model = dictItems.map(function(item) {
                    textValueMap[item.text] = item.value
                    return {text: item.text, value: item.value}
                })
            }

            property var textValueMap: ({})
            // property var dictItems: GlobalModel.sysAllDictItems[dictCode]
            property var dictCode: {
                var componentProps = config.componentProps
                if (componentProps && componentProps.dictCode) {
                    dictItemsMap[componentProps.dictCode] = true
                    return componentProps.dictCode
                }
            }

            onSelectionChanged: {
                var texts = control.displayText.split(", ")
                value = texts.map(function(text) {
                    return textValueMap[text]
                 }).join(",")
            }

            // onDictItemsChanged: {
            // Component.onCompleted: {
            //     var dictItems = GlobalModel.sysAllDictItems[dictCode]
            //     model = dictItems.map(function(item) {
            //         textValueMap[item.text] = item.value
            //         return {text: item.text, value: item.value}
            //     })
            // }

            function initDisplay() {
                if (!value) {
                    return
                }

                // clearValues()
                // var dictItems = GlobalModel.sysAllDictItems[dictCode]
                // model = dictItems.map(function(item) {
                //     textValueMap[item.text] = item.value
                //     return {text: item.text, value: item.value}
                // })

                var values = value.split(",")
                values.forEach(function(v) {
                    for(var i = 0; i < model.length; i++) {
                        if (model[i].value === v) {
                            toggleSelection(model[i])
                            break
                        }
                    }
                })
            }
        }
    }

    Component {
        id: comMultiSelectTagCheckBox
        Rectangle {
            RowLayout {
                id: control
                property list<QtObject> buttons
                // property var dictItems: GlobalModel.sysAllDictItems[dictCode]
                property var dictCode: {
                    var componentProps = config.componentProps
                    if (componentProps && componentProps.dictCode) {
                        dictItemsMap[componentProps.dictCode] = true
                        return componentProps.dictCode
                    }
                }

                // onDictItemsChanged: {
                Component.onCompleted: {
                    var dictItems = GlobalModel.sysAllDictItems[dictCode]
                    dictItems.forEach(function(item) {
                        var obj = Qt.createQmlObject("import FluentUI; FluCheckBox{property var value}", control)
                        obj.text = item.text
                        obj.value = item.value
                        obj.Layout.alignment = Qt.AlignVCenter
                        obj.clickListener = function() {
                            obj.checked = !obj.checked
                            value = value || ""
                            if (obj.checked) {
                                if (value.length > 0) {
                                    value += ","
                                }
                                value += obj.value
                            } else {
                                var values = value.split(",")
                                var index = values.indexOf(obj.value)
                                if (index > -1) {
                                    values.splice(index, 1)
                                    value = values.join(",") || null
                                }
                            }
                            // initDisplay()
                        }
                        buttons.push(obj)
                    })
                }
            }

            function initDisplay() {
                if (!value) {
                    return
                }

                var values = value.split(",")
                values.forEach(function(v) {
                    for(var i = 0; i < control.buttons.length; i++) {
                        if (control.buttons[i].value === v) {
                            control.buttons[i].checked = true
                            break
                        }
                    }
                })
            }
        }
    }

    Component {
        id: comSelectMultiUser
        FluMultilineTextBox {
            id: control
            readOnly: true
            placeholderText: "请选择"
            onPressed: {
                selectBiz.queryClickImpl()
                selectBiz.open()
            }

            function initDisplay() {
                text = value
                if (!text) {
                    return
                }

                var display = "realname"
                var queryParams = {
                    pageNo: 1
                    , pageSize: text.split(",").length
                    , username: text
                }

                sysUserListListener(control, queryParams, display)
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
    }

    Component {
        id: comSelectMultiDep
        FluMultilineTextBox {
            id: control
            readOnly: true
            placeholderText: "请选择"
            onPressed: {
                selectBiz.queryClickImpl()
                selectBiz.open()
            }

            function initDisplay() {
                text = value
                if (!text) {
                    return
                }

                var display = "departName"
                var queryParams = {
                    pageNo: 1
                    , pageSize: text.split(",").length
                    , id: text
                }

                sysDepartListListener(control, queryParams, display)
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
    }

    Component {
        id: comUnsupported
        FluTextBox {
            id: control
            enabled: false
            placeholderText: qsTr("暂未支持")

            function initDisplay() {
            }
        }
    }

    function getComponentByType(component, componentProps) {
        switch (component) {
            case "Input":
                return comTextBox
            case "Textarea":
                return comMultilineTextBox
            case "Switch":
                return comToggleSwitch
            case "DatePicker":
                return componentProps.showTime === true ? comCalendarTimePicker : comCalendarPicker
            case "TimePicker":
                return comTimePicker
            case "SearchSelect":
                return comSearchSelect
            case "DictSelectTag":
                return componentProps.type === "radio" ? comDictSelectTagRadio : comDictSelectTag
            case "MultiSelectTag":
                return componentProps.type === "checkbox" ? comMultiSelectTagCheckBox : comMultiSelectTag
            case "SelectMultiUser":
                return comSelectMultiUser
            case "SelectMultiDep":
                return comSelectMultiDep
            default:
                return comUnsupported
        }
    }

    function tableUpdateAll(tablePane) {
        if (tableModel === "modalAllModel") {
            showError(qsTr("弹窗一起保存模式暂未支持"))
            return false
        }

        var updateObj = {
            insertRecords: []
            , updateRecords: []
            , removeRecords: tablePane.removeRecords
        }
        var sysUpdateFieldNames = {}
        for (var key in tablePane.tableView.editedRows) {
            var row = tablePane.tableView.editedRows[key]
            var rowObj = tablePane.tableView.getRow(row)
            var temp = {}
            for (var field in tablePane.editFieldColumn) {
                var column = tablePane.editFieldColumn[field]
                if (column === -1) {
                    continue
                }

                var config = tablePane.tableView.columnSource[column]
                if (config.required === true && !rowObj[field]) {
                    showError(config.title + qsTr("不能为空"))
                    return false
                }
                temp[field] = rowObj[field]
                sysUpdateFieldNames[field] = true
            }

            if (rowObj.id) {
                temp.id = rowObj.id //必须
                updateObj.sysUpdateFieldNames = Object.keys(sysUpdateFieldNames)
                updateObj.updateRecords.push(temp)
            } else {
                if (windowFormData && windowFormData.relatedField && windowFormData.rowFormData.id) {
                    temp[windowFormData.relatedField] = windowFormData.rowFormData.id
                }
                updateObj.insertRecords.push(temp)
            }
        }

        if (updateObj.updateRecords.length <= 0 && updateObj.insertRecords.length <= 0 && updateObj.removeRecords.length <= 0) {
            return undefined
        }

        tablePane.tableView.editedRows = {}
        return updateObj
    }

    function openFormWindow(isNew) {
        FluRouter.navigate("/onlineWindow", {
                               windowFormData: {
                                   parentTableId: tableId
                                   , formConfig: formConfig
                                   , tabConfig: tabConfig
                                   , childTableConfig: isNew ? [] : childTableConfig
                                   , rowFormData: isNew ? {} : rowFormData
                                   , formTitle: formTitle
                               }
                           }, root)
    }
}
