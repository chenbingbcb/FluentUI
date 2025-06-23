import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import example 1.0
import "../global"

FluContentPage{

    id:root
    objectName: "T_OnlineList_1"
    signal checkBoxChanged

    property string getColumnsUrl: "/online/genFormAPI/getColumns/1920671189235699714/043780fa095ff1b2bec4dc406d76f023"
    property string getFormConfigUrl: "/online/genFormAPI/getFormConfig/1920759948459421697/043780fa095ff1b2bec4dc406d76f023"
    property string getTableDataUrl: "/online/genFormAPI/getTableData/1920671189235699714"
    property string updateFormDataUrl: "/online/genFormAPI/updateFormData/1920671189235699714"
    property string delDataByParamsUrl: "/online/genFormAPI/delDataByParams/1920671189235699714"
    property bool isModalEdit: true
    property int sortType: 0
    property bool selectedAll: false
    property string nameKeyword: ""
    property QtObject table_view
    property QtObject queryForm
    property var textBoxQueryValues: []
    property var queryFields: []
    property var queryFormConfig: null
    property var formConfig: null
    property QtObject tableFormEdit

    onNameKeywordChanged: {
        table_view.filter(function(item){
            if(item.name.includes(nameKeyword)){
                return true
            }
            return false
        })
    }

    Component.onCompleted: {
        Network.get(GlobalModel.basicUrl + getColumnsUrl)
        .addHeader("S-Token", GlobalModel.token)
        .bind(root)
        .go(getColumnsCallable)
    }

    NetworkCallable{
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

                if (jsResult.result.useSearchForm) {
                    queryFormConfig = jsResult.result.formConfig
                    queryForm = comQueryForm.createObject(gagination.parent)
                }

                var temp = []
                jsResult.result.columns.forEach(function(item) {
                    if (item.ifShow !== false) {
                        var dataIndex = typeof item.format === "string" && item.format.startsWith("column|") ? item.format.slice(7) : item.dataIndex
                        temp.push({
                            title: item.title,
                            dataIndex: dataIndex,
                            width: item.width || 100
                        })
                    }
                })

                if (typeof jsResult.result.actionColumn === "object") {
                    var actionColumn = jsResult.result.actionColumn
                    temp.push({
                        title: actionColumn.title,
                        dataIndex: actionColumn.dataIndex,
                        width: actionColumn.width || 100,
                        frozen: true
                    })
                }

                table_view = comTableView.createObject(gagination.parent, {columnSource: temp}) //FluTableView作为Component后, 其parent要跟原来的一样
                getTableDataRequest()
                isModalEdit = jsResult.result.tableModel === "modalSingleModel" || jsResult.result.tableModel === "modalAllModel"
                if (isModalEdit) {
                    getFormConfigRequest()
                }
            }
    }

    function getFormConfigRequest() {
        Network.get(GlobalModel.basicUrl + getFormConfigUrl)
        .addHeader("S-Token", GlobalModel.token)
        .bind(root)
        .go(getFormConfigCallable)
    }

    NetworkCallable{
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
                formConfig.schemas = formConfig.schemas || []
                var tabConfig = []
                var childTableConfig = []
                for (var i = formConfig.schemas.length - 1; i >= 0; i--) {
                    var schema = formConfig.schemas[i];
                    if (schema.component === "Tab") {
                        tabConfig = schema
                        formConfig.schemas.splice(i, 1);
                    } else if (schema.component === "childTable") {
                        childTableConfig.push(schema);
                        formConfig.schemas.splice(i, 1);
                    }
                }
                tableFormEdit = comTableFormEdit.createObject(root, {
                                                                  formConfig: formConfig
                                                                  , tabConfig: tabConfig
                                                                  , childTableConfig: childTableConfig
                                                              })
            }
    }

    function getTableDataRequest() {
        var networkParams = Network.get(GlobalModel.basicUrl + getTableDataUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("order", "asc")
        .addQuery("column", "createTime")
        .addQuery("pageNo", gagination.pageCurrent)
        .addQuery("pageSize", gagination.__itemPerPage)

        textBoxQueryValues.forEach(function(item, index) {
            if (item.text !== "") {
                networkParams.addQuery(queryFields[index].trim(), item.text)
            }
        })

        networkParams.go(getTableDataCallable)
    }

    NetworkCallable{
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

                loadData(jsResult.result.records, jsResult.result.total, jsResult.result.size, jsResult.result.current)
            }
    }

    function updateFormDataRequest(row) {
        var networkParams = Network.putJson(GlobalModel.basicUrl + updateFormDataUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)

        table_view.closeEditor()
        var obj = table_view.getRow(row)
        for(var key in obj) {
            networkParams.add(key, obj[key])
        }

        networkParams.go(updateFormDataCallable)
    }

    NetworkCallable{
        id: updateFormDataCallable
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
                    showError(qsTr(updateFormDataUrl + " failed: " + result))
                    return
                }

                getTableDataRequest()
            }
    }

    function delDataByParamsRequest(row) {
        var obj = table_view.getRow(row)
        var networkParams = Network.deleteJson(GlobalModel.basicUrl + delDataByParamsUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("id", obj.id)
        .go(delDataByParamsCallable)

        table_view.closeEditor()
        table_view.removeRow(row)
    }

    NetworkCallable{
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

                getTableDataRequest()
            }
    }

    onCheckBoxChanged: {
        // for(var i =0;i< table_view.rows ;i++){
        //     if(false === table_view.getRow(i).checkbox.options.checked) {
        //         root.selectedAll = false
        //         return
        //     }
        // }
        // root.selectedAll = true
    }

    onSortTypeChanged: {
        table_view.closeEditor()
        if(sortType === 0){
            table_view.sort()
        }else if(sortType === 1){
            table_view.sort(
                        (l, r) =>{
                            var lage = Number(l.age)
                            var rage = Number(r.age)
                            if(lage === rage){
                                return l._key>r._key
                            }
                            return lage>rage
                        });
        }else if(sortType === 2){
            table_view.sort(
                        (l, r) => {
                            var lage = Number(l.age)
                            var rage = Number(r.age)
                            if(lage === rage){
                                return l._key>r._key
                            }
                            return lage<rage
                        });
        }
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
                    model: queryFormConfig.schemas
                    delegate: Item {
                        Layout.columnSpan: modelData.colProps.span
                        Layout.preferredWidth: parent.width / (24 / modelData.colProps.span)
                        Layout.alignment: Qt.AlignRight
                        Layout.topMargin: 5
                        Layout.bottomMargin: 5
                        height: label.height
                        property alias textBox: textBoxQueryValue
                        FluText{
                            id: label
                            anchors{
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                            text: modelData.label
                            height: 32
                            width: 120
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignRight
                        }

                        FluTextBox {
                            id: textBoxQueryValue
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
                                     queryFields.push(model[index].field)
                                     root.textBoxQueryValues.push(item.textBox)
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
                            textBoxQueryValues.forEach(function(item) {
                                item.text = ""
                            })
                            getTableDataRequest()
                        }
                    }

                    FluFilledButton{
                        id: btnQuery
                        text: qsTr("查询")
                        onClicked: {
                            getTableDataRequest()
                        }
                    }

                    FluFilledButton{
                        text: qsTr("新增")
                        onClicked: {
                            table_view.insertRow(0,{})
                        }
                    }

                    FluFilledButton{
                        Layout.rightMargin: 10
                        text: qsTr("保存")
                        onClicked: {

                        }
                    }
                }
            }
        }
    }

    Component{
        id:com_checbox
        Item{
            FluCheckBox{
                anchors.centerIn: parent
                checked: true === options.checked
                animationEnabled: false
                clickListener: function(){
                    var obj = table_view.getRow(row)
                    obj.checkbox = table_view.customItem(com_checbox,{checked:!options.checked})
                    table_view.setRow(row,obj)
                    checkBoxChanged()
                }
            }
        }
    }

    Component{
        id:com_column_checbox
        Item{
            RowLayout{
                anchors.centerIn: parent
                FluText{
                    text: qsTr("Select All")
                    Layout.alignment: Qt.AlignVCenter
                }
                FluCheckBox{
                    checked: true === root.selectedAll
                    animationEnabled: false
                    Layout.alignment: Qt.AlignVCenter
                    clickListener: function(){
                        root.selectedAll = !root.selectedAll
                        var checked = root.selectedAll
                        var columnModel = model.display
                        columnModel.title = table_view.customItem(com_column_checbox,{"checked":checked})
                        model.display = columnModel
                        for(var i =0;i< table_view.rows ;i++){
                            var rowData = table_view.getRow(i)
                            rowData.checkbox = table_view.customItem(com_checbox,{"checked":checked})
                            table_view.setRow(i,rowData)
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
                    visible: !isModalEdit
                    iconSource: FluentIcons.Save
                    iconSize: 15
                    onClicked: {
                        updateFormDataRequest(row)
                    }
                }
                FluIconButton{
                    visible: isModalEdit
                    iconSource: FluentIcons.Edit
                    iconSize: 15
                    onClicked: {
                        tableFormEdit.open()
                    }
                }
                FluIconButton{
                    visible: isModalEdit
                    iconSource: FluentIcons.BulletedList
                    iconSize: 15
                    onClicked: {
                        tableFormEdit.open()
                    }
                }
                FluIconButton{
                    iconSource: FluentIcons.Delete
                    iconSize: 15
                    onClicked: {
                        double_btn_dialog.open()
                    }
                    FluContentDialog{
                        id:double_btn_dialog
                        title: qsTr("删除确认")
                        message: qsTr("是否确认删除?")
                        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
                        negativeText: qsTr("取消")
                        positiveText: qsTr("确认")
                        onPositiveClicked:{
                            delDataByParamsRequest(row)
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
            onRowsChanged: {
                root.checkBoxChanged()
            }
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
                table_view.closeEditor()
                getTableDataRequest()
                table_view.resetPosition()
            }
    }

    Component {
        id: comTableFormEdit
        FluTableFormDialog{
            width: root.width - 1
            height: root.height - 1
            x: parent.width - width
            y: parent.height - height
            strTitle: qsTr("编辑")
            schemas: queryFormConfig.schemas
        }
    }

    function loadData(records, total, size, current){
        var dataSource = []
        records.forEach(function(record) {
            var rowData = {
                _key: FluTools.uuid(),
                _minimumHeight: 50
            }
            table_view.columnSource.forEach(function(column) {
                if (column.dataIndex === "action") {
                    rowData[column.dataIndex] = table_view.customItem(com_action)
                } else {
                    rowData[column.dataIndex] = record[column.dataIndex] || ""
                }
            })
            dataSource.push(rowData)
        })

        table_view.dataSource = dataSource
        gagination.itemCount = total || 0
        gagination.__itemPerPage = size || 10
    }
}
