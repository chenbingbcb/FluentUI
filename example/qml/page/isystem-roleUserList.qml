import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id: root
    property string rowDataId: ""

    RowLayout {
        FluTablePane {
            id: tablePane
            listUrl: "/sys/role/list"
            deleteUrl: "/sys/role/delete"
            addUrl: "/sys/role/add"
            editUrl: "/sys/role/edit"
            queryByIdUrl: "/sys/role/queryById"
            rowActionDelegate: comRowAction
            tableTitle: "角色管理"
            tableConfig: {
                "tableModel": "modalSingleModel",
                "formConfig": {
                    "labelWidth": 120,
                    "schemas": [
                        {
                          field: 'roleName',
                          label: '角色名称',
                          component: 'Input',
                          colProps: { span: 8 },
                        },
                        {
                          field: 'roleCode',
                          label: '角色编码',
                          component: 'Input',
                          colProps: { span: 8 },
                        },
                        {
                          field: 'description',
                          label: '描述',
                          component: 'Input',
                          colProps: { span: 8 },
                        },
                    ]
                },
                "columns": [
                    {
                      title: '角色编码',
                      align: 'center',
                      dataIndex: 'roleCode',
                    },
                    {
                      title: '角色名称',
                      align: 'center',
                      dataIndex: 'roleName',
                      width: 200,
                      resizable: true,
                    },
                    {
                      title: '创建时间',
                      dataIndex: 'createTime',
                      align: 'center',
                      sorter: true,
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
                              field: 'roleName',
                              label: '角色名称',
                              component: 'Input',
                              required: true,
                            },
                            {
                              field: 'roleCode',
                              label: '角色编码',
                              // dynamicDisabled: true,
                              component: 'Input',
                              required: true,
                            },
                            {
                              field: 'description',
                              label: '描述',
                              component: 'Input',
                            },
                            {
                              field: 'sndManagers',
                              label: '二级管理人员',
                              component: 'SelectMultiUser',
                            },
                ]
            }
        }

        ColumnLayout {
            id: relatedLayout
            visible: false
            Layout.preferredWidth: root.width / 2
            RowLayout {
                Layout.alignment: Qt.AlignRight
                FluIconButton {
                    id: closeButton
                    iconSource: FluentIcons.ChromeClose
                    iconSize: 15
                    onClicked: {
                        relatedLayout.visible = false
                    }
                }
            }

            FluTablePane {
                id: userTablePane
                listListener: userRoleListCallable.httpRequest
                addListener: userRoleAddCallable.httpRequest
                tableTitle: "用户管理"
                tableViewHeight: 250
                tableConfig: {
                    "formConfig": {
                        "labelWidth": 120,
                        "schemas": [
                            {
                                "field": "username",
                                "label": "账号",
                                "component": "Input",
                                "colProps": {
                                    "span": 8
                                }
                            },
                        ]
                    },
                    "columns": [
                        {
                            "title": "用户账号",
                            "dataIndex": "username",
                            "width": 200
                        },
                        {
                            "title": "用户姓名",
                            "dataIndex": "realname",
                            "width": 200
                        },
                        {
                            "title": "状态",
                            "dataIndex": "status_dictText",
                            "width": 200,
                            "sorter": true
                        }
                    ],
                    "actionColumn": {
                        "width": 60,
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
                            "field": "userIdList",
                            "label": "用户姓名",
                            "component": "SelectMultiUser",
                        },
                    ]
                }
            }

            FluTablePane {
                id: deptTablePane
                listListener: deptRoleListCallable.httpRequest
                addListener: deptRoleAddCallable.httpRequest
                tableTitle: "部门管理"
                tableViewHeight: 250
                tableConfig: {
                    "columns": [
                        {
                            "title": "部门ID",
                            "dataIndex": "id",
                            "width": 200
                        },
                        {
                            "title": "部门名称",
                            "dataIndex": "departName",
                            "width": 200
                        },
                        {
                            "title": "状态",
                            "dataIndex": "status_dictText",
                            "width": 200,
                            "sorter": true
                        }
                    ],
                    "actionColumn": {
                        "width": 60,
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
                            "field": "deptIdList",
                            "label": "部门名称",
                            "component": "SelectMultiDep",
                        },
                    ]
                }
            }
        }
    }

    Component {
        id: comRowAction
        Item{
            RowLayout{
                anchors.centerIn: parent
                spacing: 0

                FluIconButton {
                    iconSource: FluentIcons.Contact
                    iconSize: 15
                    onClicked: {
                        var rowObj = tablePane.tableView.getRow(row)
                        rowDataId = rowObj.id
                        userRoleListCallable.httpRequest()
                        deptRoleListCallable.httpRequest()
                        relatedLayout.visible = true
                    }
                }

                FluIconButton {
                    id: moreButton
                    iconSource: FluentIcons.More
                    iconSize: 15
                    onClicked: {
                        menu.popup()
                    }

                    FluMenu {
                        id: menu
                        width: 100
                        FluMenuItem {
                            text: qsTr("菜单权限")
                            onTriggered: {
                                var obj = tablePane.tableView.getRow(row)
                                queryTreeListCallable.httpRequest(obj.id)
                            }
                        }

                        FluMenuItem {
                            text: qsTr("字段数据权限")
                            onTriggered: {
                                var obj = tablePane.tableView.getRow(row)
                                FluRouter.navigate("/authHeadTableWindow", {
                                                       relatedRowData: {id: obj.id}
                                                   }, tablePane)
                            }
                        }

                        FluMenuItem {
                            text: qsTr("编辑")
                            onTriggered: {
                                var obj = tablePane.tableView.getRow(row)
                                tablePane.queryByIdListener(obj.id, qsTr("修改"))
                            }
                        }

                        FluMenuItem {
                            text: qsTr("删除")
                            onTriggered: {
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
                                        tablePane.deleteListener(row)
                                    }

                                    tablePane.tableView.removeRow(row)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: comUserRowAction
        Item{
            RowLayout{
                anchors.centerIn: parent
                spacing: 0

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
                            var rowObj = userTablePane.tableView.getRow(row)
                            userRoleDeleteCallable.httpRequest({roleId: rowDataId, userId: rowObj.id})
                            userTablePane.tableView.removeRow(row)
                        }
                    }
                }
            }
        }
    }

    FluNetworkCallable{
        id: userRoleListCallable
        property string postfixUrl: "/sys/user/userRoleList"
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

                var tableData = jsResult.result
                var dataSource = []
                tableData.records.forEach(function(record) {
                    record._key = FluTools.uuid()
                    record._minimumHeight = 50
                    record.action = userTablePane.tableView.customItem(comUserRowAction)
                    dataSource.push(record)
                })

                userTablePane.tableView.dataSource = dataSource
            }

        function httpRequest() {
            if (!rowDataId) {
                return
            }

            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)
            // .addQuery("pageNo", 1)
            // .addQuery("pageSize", 10)
            .addQuery("roleId", rowDataId)

            for(var key in userTablePane.queryParams) {
                var loaderItem = userTablePane.queryParams[key]
                if (loaderItem.value) {
                    networkParams.addQuery(key, loaderItem.value)
                }
            }

            networkParams.go(userRoleListCallable)
        }
    }

    FluNetworkCallable{
        id: userRoleDeleteCallable
        property string postfixUrl: "/sys/user/deleteUserRole"
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

                userRoleListCallable.httpRequest()
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.deleteJson(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            for(var key in params) {
                networkParams.addQuery(key, params[key])
            }

            networkParams.go(userRoleDeleteCallable)
        }
    }

    FluNetworkCallable{
        id: userRoleAddCallable
        property string postfixUrl: "/sys/user/addSysUserRole"
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

                userRoleListCallable.httpRequest()
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.postJson(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            params.roleId = rowDataId
            params.userIdList = params.userIdList.split(",")
            for(var key in params) {
                networkParams.add(key, params[key])
            }
            networkParams.go(userRoleAddCallable)
        }
    }

    Component {
        id: comDeptRowAction
        Item{
            RowLayout{
                anchors.centerIn: parent
                spacing: 0

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
                            var rowObj = deptTablePane.tableView.getRow(row)
                            deptRoleDeleteCallable.httpRequest({roleId: rowDataId, deptId: rowObj.id})
                            deptTablePane.tableView.removeRow(row)
                        }
                    }
                }
            }
        }
    }

    FluNetworkCallable{
        id: deptRoleListCallable
        property string postfixUrl: "/sys/sysDepart/departRoleList"
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

                var tableData = jsResult.result
                var dataSource = []
                tableData.records.forEach(function(record) {
                    record._key = FluTools.uuid()
                    record._minimumHeight = 50
                    record.action = deptTablePane.tableView.customItem(comDeptRowAction)
                    dataSource.push(record)
                })

                deptTablePane.tableView.dataSource = dataSource
            }

        function httpRequest() {
            if (!rowDataId) {
                return
            }

            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)
            // .addQuery("pageNo", 1)
            // .addQuery("pageSize", 10)
            .addQuery("roleId", rowDataId)

            for(var key in deptTablePane.queryParams) {
                var loaderItem = deptTablePane.queryParams[key]
                if (loaderItem.value) {
                    networkParams.addQuery(key, loaderItem.value)
                }
            }

            networkParams.go(deptRoleListCallable)
        }
    }

    FluNetworkCallable{
        id: deptRoleDeleteCallable
        property string postfixUrl: "/sys/user/deleteUserRole"
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

                deptRoleListCallable.httpRequest()
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.deleteJson(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            for(var key in params) {
                networkParams.addQuery(key, params[key])
            }

            networkParams.go(deptRoleDeleteCallable)
        }
    }

    FluNetworkCallable{
        id: deptRoleAddCallable
        property string postfixUrl: "/sys/user/addSysUserRole"
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

                deptRoleListCallable.httpRequest()
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.postJson(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            params.roleId = rowDataId
            params.deptIdList = params.deptIdList.split(",")
            for(var key in params) {
                networkParams.add(key, params[key])
            }
            networkParams.go(deptRoleAddCallable)
        }
    }

    FluNetworkCallable{
        id: queryTreeListCallable
        property string postfixUrl: "/sys/role/queryTreeList"
        property string roleId: ""
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

                queryRolePermissionCallable.httpRequest(roleId, jsResult.result.treeList)
            }

        function httpRequest(roleId) {
            queryTreeListCallable.roleId = roleId
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            networkParams.go(queryTreeListCallable)
        }
    }

    FluNetworkCallable{
        id: queryRolePermissionCallable
        property string postfixUrl: "/sys/permission/queryRolePermission"
        property string roleId: ""
        property var treeList: []
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

                FluRouter.navigate("/authMenuWindow", {
                                       roleId: roleId,
                                       rolePermissions: jsResult.result,
                                       treeList: treeList || [],
                                   }, tablePane)
            }

        function httpRequest(roleId, treeList) {
            queryRolePermissionCallable.roleId = roleId
            queryRolePermissionCallable.treeList = treeList
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)
            .addQuery("roleId", roleId)

            networkParams.go(queryRolePermissionCallable)
        }
    }
}
