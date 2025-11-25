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
    property int tableIndex: 0 //当前table索引 默认0
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
    property var getColumnsListener: getColumnsRequest //列表配置回调
    property var getDictItemsListener: getDictItemsRequest //字典编码查询回调

    property int defaultCellWidth: 100
    property int defaultCellHeight: 50
    property string tableModel: "modalSingleModel" //modalSingleModel:弹窗单行保存 modalAllModel:弹窗一起保存 editSingleModel:可编辑单行保存 editAllModel:可编辑一起保存
    property var tablePanes: ({}) //子表面板map 子表数组索引做key
    property var tablePane
    property var tableView: tablePane ? tablePane.tableView : undefined
    property var pageNo: tablePane ? tablePane.gagination.pageCurrent : 1
    property var pageSize: tablePane ? tablePane.gagination.__itemPerPage : 10
    property var parentTableForm
    // property var dictItemsMap: ({}) //字典数据
    // property var listUrlMap: ({}) //url数据

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
                tablePane.getTableDataListener()
                tablePane.getFormConfigListener()
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

        for(var key in tablePane.queryParams) {
            if (tablePane.queryParams[key].text !== "") {
                networkParams.addQuery(key, tablePane.queryParams[key].text)
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
            }
    }

    function getFormConfigRequest() {
        if (!formId || (tableModel === "editSingleModel" || tableModel === "editAllModel")) {
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

    function getDataByParamsRequest(row, formTitle) {
        getDataByParamsCallable.formTitle = formTitle
        var obj = tableView.getRow(row)
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + getDataByParamsUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("id", obj.id)
        .go(getDataByParamsCallable)
    }

    FluNetworkCallable{
        id: getDataByParamsCallable
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
                tablePane.openFormWindowListener(false, formTitle)
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

                tablePane.getTableDataListener()
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
                        if (_windowRegister && _windowRegister.tablePane) { //若有父表 则更新父表显示
                            _windowRegister.tablePane.getTableDataListener()
                        }
                        close()
                    } else {
                        tablePane.getTableDataListener()
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
                        if (_windowRegister && _windowRegister.tablePane) { //若有父表 则更新父表显示
                            _windowRegister.tablePane.getTableDataListener()
                        }
                        close()
                    } else {
                        tablePane.getTableDataListener()
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

                tablePane.getTableDataListener()
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

        customAfterForm()

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
                width: 160/*actionColumn.width || defaultCellWidth*/,
                minimumWidth: actionColumn.width || defaultCellWidth,
                frozen: true
            })
        }

        var comTablePane = Qt.createComponent("FluTablePane.qml")
        if (comTablePane.status !== Component.Ready) {
            console.error(comTablePane.errorString())
            return
        }
        tablePane = comTablePane.createObject(rootLayout, {columnSource: temp
                                                            , editFieldColumn: editFieldColumn
                                                            , tableConfig: tableConfig
                                                            , tableModel: tableModel
                                                            , windowFormData: windowFormData
                                                            , tableId: tableId
                                                            , tableIndex: tableIndex
                                                            , getTableDataListener: getTableDataRequest
                                                            , getFormConfigListener: getFormConfigRequest
                                                            , getDataByParamsListener: getDataByParamsRequest
                                                            , delDataByParamsListener: delDataByParamsRequest
                                                            , addFormDataListener: addFormDataRequest
                                                            , updateFormDataListener: updateFormDataRequest
                                                            , updateAllListener: updateAllRequest
                                                            , openFormWindowListener: openFormWindow
                                                            , tableCustomActionListener: tableCustomActionListener
                                                            , rowCustomActionListener: rowCustomAction
                                                        })
        tablePanes[tableIndex] = tablePane
    }

    onTableDataChanged: {
        var dataSource = []
        tableData.records.forEach(function(record) {
            record._key = FluTools.uuid()
            record._minimumHeight = defaultCellHeight
            record.action = tableView.customItem(tableView.comAction)
            dataSource.push(record)
        })

        tableView.dataSource = dataSource
        tableView.editedRows = {}
        tablePane.gagination.itemCount = tableData.total || 0
        tablePane.gagination.__itemPerPage = tableData.size || 10
    }

    onFormConfigChanged: {
        formConfig.schemas = formConfig.schemas || []
        childTableConfig = []
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

    ColumnLayout {
        id: rootLayout
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

                FluFilledButton {
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
                                showInfo(qsTr("无可更新"))
                                return
                            }

                            for (var key in tablePanes) {
                                tablePanes[key].tableView.editedRows = {}
                            }

                            newData.sysUpdateFieldNames = sysUpdateFieldNames
                            updateFormDataRequest(windowFormData.parentTableId, newData)
                        } else {
                            addFormDataRequest(windowFormData.parentTableId, newData)
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
                            , removeRecords: tablePane.removeRecords || []
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

                        return updateObj
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
                                                tableId = tablePane.tableId
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
        }
    }

    function getComponentByType(component, componentProps) {
        var url = ""
        switch (component) {
            case "Input":
                url = "FluFormInput.qml"
                break
            case "Textarea":
                url = "FluFormTextArea.qml"
                break
            case "Switch":
                url = "FluFormSwitch.qml"
                break
            case "DatePicker":
                url = componentProps.showTime === true ? "FluFormDateTimePicker.qml" : "FluFormDatePicker.qml"
                break
            case "TimePicker":
                url = "FluFormTimePicker.qml"
                break
            case "SearchSelect":
                url = "FluFormSearchSelect.qml"
                break
            case "DictSelectTag":
                url = componentProps.type === "radio" ? "FluFormDictSelectTagRadio.qml" : "FluFormDictSelectTag.qml"
                break
            case "MultiSelectTag":
                url = componentProps.type === "checkbox" ? "FluFormMultiSelectTagCheckBox.qml" : "FluFormMultiSelectTag.qml"
                break
            case "SelectMultiUser":
                url = "FluFormSelectMultiUser.qml"
                break
            case "SelectMultiDep":
                url = "FluFormSelectMultiDep.qml"
                break
            default:
                url = "FluFormUnsupported.qml"
        }

        return Qt.createComponent(url)
    }

    function openFormWindow(isNew, formTitle) {
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

    // table自定义操作回调 开口暴露给应用层自定义
    function tableCustomActionListener(tableIndex, loaderTableCustomAction) {
        loaderTableCustomAction.setSource("FluIconButton.qml", {iconSource: FluentIcons.Wifi})
    }

    // row自定义操作回调 开口暴露给应用层自定义
    function rowCustomAction(row, loaderRowCustomAction) {
        loaderRowCustomAction.setSource("FluIconButton.qml", {iconSource: FluentIcons.Wifi})
    }

    // 表单后面的组件 开口暴露给应用层自定义
    function customAfterForm() {
        var com = Qt.createComponent("FluIconButton.qml")
        com.createObject(rootLayout, {iconSource: FluentIcons.Wifi})
    }
}
