import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0

FluContentPage{
    id:root

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
    property var formRowData/*: { //表单行数据
    }*/
    property bool isLocalConfig: false //是否本地配置 默认false 表示配置由web后端提供
    property var getTableDataListener: function(){} //列表查询回调
    property var updateFormDataListener: function(){} //更新回调
    property var delDataByParamsListener: function(){} //删除回调
    property var getDataByParamsListener: function(){} //表单行数据查询回调
    property var getDictItemsListener: function(dictCode){} //字典编码查询回调
    property var listUrlListener: function(listUrl, fields, pageNo){} //组件请求数据回调
    property var sysUserListListener: function(control, queryParams, display){} //用户控件查询回调
    property var sysDepartListListener: function(control, queryParams, display){} //部门控件查询回调
    signal dictItemsUpdated(string key, var dictItems) //字典数据更新通知
    property var sysAllDictItems: ({}) //所有字典数据)
    ///////////////////////////////////////以上参数由应用层赋值
    property string tableModel: "modalSingleModel" //modalSingleModel:弹窗单行保存 modalAllModel:弹窗一起保存 editSingleModel:可编辑单行保存 editAllModel:可编辑一起保存
    property alias pageNo: gagination.pageCurrent
    property alias pageSize: gagination.__itemPerPage
    property QtObject tableView
    property QtObject queryForm
    property QtObject tableFormDlg
    property var queryParams: ({}) //查询字段参数
    property var dictItemsMap: ({}) //字典数据
    property var listUrlMap: ({}) //url数据

    Component.onCompleted: {

    }

    onTableConfigChanged: {
        var temp = []
        tableConfig.columns.forEach(function(item) {
            if (item.ifShow !== false) {
                // var dataIndex = typeof item.format === "string" && item.format.startsWith("column|") ? item.format.slice(7) : item.dataIndex
                temp.push({
                    title: item.title,
                    dataIndex: item.dataIndex,
                    format: item.format,
                    width: item.width || 100,
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
                dataIndex: actionColumn.dataIndex,
                width: actionColumn.width || 100,
                frozen: true
            })
        }

        tableModel = tableConfig.tableModel
        queryForm = comQueryForm.createObject(gagination.parent)
        tableView = comTableView.createObject(gagination.parent, {columnSource: temp}) //FluTableView作为Component后, 其parent要跟原来的一样
    }

    onTableDataChanged: {
        loadData()
    }

    onFormConfigChanged: {
        formConfig.schemas = formConfig.schemas || []
        var tabConfig = {}
        var childTableConfig = []
        for (var i = formConfig.schemas.length - 1; i >= 0; i--) {
            var schema = formConfig.schemas[i];
            //分离不同类型的配置
            if (schema.component === "Tab") {
                tabConfig = schema
                formConfig.schemas.splice(i, 1);
            } else if (schema.component === "childTable") {
                childTableConfig.push(schema);
                formConfig.schemas.splice(i, 1);
            } else if (schema.ifShow === false) {
                formConfig.schemas.splice(i, 1);
            }
        }
        tableFormDlg = comTableFormDlg.createObject(root, {
                                                          formConfig: formConfig
                                                          , tabConfig: tabConfig
                                                          , childTableConfig: childTableConfig
                                                      })
    }

    onFormRowDataChanged: {
        tableFormDlg.formRowData = formRowData
        tableFormDlg.open()
    }

    Component{
        id: comQueryForm
        FluFrame{
            anchors{
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: 20
            }

            GridLayout{
                columns: 24
                columnSpacing: 0
                anchors{
                    left: parent.left
                    right: parent.right
                }

                Repeater {
                    model: tableConfig.formConfig.schemas
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
                            width: tableConfig.formConfig.labelWidth | 120
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
                        bottomMargin: 5
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
                        id: btnQuery
                        text: qsTr("查询")
                        onClicked: {
                            getTableDataListener()
                        }
                    }

                    FluFilledButton{
                        text: qsTr("新增")
                        onClicked: {
                            tableView.insertRow(0,{})
                        }
                    }

                    FluFilledButton{
                        visible: tableModel === "modalAllModel" || tableModel === "editAllModel"
                        Layout.rightMargin: 10
                        text: qsTr("保存")
                        onClicked: {
                            if (tableModel === "modalAllModel") {
                                showWarning(qsTr("弹窗一起保存模式暂未支持"))
                                return
                            }
                        }
                    }
                }
            }
        }
    }

    Component{
        id:com_action
        Item{
            RowLayout{
                anchors.centerIn: parent
                FluIconButton{
                    id: editButton
                    iconSource: FluentIcons.Edit
                    iconSize: 15
                    onClicked: {
                        if (tableModel === "editSingleModel" || tableModel === "editAllModel") {
                            if (tableModel === "editSingleModel") {
                                visible = false
                                saveButton.visible = true
                                cancelButton.visible = true
                            }
                            tableView.editRows = Object.defineProperty(tableView.editRows, row, {value: true, writable: true})
                        } else {
                            getDataByParamsListener(row)
                            if (tableFormDlg) {
                                tableFormDlg.title = qsTr("编辑")
                                tableFormDlg.editRow = row
                            }
                        }

                        for (var listUrl in listUrlMap) {
                            listUrlListener(listUrl, listUrlMap[listUrl], 1)
                        }
                    }
                }
                FluIconButton{
                    visible: tableModel === "modalSingleModel" || tableModel === "modalAllModel"
                    iconSource: FluentIcons.BulletedList
                    iconSize: 15
                    onClicked: {
                        getDataByParamsListener(row)
                        for (var listUrl in listUrlMap) {
                            listUrlListener(listUrl, listUrlMap[listUrl], 1)
                        }

                        if (tableFormDlg) {
                            tableFormDlg.title = qsTr("详情")
                        }
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
                            delDataByParamsListener(row)
                            // tableView.closeEditor()
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
                        // tableView.closeEditor()
                        tableView.editRows = Object.defineProperty(tableView.editRows, row, {value: false, writable: true})
                        var rowObj = tableView.getRow(row)
                        updateFormDataListener(rowObj)
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
                            tableView.editRows = Object.defineProperty(tableView.editRows, row, {value: false, writable: true})
                        }
                    }
                }
            }
        }
    }

    Component {
        id: comTableView
        FluTableView{
            anchors{
                left: parent.left
                right: parent.right
                top: queryForm.bottom
                bottom: gagination.top
            }
            anchors.topMargin: 5
            startRowIndex: (gagination.pageCurrent - 1) * gagination.__itemPerPage + 1
        }
    }

    FluPagination{
        id:gagination
        anchors{
            bottom: parent.bottom
            left: parent.left
        }
        pageCurrent: 1
        pageButtonCount: 7
        __itemPerPage: 10
        previousText: qsTr("<")
        nextText: qsTr(">")
        onRequestPage:
            (page,count)=> {
                // tableView.closeEditor()
                tableView.editRows = Object.defineProperty(tableView.editRows, row, {value: false, writable: true})
                tableView.resetPosition()
                getTableDataListener()
            }
    }

    function loadData(){
        var dataSource = []
        tableData.records.forEach(function(record) {
            record._key = FluTools.uuid()
            record._minimumHeight = 50
            record.action = tableView.customItem(com_action)
            dataSource.push(record)
        })

        tableView.dataSource = dataSource
        gagination.itemCount = tableData.total || 0
        gagination.__itemPerPage = tableData.size || 10
    }

    //form弹窗
    Component {
        id: comTableFormDlg
        FluPopup {
            id: control
            width: root.width - 1
            height: root.height - 1
            x: parent.width - width
            y: parent.height - height
            modal: false

            property string title: qsTr("编辑")
            property var formConfig: ({}) //控件表单正文配置
            property var tabConfig: ({}) //标签配置
            property var childTableConfig: [] //子表配置
            property var tabFields: []
            property var formRowData
            property int editRow: -1

            Component.onCompleted: {

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

            onFormRowDataChanged: {
                var loaderItem
                for (var i = 0; i < tabRepeater.count; i++) {
                    loaderItem = tabRepeater.itemAt(i).loaderItem
                    loaderItem.value = formRowData[loaderItem.config.field]
                    if (loaderItem.item.initDisplay) {
                        loaderItem.item.initDisplay()
                    }
                }

                for (var j = 0; j < repeater.count; j++) {
                    loaderItem = repeater.itemAt(j).loaderItem
                    loaderItem.value = formRowData[loaderItem.config.field]
                    if (loaderItem.item.initDisplay) {
                        loaderItem.item.initDisplay()
                    }
                }
            }

            onOpened: {
                for(var i = 0;i<tabButtons.buttons.length;i++) {
                    var button = tabButtons.buttons[i]
                    if(tabConfig.componentProps && tabConfig.componentProps.activeKey === button.contentDescription){
                        tabButtons.currentIndex = i
                        tabFields = tabConfig.componentProps.tabPanels[tabButtons.currentIndex].fields
                    }
                }
            }

            ColumnLayout{
                anchors{
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                RowLayout{
                    anchors{
                        left: parent.left
                        right: parent.right
                    }

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
                            control.close()

                            var rowObj = tableView.getRow(editRow)
                            if (!rowObj) {
                                console.error("tableView.getRow null: " + editRow)
                                return
                            }

                            var loaderItem
                            for (var i = 0; i < tabRepeater.count; i++) {
                                loaderItem = tabRepeater.itemAt(i).loaderItem
                                rowObj[loaderItem.config.field] = loaderItem.value || null
                            }

                            for (var j = 0; j < repeater.count; j++) {
                                loaderItem = repeater.itemAt(j).loaderItem
                                rowObj[loaderItem.config.field] = loaderItem.value || null
                            }

                            updateFormDataListener(rowObj)
                        }
                    }

                    FluIconButton{
                        iconSource: FluentIcons.ChromeClose
                        iconSize: 15
                        text: qsTr("Close")
                        display: Button.IconOnly
                        onClicked:{
                            control.close()
                        }
                    }
                }

                Component {
                    id: comToggleButton
                    FluToggleButton {
                        id: tabToggleButton
                        text: ""
                        contentDescription: ""
                        controlBackground.border.width: 0
                        controlBackground.gradient: null
                        clickListener: function() {}
                        property var items: []
                    }
                }

                FluRadioButtons{
                    id: tabButtons
                    spacing: 0
                    orientation: Qt.Horizontal
                    Component.onCompleted: {
                        for (var i = 0; i < tabConfig.componentProps.tabPanels.length; i++) {
                            var panel = tabConfig.componentProps.tabPanels[i]
                            var obj = Qt.createQmlObject("import FluentUI; FluToggleButton{}", tabButtons)
                            obj.text = panel.tab
                            obj.controlBackground.border.width = 0
                            obj.controlBackground.gradient = null
                            obj.contentDescription = panel.key
                            obj.clickListener = function() {
                                for(var i = 0;i<tabButtons.buttons.length;i++) {
                                    var button = tabButtons.buttons[i]
                                    if(this === button){
                                        tabButtons.currentIndex = i
                                        tabFields = tabConfig.componentProps.tabPanels[tabButtons.currentIndex].fields
                                        break
                                    }
                                }
                            }
                            tabButtons.buttons.push(obj)
                        }
                        control.onOpened() //提前加载tabFields的控件
                    }
                }

                FluDivider{
                    Layout.fillWidth: true
                }

                GridLayout{
                    id: tabPanel
                    columns: 24
                    columnSpacing: 0
                    anchors{
                        left: parent.left
                        right: parent.right
                    }

                    Repeater {
                        id: tabRepeater
                        model: tabFields
                        delegate: comDelegate
                        // onItemAdded: (index, item) => {
                        //                  //顺序在repeater.onItemAdded之后 全部添加完后执行字典编码查询回调
                        //                  if (index === model.length - 1) {
                        //                      for (var dictCode in dictItemsMap) {
                        //                          getDictItemsListener(dictCode)
                        //                      }
                        //                  }
                        //              }
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
                    anchors{
                        left: parent.left
                        right: parent.right
                    }

                    Repeater {
                        id: repeater
                        model: formConfig.schemas
                        delegate: comDelegate
                        onItemAdded: (index, item) => {

                                     }
                    }

                    Item {
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
            Layout.preferredHeight: item instanceof FluMultilineTextBox ? item.contentHeight + 16 : 32
            property alias loaderItem: loader

            FluText{
                id: label
                anchors{
                    left: parent.left
                    top: parent.top
                }
                text: modelData.label
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
                // enabled: !modelData.dynamicDisabled
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

            onTextEdited: {
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

            onEditingFinished: {
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
                control.checked = value.toLowerCase() === "true"
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
                var componentProps = config.componentProps
                if (componentProps && componentProps.listUrl) {
                    listUrlMap[componentProps.listUrl] = [componentProps.valField, componentProps.txtField]
                    return componentProps.listUrl
                }
            }
            property var textValueMap: ({})
            property var dictItems

            onMoreButtonClicked: {
                listUrlListener(listUrl, listUrlMap[listUrl], ++listPageNo)
            }

            onSelectionChanged: {
                var texts = control.displayText.split(", ")
                value = texts.map(function(text) {
                    return textValueMap[text]
                 }).join(",")
            }

            onDictItemsChanged: {
                model = model.concat(dictItems.records.map(function(item) {
                    var text = item[config.componentProps.txtField]
                    var value = item[config.componentProps.valField]
                    textValueMap[text] = value
                    return {text: text, value: value}
                }))
                update()
                initDisplay()
            }

            Connections{
                target: root
                function onDictItemsUpdated(key, dictItems) {
                    if (listUrl === key) {
                        control.dictItems = dictItems
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
            // property var dictItems: sysAllDictItems[dictCode]
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
                var dictItems = sysAllDictItems[dictCode]
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
                // property var dictItems: sysAllDictItems[dictCode]
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
                    var dictItems = sysAllDictItems[dictCode] || []
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
            property var textValueMap: ({})
            // property var dictItems: sysAllDictItems[dictCode]
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
            //     var dictItems = sysAllDictItems[dictCode]
            //     model = dictItems.map(function(item) {
            //         textValueMap[item.text] = item.value
            //         return {text: item.text, value: item.value}
            //     })
            // }

            function initDisplay() {
                if (!value) {
                    return
                }

                clearValues()
                var dictItems = sysAllDictItems[dictCode]
                model = dictItems.map(function(item) {
                    textValueMap[item.text] = item.value
                    return {text: item.text, value: item.value}
                })

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
                // property var dictItems: sysAllDictItems[dictCode]
                property var dictCode: {
                    var componentProps = config.componentProps
                    if (componentProps && componentProps.dictCode) {
                        dictItemsMap[componentProps.dictCode] = true
                        return componentProps.dictCode
                    }
                }

                // onDictItemsChanged: {
                Component.onCompleted: {
                    var dictItems = sysAllDictItems[dictCode]
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
}
