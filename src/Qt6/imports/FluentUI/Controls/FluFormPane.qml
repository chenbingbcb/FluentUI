import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI

ColumnLayout{
    id: root
    property var formPaneData
    property var tabFields: []
    property var rowFormData: ({}) //单行表单数据
    property var tablePanes: ({}) //子表面板map 子表数组索引做key
    property var tablePane //当前子表
    Layout.fillWidth: true

    onFormPaneDataChanged: {
        if (formPaneData.tabConfig) {
            var fields = []
            var tabConfig = formPaneData.tabConfig
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
        }

        if (formPaneData.row > -1) {
            getDataByParamsRequest(formPaneData.row)
        }

        formPaneData.parent.customAfterFormListener(loaderCustomAfterForm)
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

    function getDataByParamsRequest(row) {
        var obj = formPaneData.parent.tableView.getRow(row)
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + formPaneData.parent.getDataByParamsUrl)
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
                    showError(qsTr(formPaneData.parent.getDataByParamsUrl + " failed: " + result))
                    return
                }

                rowFormData = jsResult.result
                var loaderItem = null
                for (var i = 0; i < tabRepeater.count; i++) {
                    loaderItem = tabRepeater.itemAt(i).loaderItem
                    loaderItem.value = rowFormData[loaderItem.config.field] || null
                    if (loaderItem.item.initDisplay) {
                        loaderItem.item.initDisplay()
                    }
                }

                for (var j = 0; j < repeater.count; j++) {
                    loaderItem = repeater.itemAt(j).loaderItem
                    loaderItem.value = rowFormData[loaderItem.config.field] || null
                    if (loaderItem.item.initDisplay) {
                        loaderItem.item.initDisplay()
                    }
                }
            }
    }

    RowLayout{
        Layout.fillWidth: true

        FluText{
            id: title
            font: FluTextStyle.Subtitle
            text: formPaneData ? formPaneData.title : ""
            leftPadding: 10
        }

        Item {
            Layout.fillWidth: true
        }

        FluFilledButton {
            visible: title.text !== qsTr("详情")
            Layout.rightMargin: 10
            text: qsTr("保存")
            onClicked: {
                // control.close()
                var newData = Object.assign({}, rowFormData)
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
                    if (formPaneData && formPaneData.childTableConfig.length > 0) {
                        for (var k = 0; k < formPaneData.childTableConfig.length; k++) {
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

                            var config = formPaneData.childTableConfig[k]
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
                    formPaneData.parent.updateFormDataRequest(newData)
                } else {
                    formPaneData.parent.addFormDataRequest(newData)
                }

                if (close) { //若有父窗口 则关闭
                    close()
                }
            }

            function tableUpdateAll(tablePane) {
                // if (tableModel === "modalAllModel") {
                //     showError(qsTr("弹窗一起保存模式暂未支持"))
                //     return false
                // }

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
                        if (tablePane.relatedField && rowFormData.id) {
                            temp[tablePane.relatedField] = rowFormData.id
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
            model: formPaneData.formConfig.schemas
            delegate: comDelegate
            onItemAdded: (index, item) => {

                         }
        }

        Item {
            Layout.fillWidth: true
        }
    }

    FluLoader {
        id: loaderCustomAfterForm
    }

    //子表tab
    FluLoader {
        Layout.fillWidth: true
        sourceComponent: formPaneData.childTableConfig.length > 0 ? comChildTableTab : undefined
    }

    Component {
        id: comChildTableTab
        ColumnLayout {
            FluRadioButtons{
                id: tableButtons
                spacing: 0
                orientation: Qt.Horizontal
                Component.onCompleted: {
                    for (var i = 0; i < formPaneData.childTableConfig.length; i++) {
                        var config = formPaneData.childTableConfig[i]
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
                                        // tableId = tablePane.tableId
                                    } else {
                                        procChildTable(i)
                                    }
                                } else if (tablePanes[i]) {
                                    tablePanes[i].visible = false
                                }
                            }
                        }
                        tableButtons.buttons.push(obj)
                    }

                    tableButtons.currentIndex = 0
                    procChildTable(0)
                }

                function procChildTable(i) {
                    if (i < 0 || i >= formPaneData.childTableConfig.length) {
                        return
                    }

                    var componentProps = formPaneData.childTableConfig[i].componentProps
                    var tableId = componentProps.genTableHeadId || componentProps.defaultValue
                    var menuId = componentProps.genMenuId || 0
                    var fieldStr = componentProps.relatedField || ""
                    var fields = fieldStr.split(":")
                    var relatedField = fields.length > 1 ? fields[1] : ""

                    var comTablePane = Qt.createComponent("FluTablePane.qml")
                    if (comTablePane.status !== Component.Ready) {
                        console.error(comTablePane.errorString())
                        return
                    }

                    var properties = {
                        formPane: root
                        , tableModel: "editAllModel" //子表的模式由web端写死
                        , tableId: tableId
                        // , formId: formId
                        , menuId: menuId
                        , relatedField: relatedField
                    }

                     //使用自定义url
                    if (formPaneData && formPaneData.childTableConfig.length > 0) {
                        var config = formPaneData.childTableConfig[i]
                        if (config.getColumnsUrl) {
                            properties.getColumnsUrl = config.getColumnsUrl
                        }
                        if (config.getTableDataUrl) {
                            properties.getTableDataUrl = config.getTableDataUrl
                        }
                    }

                    tablePane = comTablePane.createObject(root, properties)
                    tablePanes[i] = tablePane
                }
            }

            FluDivider {
                Layout.fillWidth: true
            }
        }
    }

    Component {
        id: comDelegate
        Item {
            property var columnSpan: modelData.colProps ? (modelData.colProps.span || 8) : 8
            property alias loaderItem: loader
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
                sourceComponent: formPaneData.parent.getComponentByType(config.component, config.componentProps)
            }
        }
    }
}
