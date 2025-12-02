import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI

ColumnLayout {
    property var getTableDataListener: function() {} //列表数据回调
    property var getFormConfigListener: function() {} //表单配置回调
    property var getDataByParamsListener: function() {} //单行表单数据回调
    property var delDataByParamsListener: function() {} //删除回调
    property var addFormDataListener: function() {} //新增回调
    property var updateFormDataListener: function() {} //更新回调
    property var updateAllListener: function() {} //批量更新回调
    property var openFormWindowListener: function() {} //打开表单窗口回调
    property var tableCustomActionListener: function() {} //table自定义操作列回调
    property var rowCustomActionListener: function() {} //row自定义操作回调
    property var editFieldColumn: ({})
    property var tableConfig: ({})
    property string tableModel: "modalSingleModel"
    property var defaultButtons: tableConfig.defaultButtons || ({})
    property var queryFormConfig: tableConfig.formConfig || ({}) //查询表单配置
    property var queryParams: ({}) //查询字段参数
    property var windowFormData
    property string addFormDataUrl: ""
    property string updateFormDataUrl: ""
    property int tableIndex: 0 //当前table索引 默认0
    property var removeRecords: [] //删除的table记录
    property alias tableView: tableView
    property alias columnSource: tableView.columnSource
    property alias gagination: gagination
    Layout.fillWidth: true

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

        Component.onCompleted: {
            tableCustomActionListener(tableIndex, loaderTableCustomAction)
        }

        FluFilledButton{
            visible: defaultButtons.add ? defaultButtons.add.visible : true
            text: qsTr("新增")
            onClicked: {
                if (tableModel === "editSingleModel" || tableModel === "editAllModel") {
                    var uuid = FluTools.uuid()
                    var rowObj = {
                        _key: uuid
                        , _minimumHeight: defaultCellHeight
                        , action: tableView.customItem(comAction, {newRow: uuid})
                    }
                    for (var field in editFieldColumn) {
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
                    openFormWindowListener(true, qsTr("编辑"))
                }
            }
        }

        FluFilledButton{
            visible: (tableModel === "modalAllModel" || tableModel === "editAllModel") && !windowFormData //子表的保存跟表单一起
            text: qsTr("保存")
            onClicked: {
                if (tableModel === "modalAllModel") {
                    showError(qsTr("弹窗一起保存模式暂未支持"))
                    return
                }

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
                updateAllListener(updateObj)
            }
        }

        FluLoader {
            id: loaderTableCustomAction
        }
    }

    FluTableView{
        id: tableView
        Layout.topMargin: -6
        Layout.fillWidth: true
        // Layout.fillHeight: true
        Layout.preferredHeight: defaultCellHeight * 10 + 42 //42为表头高度
        startRowIndex: (gagination.pageCurrent - 1) * gagination.__itemPerPage + 1
        property alias comAction: comAction

        Component{
            id:comAction
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

                        rowCustomActionListener(row, loaderRowCustomAction)
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
                                getDataByParamsListener(row, qsTr("编辑"))
                            }
                        }
                    }

                    FluIconButton{
                        visible: tableModel === "modalSingleModel" || tableModel === "modalAllModel"
                        iconSource: FluentIcons.BulletedList
                        iconSize: 15
                        onClicked: {
                            getDataByParamsListener(row, qsTr("详情"))
                        }
                    }

                    FluIconButton{
                        visible: (defaultButtons.delete ? defaultButtons.delete.visible : true) && editButton.visible
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
                                        removeRecords.push(rowObj)
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
                                updateFormDataListener(updateFormDataUrl, updateObj, true)
                            } else {
                                addFormDataListener(addFormDataUrl, updateObj, true)
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

                    FluLoader {
                        id: loaderRowCustomAction
                    }
                }
            }
        }
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
