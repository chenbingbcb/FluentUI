import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import "../component"

FluWindow {
    id: window
    minimumWidth: 1000
    minimumHeight: 668
    property var tablePane
    property var currentRowObj: ({})
    property var childTablePanes: []

    onInitArgument:
        (argument)=>{
            loaderTablePane.sourceComponent = comTablePane
            tablePane = loaderTablePane.item
        }

    FluScrollablePage {
        id: root
        anchors.fill: parent
        Component.onCompleted: {
        }


        FluLoader {
            id: loaderTablePane
            Layout.fillWidth: true
        }

        Component {
            id: comTablePane
            FluTablePane {
                listUrl: '/online/authHead/listHeader'
                deleteUrl: '/online/authHead/deleteRel'
                addUrl: '/online/authHead/addHeader'
                editUrl: '/online/authHead/updateMainSub'
                queryByIdUrl: '/online/authHead/queryById'
                addCallback: addHeaderCallable.httpRequest
                deleteCallback: deleteRelCallable.httpRequest
                relatedFields: ["id", "roleId"]
                relatedRowData: argument.relatedRowData
                tableTitle: "权限管理"
                rowActionDelegate: comRowAction
                tableActionDelegate: comTableCustomAction
                tableConfig: {
                    "tableModel": "modalSingleModel",
                    "formConfig": {
                        "labelWidth": 120,
                        "schemas": [
                            {
                              field: 'title',
                              label: '标题',
                              component: 'Input',
                              colProps: { span: 8 },
                            },
                            {
                              field: 'menuId',
                              label: '菜单id',
                              component: 'SelectMenu',
                              colProps: { span: 8 },
                            },
                            {
                              field: 'formId',
                              label: '表单管理id',
                              component: 'SelectForm',
                              colProps: { span: 8 },
                            },
                            {
                              field: 'tableId',
                              label: '列表管理id',
                              component: 'SelectTable',
                              colProps: { span: 8 },
                            },
                        ]
                    },
                    "columns": [
                        {
                          title: 'id',
                          align: 'center',
                          dataIndex: 'id',
                          width: 200,
                          resizable: true,
                        },
                        {
                          title: '标题',
                          align: 'center',
                          dataIndex: 'title',
                          width: 200,
                          resizable: true,
                        },
                        {
                          title: '菜单id',
                          align: 'center',
                          dataIndex: 'menuId_dictText',
                        },
                        {
                          title: '表单管理id',
                          align: 'center',
                          dataIndex: 'formId_dictText',
                        },
                        {
                          title: '列表管理id',
                          align: 'center',
                          dataIndex: 'tableId_dictText',
                        },
                    ],
                    "actionColumn": {
                        "width": 120,
                        "title": "操作",
                        "dataIndex": "action"
                    },
                    "defaultButtons": {
                        "add": {
                            "visible": true
                        },
                        "edit": {
                            "visible": true
                        },
                        "delete": {
                            "visible": true
                        }
                    },
                }
                formConfig: {
                    "schemas": [
                        {
                          field: 'id',
                          label: 'id',
                          component: 'Input',
                          ifShow: false,
                        },
                        {
                          field: 'title',
                          label: '标题',
                          component: 'Input',
                          required: true,
                        },
                        {
                          field: 'menuId',
                          label: '菜单id',
                          component: 'SelectMenu',
                        },
                        {
                          field: 'formId',
                          label: '表单管理id',
                          component: 'SelectForm',
                        },
                        {
                          field: 'tableId',
                          label: '列表管理id',
                          component: 'SelectTable',
                        },
                        {
                          field: 'authField',
                          label: '字段权限表',
                          component: 'childTable',
                          componentProps: {
                              relatedField: "id:mainId",
                          },
                        },
                        {
                          field: 'authButton',
                          label: '按钮权限表',
                          component: 'childTable',
                          componentProps: {
                              relatedField: "id:mainId",
                          },
                        },
                        {
                          field: 'authData',
                          label: '数据权限表',
                          component: 'childTable',
                          componentProps: {
                              relatedField: "id:mainId",
                          },
                        },
                    ]
                }
                childTableCustomConfig: [
                    {
                        tableModel: "editAllModel",
                        tableConfig: {
                            "columns": [
                                {
                                  title: 'id',
                                  dataIndex: 'id',
                                  width: 200,
                                  ifShow: false,
                                  "editComponent": "Input",
                                  "editComponentProps": {},
                                },
                                {
                                  title: '字段名',
                                  dataIndex: 'code',
                                  width: 200,
                                  "editComponent": "Input",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '显示名',
                                  dataIndex: 'name',
                                  "editComponent": "Input",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '列表显示',
                                  dataIndex: 'listVisible',
                                  "editComponent": "Switch",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '表单显示',
                                  dataIndex: 'formVisible',
                                  "editComponent": "Switch",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '列表可编辑',
                                  dataIndex: 'listEdit',
                                  "editComponent": "Switch",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '表单可编辑',
                                  dataIndex: 'formEdit',
                                  "editComponent": "Switch",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                            ],
                            "actionColumn": {
                                "width": 120,
                                "title": "操作",
                                "dataIndex": "action"
                            },
                            "defaultButtons": {
                                "add": {
                                    "visible": true
                                },
                                "edit": {
                                    "visible": true
                                },
                                "delete": {
                                    "visible": true
                                }
                            },
                        },
                        listUrl: "/online/authFiled/list",
                        tableActionDelegate: comAuthFieldTableCustomAction
                    },
                    {
                        tableModel: "editAllModel",
                        tableConfig: {
                            "columns": [
                                {
                                  title: 'id',
                                  dataIndex: 'id',
                                  width: 200,
                                  ifShow: false,
                                  "editComponent": "Input",
                                  "editComponentProps": {},
                                },
                                {
                                  title: '按钮code',
                                  dataIndex: 'code',
                                  width: 200,
                                  "editComponent": "Input",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '按钮名称',
                                  dataIndex: 'permissionTag',
                                  "editComponent": "Input",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '列表可见',
                                  dataIndex: 'listVisible',
                                  "editComponent": "Switch",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '表单可见',
                                  dataIndex: 'formVisible',
                                  "editComponent": "Switch",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '列表可用',
                                  dataIndex: 'listEnble',
                                  "editComponent": "Switch",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '表单可用',
                                  dataIndex: 'formEnable',
                                  "editComponent": "Switch",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                            ],
                            "actionColumn": {
                                "width": 120,
                                "title": "操作",
                                "dataIndex": "action"
                            },
                            "defaultButtons": {
                                "add": {
                                    "visible": true
                                },
                                "edit": {
                                    "visible": true
                                },
                                "delete": {
                                    "visible": true
                                }
                            },
                        },
                        listUrl: "/online/authButton/list",
                        tableActionDelegate: comAuthButtonTableCustomAction
                    },
                    {
                        tableModel: "editAllModel",
                        tableConfig: {
                            "columns": [
                                {
                                  title: 'id',
                                  dataIndex: 'id',
                                  width: 200,
                                  ifShow: false,
                                  "editComponent": "Input",
                                  "editComponentProps": {},
                                },
                                {
                                  title: '规则名称',
                                  dataIndex: 'ruleName',
                                  width: 200,
                                  "editComponent": "Input",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '规则字段',
                                  dataIndex: 'ruleColumn',
                                  "editComponent": "Input",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '规则条件',
                                  dataIndex: 'ruleConditions',
                                  "editComponent": "DictSelectTag",
                                  "editComponentProps": {"dictCode": "rule_conditions"},
                                  "format": "dict|rule_conditions",
                                  "editRow": true,
                                },
                                {
                                  title: '规则值',
                                  dataIndex: 'ruleValue',
                                  "editComponent": "Input",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                                {
                                  title: '状态',
                                  dataIndex: 'status',
                                  "editComponent": "Switch",
                                  "editComponentProps": {},
                                  "editRow": true,
                                },
                            ],
                            "actionColumn": {
                                "width": 120,
                                "title": "操作",
                                "dataIndex": "action"
                            },
                            "defaultButtons": {
                                "add": {
                                    "visible": true
                                },
                                "edit": {
                                    "visible": true
                                },
                                "delete": {
                                    "visible": true
                                }
                            },
                        },
                        listUrl: "/online/authData/list",
                    },
                ]
            }
        }

        FluNetworkCallable{
            id: queryByIdCallable
            property string postfixUrl: "/online/authHead/queryById"
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
                        showError(qsTr(postfixUrl + " failed: " + result))
                        return
                    }

                    FluRouter.navigate("/onlineFormWindow", {
                                           formPaneData: {
                                               formConfig: tablePane.formConfig
                                               , formData: jsResult.result
                                               , title: formTitle
                                               , parent: tablePane
                                               , childTableCustomConfig: tablePane.childTableCustomConfig
                                           }
                                       }, tablePane)


                    var formPane = tablePane._to.formPane
                    childTablePanes = formPane.tablePanes
                }

            function httpRequest(rowDataId, formTitle) {
                queryByIdCallable.formTitle = formTitle
                var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
                .bind(root)
                .addHeader("S-Token", GlobalModel.token)
                .addQuery("id", rowDataId)
                .go(queryByIdCallable)
            }
        }

        Component {
            id: comRowAction
            Item{
                RowLayout{
                    anchors.centerIn: parent
                    spacing: 0

                    FluIconButton {
                        id: editButton
                        iconSource: FluentIcons.Edit
                        iconSize: 15
                        onClicked: {
                            currentRowObj = tablePane.tableView.getRow(row)
                            queryByIdCallable.httpRequest(currentRowObj.id, qsTr("修改"))
                        }
                    }

                    FluIconButton {
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
                                var rowObj = tablePane.tableView.getRow(row)
                                if (rowObj.id) {
                                    tablePane.deleteCallback(row)
                                }

                                tablePane.tableView.removeRow(row)
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: comTableCustomAction
            RowLayout {
                Layout.fillWidth: true

                property var relateAuthFormConfig: ({
                    schemas: [
                        {
                            field: 'authorities',
                            label: '权限',
                            component: 'SelectAuthority',
                        },
                    ]
                })

                FluNetworkCallable{
                    id: relHeaderCallable
                    property string postfixUrl: "/online/authHead/relHeader"
                    onStart: {
                        showLoading()
                    }
                    onFinish: {
                        hideLoading()
                    }
                    onError:
                        (status,errorString,result)=>{
                            tablePane._to.showError(qsTr(status+";"+errorString+";"+result))
                        }
                    onSuccess:
                        (result)=>{
                            var jsResult = JSON.parse(result)
                            console.debug(JSON.stringify(jsResult, null, 2))
                            if (jsResult.code !== 200) {
                                tablePane._to.showError(qsTr(postfixUrl + " failed: " + result))
                                return
                            }

                            if (tablePane._to.close) {
                                tablePane._to.close()
                            }

                            tablePane.listCallback()
                        }

                    function httpRequest() {
                        var networkParams = FluNetwork.postJson(GlobalModel.basicUrl + postfixUrl)
                        .bind(root)
                        .addHeader("S-Token", GlobalModel.token)

                        var formPane = tablePane._to.formPane
                        var loaderItem = formPane.formRepeater.itemAt(0).loaderItem
                        networkParams.addQuery("perId", loaderItem.value)
                        networkParams.addQuery("roleId", tablePane.relatedRowData.id)

                        networkParams.go(relHeaderCallable)
                    }
                }

                FluFilledButton {
                    text: qsTr("关联权限")
                    onClicked: {
                        FluRouter.navigate("/onlineFormWindow", {
                                               formPaneData: {
                                                   formConfig: relateAuthFormConfig
                                                   , title: qsTr("关联权限")
                                                   , parent: tablePane
                                                   , formDataSaveListener: relHeaderCallable.httpRequest
                                               }
                                           }, tablePane)
                    }
                }

                FluFilledButton {
                    text: qsTr("清除缓存")
                    onClicked: {
                        clearCacheCallable.httpRequest()
                    }
                }
            }
        }

        FluNetworkCallable{
            id: clearCacheCallable
            property string postfixUrl: "/online/authHead/clearCache"
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
                        showError(qsTr(postfixUrl + " failed: " + result))
                        return
                    }

                    showInfo(jsResult.result)
                }

            function httpRequest() {
                var networkParams = FluNetwork.postJson(GlobalModel.basicUrl + postfixUrl)
                .bind(root)
                .addHeader("S-Token", GlobalModel.token)

                networkParams.go(clearCacheCallable)
            }
        }

        FluNetworkCallable {
            id: deleteRelCallable
            property string postfixUrl: "/online/authHead/deleteRel"
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
                        showError(qsTr(postfixUrl + " failed: " + result))
                        return
                    }

                    tablePane.listCallback()
                }

            function httpRequest(row) {
                var obj = tablePane.tableView.getRow(row)
                var networkParams = FluNetwork.deleteJson(GlobalModel.basicUrl + postfixUrl)
                .bind(root)
                .addHeader("S-Token", GlobalModel.token)
                .addQuery("perId", obj.id)
                .addQuery("roleId", tablePane.relatedRowData.id)
                .go(deleteRelCallable)
            }
        }

        FluNetworkCallable {
            id: addHeaderCallable
            property string postfixUrl: "/online/authHead/addHeader"
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
                        showError(qsTr(postfixUrl + " failed: " + result))
                        return
                    }

                    tablePane.listCallback()
                }

            function httpRequest(params) {
                var networkParams = FluNetwork.postJson(GlobalModel.basicUrl + postfixUrl)
                .bind(root)
                .addHeader("S-Token", GlobalModel.token)
                .addQuery("roleId", tablePane.relatedRowData.id)

                for(var key in params) {
                    networkParams.add(key, params[key])
                }

                networkParams.go(addHeaderCallable)
            }
        }

        Component {
            id: comAuthFieldTableCustomAction
            RowLayout {
                id: rowRelField
                Layout.fillWidth: true

                property var authFieldFormConfig: ({
                    schemas: [
                        {
                            field: 'field',
                            label: '字段',
                            component: 'SelectField',
                        },
                    ]
                })

                function authFieldAdd() {
                    var childTablePane = childTablePanes[0]
                    var formPane = childTablePane._to.formPane
                    var loaderItem = formPane.formRepeater.itemAt(0).loaderItem
                    if (loaderItem.value) {
                        var selectFieldItem = loaderItem.item
                        var codes = loaderItem.value.split(",")
                        var names = selectFieldItem.displayText.split(", ")

                        codes.forEach(function(code, index) {
                            var uuid = FluTools.uuid()
                            var rowObj = {
                                _key: uuid
                                , _minimumHeight: childTablePane.defaultCellHeight
                                , action: childTablePane.tableView.customItem(childTablePane.rowActionDelegate, {newRow: uuid})
                            }

                            for (var field in childTablePane.editFieldColumn) {
                                rowObj[field] = ""
                            }

                            rowObj.code = code
                            rowObj.name = names[index]

                            for (var key in childTablePane.tableView.editedRows) {
                                var row = childTablePane.tableView.editedRows[key]
                                if (row !== undefined) {
                                    childTablePane.tableView.editedRows[key] = row + 1
                                }
                            }
                            childTablePane.tableView.editedRows[uuid] = 0
                            childTablePane.tableView.insertRow(0, rowObj)
                        })
                    }

                    if (childTablePane._to.close) {
                        childTablePane._to.close()
                    }
                }

                FluFilledButton {
                    text: qsTr("关联字段")
                    onClicked: {
                        var childTablePane = childTablePanes[0]
                        FluRouter.navigate("/onlineFormWindow", {
                                               formPaneData: {
                                                   formConfig: authFieldFormConfig
                                                   , title: qsTr("关联字段")
                                                   , parent: childTablePane
                                                   , formDataSaveListener: rowRelField.authFieldAdd
                                               }
                                           }, childTablePane)

                        var formPane = childTablePane._to.formPane
                        var loaderItem = formPane.formRepeater.itemAt(0).loaderItem
                        var selectFieldItem = loaderItem.item
                        selectFieldItem.formId = currentRowObj.formId
                        selectFieldItem.tableId = currentRowObj.tableId
                    }
                }
            }
        }

        Component {
            id: comAuthButtonTableCustomAction
            RowLayout {
                id: rowRelButton
                Layout.fillWidth: true

                property var authButtonFormConfig: ({
                    schemas: [
                        {
                            field: 'button',
                            label: '按钮',
                            component: 'SelectButton',
                        },
                    ]
                })

                function authButtonAdd() {
                    var childTablePane = childTablePanes[1]
                    var formPane = childTablePane._to.formPane
                    var loaderItem = formPane.formRepeater.itemAt(0).loaderItem
                    if (loaderItem.value) {
                        var selectButtonItem = loaderItem.item
                        var codes = loaderItem.value.split(",")
                        var permissionTags = selectButtonItem.displayText.split(", ")

                        codes.forEach(function(code, index) {
                            var uuid = FluTools.uuid()
                            var rowObj = {
                                _key: uuid
                                , _minimumHeight: childTablePane.defaultCellHeight
                                , action: childTablePane.tableView.customItem(childTablePane.rowActionDelegate, {newRow: uuid})
                            }

                            for (var field in childTablePane.editFieldColumn) {
                                rowObj[field] = ""
                            }

                            rowObj.code = code
                            rowObj.permissionTag = permissionTags[index]

                            for (var key in childTablePane.tableView.editedRows) {
                                var row = childTablePane.tableView.editedRows[key]
                                if (row !== undefined) {
                                    childTablePane.tableView.editedRows[key] = row + 1
                                }
                            }
                            childTablePane.tableView.editedRows[uuid] = 0
                            childTablePane.tableView.insertRow(0, rowObj)
                        })
                    }

                    if (childTablePane._to.close) {
                        childTablePane._to.close()
                    }
                }

                FluFilledButton {
                    text: qsTr("关联按钮")
                    onClicked: {
                        var childTablePane = childTablePanes[1]
                        FluRouter.navigate("/onlineFormWindow", {
                                               formPaneData: {
                                                   formConfig: authButtonFormConfig
                                                   , title: qsTr("关联按钮")
                                                   , parent: childTablePane
                                                   , formDataSaveListener: rowRelButton.authButtonAdd
                                               }
                                           }, childTablePane)

                        var formPane = childTablePane._to.formPane
                        var loaderItem = formPane.formRepeater.itemAt(0).loaderItem
                        var selectButtonItem = loaderItem.item
                        selectButtonItem.formId = currentRowObj.formId
                        selectButtonItem.tableId = currentRowObj.tableId
                    }
                }
            }
        }
    }
}
