import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id:root

    FluNetworkCallable{
        id: queryallCallable
        property string postfixUrl: "/sys/role/queryall"
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

                contentDialog.open()
            }

        function queryallRequest(updateObj) {
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            for(var key in updateObj) {
                networkParams.addQuery(key, updateObj[key])
            }

            networkParams.go(queryallCallable)
        }
    }

    FluContentDialog {
        id: contentDialog
        title: qsTr("角色\部门分配")
        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
        negativeText: qsTr("关闭")
        positiveText: qsTr("确认")
        onPositiveClicked:{
        }
    }

    FluTablePane {
        id: tablePane
        getTableDataUrl: "/sys/user/list"
        getDataByParamsUrl: "/sys/user/queryById"
        delDataByParamsUrl: "/sys/user/delete"
        addFormDataUrl: "/sys/user/add"
        updateFormDataUrl: "/sys/user/edit"
        rowActionDelegate: comRowAction
        tableConfig: {
            "tableModel": "modalSingleModel",
            "primaryKey": [
                "id"
            ],
            "useSearchForm": true,
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
            "ellipsis": true,
            "orderConfig": "{}",
            "showIndexColumn": true,
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
            "showTableSetting": true,
            "bordered": true,
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
            "customButtons": {},
            "rowKey": "id",
            "rowSelection": {
                "type": "checkbox"
            },
            "showSelectionBar": true
        }
        formConfig: {
            "primaryKey": [
                "id"
            ],
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
            "customButtons": {},
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

    Component{
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
                        tablePane.openFormWindow(row, qsTr("修改"))
                    }
                }

                FluIconButton {
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
                            var rowObj = tablePane.tableView.getRow(row)
                            if (rowObj.id) {
                                tablePane.delDataByParamsRequest(row)
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
                                queryallCallable.queryallRequest()
                            }
                        }
                        // FluMenuSeparator { }
                        FluMenuItem {
                            text: qsTr("密码")
                            onTriggered: {
                                showError(qsTr("Search"))
                            }
                        }
                        // FluMenuSeparator { }
                        FluMenuItem {
                            text: qsTr("冻结")
                            onTriggered: {
                                showError(qsTr("Search"))
                            }
                        }
                        // FluMenuSeparator { }
                        FluMenuItem {
                            text: qsTr("业务权限")
                            onTriggered: {
                                showError(qsTr("Search"))
                            }
                        }
                    }

                }
            }
        }
    }
}
