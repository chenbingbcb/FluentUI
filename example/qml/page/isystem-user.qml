import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id: root
    readonly property int enumStatusUnfrozen: 1
    readonly property int enumStatusFrozen: 2

    property var infoAssignFormData: ({})
    property var infoAssignFormConfig: ({
        schemas: [
            {
                field: 'selectedRole',
                label: '角色分配',
                component: 'SearchSelect',
                componentProps: {
                    listUrl: '/sys/role/list',
                    valField: 'id',
                    txtField: 'roleName',
                    multiple: false,
                    async: false,
                },
            },
            {
                field: 'checkedDepartNameString',
                label: '部门分配',
                component: 'SelectMultiDep',
            },
            {
                field: 'departIds',
                label: '负责部门',
                component: 'SelectMultiDep',
            },
        ]
    })

    FluNetworkCallable{
        id: queryUserRoleCallable
        property string postfixUrl: "/sys/user/queryUserRole"
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

                if (jsResult.result) {
                    infoAssignFormData.selectedRole = jsResult.result.map(function(item) {
                        return item.roleId
                     }).join(",")
                } else {
                    infoAssignFormData.selectedRole = ""
                }

                queryUserDepartsCallable.httpRequest({userId: infoAssignFormData.id})
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            for(var key in params) {
                networkParams.addQuery(key, params[key])
            }

            networkParams.go(queryUserRoleCallable)
        }
    }

    FluNetworkCallable{
        id: queryUserDepartsCallable
        property string postfixUrl: "/sys/user/queryUserDeparts"
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

                if (jsResult.result) {
                    infoAssignFormData.checkedDepartNameString = jsResult.result.map(function(item) {
                        return item.value
                     }).join(",")
                } else {
                    infoAssignFormData.checkedDepartNameString = ""
                }

                listCallable.httpRequest({id: infoAssignFormData.id})
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            for(var key in params) {
                networkParams.addQuery(key, params[key])
            }

            networkParams.go(queryUserDepartsCallable)
        }
    }

    FluNetworkCallable{
        id: listCallable
        property string postfixUrl: "/sys/user/list"
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

                infoAssignFormData.departIds = jsResult.result ? jsResult.result.records[0].departIds : ""
                FluRouter.navigate("/onlineFormWindow", {
                                       formPaneData: {
                                           formConfig: infoAssignFormConfig
                                           , title: qsTr("角色\\部门分配")
                                           , parent: tablePane
                                           , formData: infoAssignFormData
                                           , formDataSaveListener: infoAssignFormDataSave
                                       }
                                   }, tablePane)
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            for(var key in params) {
                networkParams.addQuery(key, params[key])
            }

            networkParams.go(listCallable)
        }
    }

    function infoAssignFormDataSave() {
        var formPane = tablePane._to.formPane
        var newData = {id: infoAssignFormData.id}
        var loaderItem
        for (var j = 0; j < formPane.formRepeater.count; j++) {
            loaderItem = formPane.formRepeater.itemAt(j).loaderItem
            if (loaderItem.config.required === true && !loaderItem.value) {
                tablePane._to.showError(loaderItem.config.label + qsTr("不能为空"))
                return
            }

            newData[loaderItem.config.field] = loaderItem.value
        }

        newData.selectedRole = newData.selectedRole ? newData.selectedRole.split(",") : []
        changePropsCallable.httpRequest(newData)
    }

    FluNetworkCallable{
        id: changePropsCallable
        property string postfixUrl: "/sys/user/changeProps"
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
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.putJson(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            for(var key in params) {
                networkParams.add(key, params[key])
            }

            networkParams.go(changePropsCallable)
        }
    }

    property var passwordFormData: ({})
    property var passwordFormConfig: ({
        schemas: [
            {
                field: 'username',
                label: '用户账号',
                component: 'Input',
            },
            {
                field: 'password',
                label: '登录密码',
                required: true,
                component: 'Password',
                "componentProps": {
                    "placeholderText": "请输入登录密码"
                },
            },
            {
                field: 'confirmpassword',
                label: '确认密码',
                component: 'Password',
                "componentProps": {
                    "placeholderText": "请重新输入登录密码"
                },
            },
        ]
    })

    function passwordFormDataSave() {
        var formPane = tablePane._to.formPane
        var newData = {}
        var loaderItem
        for (var j = 0; j < formPane.formRepeater.count; j++) {
            loaderItem = formPane.formRepeater.itemAt(j).loaderItem
            if (loaderItem.config.required === true && !loaderItem.value) {
                tablePane._to.showError(loaderItem.config.label + qsTr("不能为空"))
                return
            }

            newData[loaderItem.config.field] = loaderItem.value
        }

        var pattern = /^[a-zA-Z0-9`~!@#$%^&*()-_=+[{\]}\|;:'",<.>/?]{6,}$/
        if (!pattern.test(newData.password)) {
            tablePane._to.showError(qsTr("密码需要至少6位数字、大小写字母或特殊符号组成！"))
            return
        }

        if (newData.password !== newData.confirmpassword) {
            tablePane._to.showError(qsTr("两次输入的密码不一样！"))
            return
        }

        changePasswordCallable.httpRequest(newData)
    }

    FluNetworkCallable{
        id: changePasswordCallable
        property string postfixUrl: "/sys/user/changePassword"
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
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.putJson(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            for(var key in params) {
                networkParams.add(key, params[key])
            }

            networkParams.go(changePasswordCallable)
        }
    }

    FluNetworkCallable{
        id: frozenBatchCallable
        property string postfixUrl: "/sys/user/frozenBatch"
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

                tablePane.listListener()
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.putJson(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            for(var key in params) {
                networkParams.add(key, params[key])
            }

            networkParams.go(frozenBatchCallable)
        }
    }

    property var busiRuleFormData: ({})
    property var busiRuleFormConfig: ({
        schemas: [
            {
                "field": "busiRule",
                "label": "",
                "component": "childTable",
                "colProps": {
                    "span": 8
                },
                "componentProps": {
                    "relatedField": "id:userId",
                },
                "listUrl": "/sys/sysBusiRule/list",
                "deleteUrl": "/sys/sysBusiRule/delete",
                "addUrl": "/sys/sysBusiRule/add",
                "editUrl": "/sys/sysBusiRule/edit",
                "tableConfig": {
                    "tableModel": "editSingleModel",
                    "formConfig": {
                        "labelWidth": 120,
                        "schemas": [
                            {
                                "field": "userId",
                                "label": "用户ID",
                                "component": "SInput",
                                "componentProps": {
                                    "type": "LIKE"
                                },
                                "colProps": {
                                    "span": 8
                                }
                            },
                            {
                                "field": "busiKey",
                                "label": "业务key",
                                "component": "DictSelectTag",
                                "componentProps": {
                                    "dictCode": "sys_busi_rule"
                                },
                                "colProps": {
                                    "span": 8
                                }
                            },
                            {
                                "field": "busiValue",
                                "label": "业务值",
                                "component": "SInput",
                                "componentProps": {
                                    "type": "LIKE"
                                },
                                "colProps": {
                                    "span": 8
                                }
                            }
                        ]
                    },
                    "columns": [
                        {
                            "title": "用户ID",
                            "dataIndex": "userId",
                            "width": 200,
                            "editComponent": "Input",
                            "editRow": true,
                            "editRule": true,
                        },
                        {
                            "title": "业务key",
                            "dataIndex": "busiKey_dictText",
                            "width": 200,
                            "editComponent": "DictSelectTag",
                            "editComponentProps": {
                                "dictCode": "sys_busi_rule"
                            },
                            "editRow": true,
                            "editRule": true,
                        },
                        {
                            "title": "业务值",
                            "dataIndex": "busiValue",
                            "width": 200,
                            "editComponent": "Input",
                            "editRow": true,
                            "editRule": true,
                        }
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
            },
        ]
    })

    FluTablePane {
        id: tablePane
        listUrl: "/sys/user/list"
        deleteUrl: "/sys/user/delete"
        addUrl: "/sys/user/add"
        editUrl: "/sys/user/edit"
        queryByIdUrl: "/sys/user/queryById"
        rowActionDelegate: comRowAction
        tableTitle: "用户管理"
        tableConfig: {
            "tableModel": "modalSingleModel",
            "formConfig": {
                "labelWidth": 120,
                "schemas": [
                    {
                        "field": "username",
                        "label": "账号",
                        "component": "SInput",
                        "componentProps": {
                            "type": "LIKE"
                        },
                        "colProps": {
                            "span": 8
                        }
                    },
                    {
                        "field": "realname",
                        "label": "真实名字",
                        "component": "SInput",
                        "componentProps": {
                            "type": "LIKE"
                        },
                        "colProps": {
                            "span": 8
                        }
                    },
                    {
                        "field": "status",
                        "label": "用户状态",
                        "component": "DictSelectTag",
                        "componentProps": {
                            "dictCode": "status"
                        },
                        "colProps": {
                            "span": 8
                        }
                    },
                    {
                        "field": "sex",
                        "label": "性别",
                        "component": "DictSelectTag",
                        "componentProps": {
                            "dictCode": "sex"
                        },
                        "colProps": {
                            "span": 8
                        }
                    },
                    {
                        "field": "phone",
                        "label": "手机号码",
                        "component": "SInput",
                        "componentProps": {
                            "type": "LIKE"
                        },
                        "colProps": {
                            "span": 8
                        }
                    }
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
                    "title": "头像",
                    "dataIndex": "avatar",
                    "width": 200
                },
                {
                    "title": "性别",
                    "dataIndex": "sex_dictText",
                    "width": 200,
                    "sorter": true
                },
                {
                    "title": "生日",
                    "dataIndex": "birthday",
                    "width": 200,
                    "sorter": true
                },
                {
                    "title": "手机号码",
                    "dataIndex": "phone",
                    "width": 200
                },
                {
                    "title": "部门",
                    "dataIndex": "orgCodeTxt",
                    "width": 200,
                    "sorter": true
                },
                {
                    "title": "负责部门",
                    "dataIndex": "departIds_dictText",
                    "width": 200,
                    "sorter": true
                },
                {
                    "title": "状态",
                    "dataIndex": "status_dictText",
                    "width": 200,
                    "sorter": true
                }
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
                    "field": "username",
                    "label": "登录账号",
                    "component": "Input",
                    "colProps": {
                        "span": 8
                    },
                    "required": true,
                    "componentProps": {}
                },
                {
                    "field": "realname",
                    "label": "真实姓名",
                    "component": "Input",
                    "colProps": {
                        "span": 8
                    },
                    "required": true,
                    "componentProps": {}
                },
                {
                    field: 'workNo',
                    label: '工号',
                    component: 'Input',
                    required: true
                },
                {
                    field: 'post',
                    label: '职务',
                    component: 'SelectPost',
                },
                {
                    field: 'userIdentity',
                    label: '身份',
                    component: 'RadioGroup',
                    componentProps: {
                      options: [
                        {
                          label: '普通用户',
                          value: 1,
                        },
                        {
                          label: '上级用户',
                          value: 2,
                        },
                      ],
                    },
                },
                {
                    field: 'birthday',
                    label: '生日',
                    component: 'DatePicker',
                    componentProps: {
                      valueFormat: 'YYYY-MM-DD',
                    },
                },
                {
                    "field": "sex",
                    "label": "性别",
                    "component": "DictSelectTag",
                    "componentProps": {
                        "dictCode": "sex"
                    }
                },
                {
                    field: 'email',
                    label: '邮箱',
                    component: 'Input',
                },
                {
                    field: 'zzdm',
                    label: '所属组织',
                    component: 'Input',
                },
                {
                    field: 'divisionDept',
                    label: '所属事业部--备用',
                    component: 'Input',
                },
                {
                    field: 'phone',
                    label: '手机号码',
                    component: 'Input',
                },
                {
                    field: 'telephone',
                    label: '座机',
                    component: 'Input',
                },
                {
                    field: 'yyzx',
                    label: '营运中心',
                    component: 'SearchSelect',
                    componentProps: {
                        listUrl: '/system/xtmYyzx/list',
                        valField: 'yyzxdm',
                        txtField: 'yyzxmc',
                        multiple: false,
                        async: false,
                    },
                },
            ]
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
                        var obj = tablePane.tableView.getRow(row)
                        tablePane.queryByIdListener(obj.id, qsTr("修改"))
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
                                tablePane.deleteListener(row)
                            }

                            tablePane.tableView.removeRow(row)
                        }
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
                        width: 80
                        FluMenuItem {
                            text: qsTr("信息分配")
                            onTriggered: {
                                infoAssignFormData = {}
                                var rowObj = tablePane.tableView.getRow(row)
                                infoAssignFormData.id = rowObj.id
                                queryUserRoleCallable.httpRequest({userId: infoAssignFormData.id})
                            }
                        }

                        FluMenuItem {
                            text: qsTr("密码")
                            onTriggered: {
                                passwordFormData = {}
                                var rowObj = tablePane.tableView.getRow(row)
                                passwordFormData.username = rowObj.id
                                FluRouter.navigate("/onlineFormWindow", {
                                                       formPaneData: {
                                                           formConfig: passwordFormConfig
                                                           , title: qsTr("重新设定密码")
                                                           , parent: tablePane
                                                           , formData: passwordFormData
                                                           , formDataSaveListener: passwordFormDataSave
                                                       }
                                                   }, tablePane)
                            }
                        }

                        FluMenuItem {
                            text: qsTr("冻结")
                            onTriggered: {
                                var rowObj = tablePane.tableView.getRow(row)
                                if (rowObj.status === enumStatusUnfrozen) {
                                    frozenDialog.open()
                                } else {
                                    frozenBatchCallable.httpRequest({ids: rowObj.id, status: enumStatusUnfrozen})
                                }
                            }
                            Component.onCompleted: {
                                var rowObj = tablePane.tableView.getRow(row)
                                if (rowObj.status === enumStatusFrozen) {
                                    text = qsTr("解冻")
                                }
                            }

                            FluContentDialog{
                                id: frozenDialog
                                title: qsTr("冻结")
                                message: qsTr("是否确认冻结?")
                                buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
                                negativeText: qsTr("取消")
                                positiveText: qsTr("确认")
                                onPositiveClicked:{
                                    var rowObj = tablePane.tableView.getRow(row)
                                    frozenBatchCallable.httpRequest({ids: rowObj.id, status: enumStatusFrozen})
                                }
                            }
                        }

                        FluMenuItem {
                            text: qsTr("业务权限")
                            onTriggered: {
                                busiRuleFormData = {}
                                var rowObj = tablePane.tableView.getRow(row)
                                busiRuleFormData.id = rowObj.id
                                FluRouter.navigate("/onlineFormWindow", {
                                                       formPaneData: {
                                                           formConfig: busiRuleFormConfig
                                                           , title: qsTr("详情")
                                                           , parent: tablePane
                                                           , formData: busiRuleFormData
                                                       }
                                                   }, tablePane)
                            }
                        }
                    }
                }
            }
        }
    }
}
