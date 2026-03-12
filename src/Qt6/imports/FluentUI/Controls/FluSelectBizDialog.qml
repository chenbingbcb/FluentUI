import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import FluentUI

FluPopup {
    id: control
    property string title: ""
    property string choosedTitle: ""
    property var columnConfig: [ //至少2列 应用层可自定义 第一项固定用于名称展示
        {
            title: "名称",
            dataIndex: 'name',
            width: 300
        },
        {
            title: "id",
            dataIndex: 'id',
            width:200
        }
    ]
    property var queryClickListener: function(){} //查询监听器

    property string negativeText: qsTr("关闭")
    property string positiveText: qsTr("确定")
    property int messageTextFormart: Text.AutoText
    property int delayTime: 100
    property bool isMoreQuery: false
    property bool isSingleSelect: false //是否单选
    property var lastObj: null
    property int buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
    property var contentDelegate:  Component{
        Item{
        }
    }
    property var onNeutralClickListener
    property var onNegativeClickListener
    property var onPositiveClickListener
    signal neutralClicked
    signal negativeClicked
    signal positiveClicked(var data)
    implicitWidth: 1000
    implicitHeight: 668
    focus: true
    Rectangle {
        id:layout_content
        width: parent.width
        height: parent.height
        color: 'transparent'
        radius:5
        ColumnLayout{
            id:root
            width: parent.width
            property bool selectedAll: false
            signal checkBoxChanged

            RowLayout{
                FluText{
                    font: FluTextStyle.Subtitle
                    text: title
                    leftPadding: 10
                    wrapMode: Text.WordWrap
                }

                Item {
                    Layout.fillWidth: true
                }

                FluIconButton{
                    iconSource: FluentIcons.ChromeClose
                    iconSize: 15
                    text: qsTr("Close")
                    display: Button.IconOnly
                    onClicked:{
                        if(control.onNegativeClickListener){
                            control.onNegativeClickListener()
                        }else{
                            negativeClicked()
                            control.close()
                        }
                    }
                }
            }

            RowLayout{
                id: layout_controls
                FluText{
                    id: textId
                    font: FluTextStyle.Body
                    text: columnConfig[1].title + ":"
                    leftPadding: 10
                }

                FluMultilineTextBox {
                    id: textBoxId
                    placeholderText: columnConfig[1].title
                    implicitWidth: 150
                }

                FluText{
                    id: textName
                    font: FluTextStyle.Body
                    text: columnConfig[0].title + ":"
                    leftPadding: 10
                }

                FluTextBox {
                    id: textBoxName
                    placeholderText: columnConfig[0].title
                    implicitWidth: 150
                }

                FluIconButton{
                    iconSource: FluentIcons.Search
                    iconSize: 15
                    text: qsTr("查询")
                    display: Button.TextBesideIcon
                    onClicked: queryClickListener()
                }

                FluIconButton{
                    iconSource: FluentIcons.Refresh
                    iconSize: 15
                    text: qsTr("重置")
                    display: Button.TextBesideIcon
                    onClicked:{
                        textBoxId.text = ""
                        textBoxName.text = ""
                        comboBoxSex.currentIndex = 0
                        calendarPicker.current = null
                        textBoxPhone.text = ""
                        queryClickListener()
                    }
                }

                FluExpander {
                    visible: isMoreQuery
                    headerText: qsTr("展开")
                    implicitWidth: 200
                    contentHeight: 110
                    ColumnLayout {
                        RowLayout {
                            FluText{
                                font: FluTextStyle.Body
                                text: qsTr("性别:")
                                leftPadding: 10
                            }

                            FluComboBox {
                                id: comboBoxSex
                                implicitWidth: 150
                                model: ListModel {
                                    ListElement { text: "" }
                                    ListElement { text: qsTr("男") }
                                    ListElement { text: qsTr("女") }
                                }
                            }
                        }

                        RowLayout {
                            FluText{
                                font: FluTextStyle.Body
                                text: qsTr("生日:")
                                leftPadding: 10
                            }

                            FluCalendarPicker{
                                id: calendarPicker
                                implicitWidth: 150
                                onAccepted:{
                                    showSuccess(current.toLocaleString())
                                }
                            }
                        }

                        RowLayout {
                            FluText{
                                font: FluTextStyle.Body
                                text: qsTr("电话:")
                                leftPadding: 10
                            }

                            FluTextBox {
                                id: textBoxPhone
                                implicitWidth: 150
                            }
                        }
                    }
                }
            }

            onCheckBoxChanged: {
                for(var i =0;i< table_view.rows ;i++){
                    if(false === table_view.getRow(i).checkbox.options.checked){
                        root.selectedAll = false
                        return
                    }
                }
                root.selectedAll = true
            }

            Component{
                id:comColumnCheckBox
                Item{
                    FluCheckBox{
                        anchors.centerIn: parent
                        checked: true === root.selectedAll
                        clickListener: function(){
                            root.selectedAll = !root.selectedAll
                            var checked = root.selectedAll
                            var columnModel = model.display
                            columnModel.title = table_view.customItem(comColumnCheckBox,{"checked":checked})
                            model.display = columnModel
                            for(var i =0;i< table_view.rows ;i++){
                                var rowData = table_view.getRow(i)
                                rowData.checkbox = table_view.customItem(getCheckOrRadioComponent(),{"checked":checked})
                                table_view.setRow(i,rowData)
                            }

                            updateChoosedTable(checked)
                        }
                    }
                }
            }

            Component{
                id:comCheckBox
                Item{
                    FluCheckBox{
                        anchors.centerIn: parent
                        checked: true === options.checked
                        clickListener: function() {
                            var obj = table_view.getRow(row)
                            obj.checkbox = table_view.customItem(comCheckBox,{checked:!options.checked})
                            table_view.setRow(row,obj)
                            root.checkBoxChanged()

                            updateChoosedRow(options.checked, obj)
                        }
                    }
                }
            }

            Component{
                id:comRadio
                Item{
                    FluRadioButton{
                        id: radioRow
                        anchors.centerIn: parent
                        checked: true === options.checked
                        clickListener: function() {
                            var obj = table_view.getRow(row)
                            obj.checkbox = table_view.customItem(comRadio,{checked:!options.checked})
                            obj.row = row
                            table_view.setRow(row,obj)
                            root.checkBoxChanged()
                            updateChoosedRow(options.checked, obj)

                            if (lastObj && options.checked) { //勾选
                                lastObj.checkbox = table_view.customItem(comRadio,{checked:false})
                                table_view.setRow(lastObj.row,lastObj)
                                root.checkBoxChanged()
                                updateChoosedRow(false, lastObj)
                            }
                            lastObj = options.checked ? obj : null
                        }
                    }
                }
            }

            Component {
                id: componentDelete
                FluTextButton {
                    text: qsTr("删除")
                    onClicked: {
                        var obj = choosedTableView.getRow(row)
                        for (var j = 0; j < table_view.rows; j++) {
                            var item = table_view.getRow(j)
                            if(item.id === obj.id){
                                item.checkbox = table_view.customItem(getCheckOrRadioComponent(),{checked:false})
                                table_view.setRow(j,item)
                                break
                            }
                        }

                        var temp = choosedTableView.dataSource
                        for (var i = temp.length - 1; i >= 0; i--) {
                            var sourceItem = temp[i]
                            if(sourceItem.id === obj.id){
                                temp.splice(i, 1)
                                choosedTableView.dataSource = temp
                                return
                            }
                        }
                    }
                }
            }

            RowLayout {
                ColumnLayout {
                    FluTableView {
                        id:table_view
                        Layout.alignment: Qt.AlignTop
                        Layout.leftMargin: 10
                        Layout.preferredWidth: 550
                        Layout.preferredHeight: 300
                        verticalHeaderVisible: false
                        onRowsChanged: {
                            root.checkBoxChanged()
                        }
                        startRowIndex: (gagination.pageCurrent - 1) * gagination.__itemPerPage + 1
                        columnSource: {
                            // var temp = [
                            //             {
                            //                 title: table_view.customItem(comColumnCheckBox,{checked:false}),
                            //                 dataIndex: 'checkbox',
                            //                 width: 50
                            //             },
                            //             {
                            //                 title: name,
                            //                 dataIndex: 'name',
                            //                 width: 300
                            //             },
                            //             {
                            //                 title: strId,
                            //                 dataIndex: 'id',
                            //                 width:200
                            //             }
                            //         ]
                            // if (control.isSingleSelect) {
                            //     temp[0].title = ""
                            // }
                            // if(orgCodeTxt !== "") { //第三列
                            //     temp.push({
                            //         title: orgCodeTxt,
                            //         dataIndex: 'orgCodeTxt',
                            //         width: 200
                            //     })
                            //     temp[1].width = 150
                            //     temp[2].width = 150
                            // }
                            var temp = [
                                        {
                                            title: control.isSingleSelect ? "" : table_view.customItem(comColumnCheckBox,{checked:false}),
                                            dataIndex: 'checkbox',
                                            width: 50
                                        }
                                    ]
                            temp = temp.concat(columnConfig)
                            return temp
                        }
                    }

                    FluPagination{
                        id:gagination
                        pageCurrent: 1
                        __itemPerPage: 5
                        pageButtonCount: 7
                        previousText: qsTr("<")
                        nextText: qsTr(">")
                        onRequestPage:
                            (page,count)=> {
                                table_view.closeEditor()
                                queryClickListener()
                                table_view.resetPosition()
                            }
                    }

                    FluComboBox {
                        id: comboBoxPageSize
                        Layout.leftMargin: 10
                        model: ListModel {
                            ListElement { text: qsTr("5条/页") }
                            ListElement { text: qsTr("10条/页") }
                            ListElement { text: qsTr("20条/页") }
                            ListElement { text: qsTr("30条/页") }
                        }
                        onActivated: {
                            var text = model.get(index).text
                            gagination.__itemPerPage = Number(text.slice(0, text.indexOf(qsTr("条/页"))))
                            queryClickListener()
                        }
                    }

                    Item {
                        Layout.leftMargin: 10
                        FluText {
                            id: textJump
                            text: qsTr("跳至               页")
                            anchors {
                                top: parent.top
                                topMargin: 5
                            }
                        }

                        FluTextBox {
                            id: textBoxPageNo
                            width: 50
                            anchors {
                                left: parent.left
                                leftMargin: 30
                            }
                            cleanEnabled: false
                            focus: true
                            inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                            onCommit: {
                                var pageNo = Number(text)
                                if (isNaN(pageNo)) {
                                    textBoxPageNo.text = ""
                                    return
                                }
                                if (pageNo < 1) {
                                    pageNo = 1
                                } else if (pageNo > gagination.pageCount) {
                                    pageNo = gagination.pageCount
                                }
                                gagination.calcNewPage(pageNo)
                                textBoxPageNo.text = ""
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignTop
                    Layout.leftMargin: 10
                    FluFrame{
                        // Layout.fillWidth: true
                        Layout.preferredWidth: 300
                        padding: 10

                        FluCopyableText{
                            text: choosedTitle
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    FluTableView {
                        id: choosedTableView
                        // Layout.fillWidth: true
                        Layout.topMargin: -6
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 300
                        Layout.minimumHeight: 200
                        verticalHeaderVisible: false
                        onRowsChanged: {
                            root.checkBoxChanged()
                        }
                        startRowIndex: (gagination.pageCurrent - 1) * gagination.__itemPerPage + 1
                        columnSource:[
                            {
                                title: columnConfig[0].title,
                                dataIndex: columnConfig[0].dataIndex,
                                // readOnly:true,
                                width: 200
                            },
                            {
                                title: qsTr("操作"),
                                dataIndex: 'delete',
                                width:100
                            }
                        ]
                    }
                }
            }
        }

        RowLayout{
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 10

            FluButton{
                id:negative_btn
                Layout.bottomMargin: 10
                text: negativeText
                onClicked: {
                    if(control.onNegativeClickListener){
                        control.onNegativeClickListener()
                    }else{
                        negativeClicked()
                        control.close()
                    }
                }
            }

            FluFilledButton{
                id:positive_btn
                Layout.bottomMargin: 10
                Layout.rightMargin: 10
                text: positiveText
                onClicked: {
                    if(control.onPositiveClickListener){
                        control.onPositiveClickListener()
                    }else{
                        positiveClicked(choosedTableView.dataSource)
                        control.close()
                    }
                }
            }
        }
    }

    function getCheckOrRadioComponent() {
        return control.isSingleSelect ? comRadio : comCheckBox
    }

    function initChoosed(records) {
        records.forEach(function(item, index) {
            item.delete = choosedTableView.customItem(componentDelete)
            item._minimumHeight = 50
        })
        choosedTableView.dataSource = records
    }

    function loadData(result) {
        root.selectedAll = false
        result.records.forEach(function(item, index) {
            item.checkbox = table_view.customItem(getCheckOrRadioComponent(),{checked:root.selectedAll})
            item._key = FluTools.uuid()
            // item.order = result.size * (result.current - 1) + index + 1 //在总数中的顺序号
            item._minimumHeight = 50
        })

        choosedTableView.dataSource.forEach(function(choosed, index) {
            for(var i = 0; i < result.records.length; i++) {
                var item = result.records[i]
                if (item.id === choosed.id) {
                    item.checkbox.options.checked = true
                    break
                }
            }
        })

        table_view.dataSource = result.records
        gagination.itemCount = result.total || 0
        gagination.__itemPerPage = result.size || 10
    }

    function getTextBoxId() {
        return textBoxId.text
    }

    function getTextBoxName() {
        return textBoxName.text
    }

    function getComboBoxSex() {
        return comboBoxSex.currentIndex
    }

    function getCalendarBirthday() {
        return calendarPicker.text
    }

    function getTextBoxPhone() {
        return textBoxPhone.text
    }

    function getPageNo() {
        return gagination.pageCurrent
    }

    function getPageSize() {
        return gagination.__itemPerPage
    }

    function updateChoosedRow(checked, obj) {
        var temp = choosedTableView.dataSource
        for (var i = 0; i < temp.length; i++) {
            var sourceItem = temp[i]
            if(sourceItem.id === obj.id){
                if (checked) {
                    return //如果存在且勾选 则不添加
                } else {
                    temp.splice(i, 1) //如果存在且不勾选 则去掉
                    break
                }
            }
        }

        if (checked) { //如果不存在且勾选 则添加
            var itemChoosed = {}
            itemChoosed.id = obj.id
            columnConfig.forEach(function(item) {
                itemChoosed[item.dataIndex] = obj[item.dataIndex]
            })
            itemChoosed._minimumHeight = 50
            itemChoosed.delete = choosedTableView.customItem(componentDelete)
            temp.push(itemChoosed)
        }

        choosedTableView.dataSource = temp
    }

    function updateChoosedTable(checked) {
        if (checked) {
            var temp = choosedTableView.dataSource
            for (var i = 0; i < table_view.rows; i++) {
                var obj = table_view.getRow(i)
                var itemChoosed = {}
                itemChoosed.id = obj.id
                columnConfig.forEach(function(item) {
                    itemChoosed[item.dataIndex] = obj[item.dataIndex]
                })
                itemChoosed._minimumHeight = 50
                itemChoosed.delete = choosedTableView.customItem(componentDelete)
                temp.push(itemChoosed)
            }

            choosedTableView.dataSource = temp
        } else {
            choosedTableView.dataSource = []
        }
    }
}
