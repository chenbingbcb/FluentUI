import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id: root
    property var deleteChildTablePane
    FluTablePane {
        id: tablePane
        listUrl: '/sys/dict/list'
        deleteUrl: '/sys/dict/delete'
        addUrl: '/sys/dict/add'
        editUrl: '/sys/dict/edit'
        queryByIdUrl: '/sys/dict/queryById'
        rowActionDelegate: comRowAction
        tableActionDelegate: comTableCustomAction
        tableTitle: "数据字典"
        tableConfig: {
            "tableModel": "modalSingleModel",
            "formConfig": {
                "labelWidth": 120,
                "schemas": [
                    {
                        field: 'dictName',
                        label: '字典名称',
                        component: 'Input',
                        colProps: { span: 8 },
                    },
                    {
                        field: 'dictCode',
                        label: '字典编码',
                        component: 'Input',
                        colProps: { span: 8 },
                    },
                ]
            },
            "columns": [
                {
                    title: '字典名称',
                    align: 'center',
                    dataIndex: 'dictName',
                    width: 200,
                    resizable: true,
                },
                {
                    title: '字典编码',
                    align: 'center',
                    dataIndex: 'dictCode',
                },
                {
                    title: '描述',
                    align: 'center',
                    dataIndex: 'description',
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
                    field: 'dictName',
                    label: '字典名称',
                    component: 'Input',
                    rules: [
                    {
                        required: true,
                        message: '请输入字典名称',
                    },
                    ],
                },
                {
                    field: 'dictCode',
                    label: '字典编码',
                    component: 'Input',
                    rules: [
                    {
                        required: true,
                        message: '请输入字典编码',
                    },
                    ],
                },
                {
                    field: 'description',
                    label: '描述',
                    component: 'Input',
                },
            ]
        }
    }

    property var dictItemFormData: ({})
    property var dictItemFormConfig: ({
        "schemas": [
            {
                field: 'dictTable',
                label: '字典列表',
                component: 'childTable',
                componentProps: {
                    relatedField: "id:dictId",
                },
                listUrl: "/sys/dictItem/list",
                deleteUrl: '/sys/dictItem/delete',
                addUrl: '/sys/dictItem/add',
                editUrl: '/sys/dictItem/edit',
                queryByIdUrl: '/sys/dictItem/queryById',
                updateAllUrl: '/sys/dictItem/updateAll',
                tableConfig: {
                    tableModel: "editAllModel",
                    "formConfig": {
                        "labelWidth": 120,
                        "schemas": [
                            {
                                field: 'itemText',
                                label: '名称',
                                component: 'Input',
                                colProps: { span: 8 },
                            },
                            {
                                field: 'status',
                                label: '状态',
                                component: 'DictSelectTag',
                                componentProps: {
                                    dictCode: 'dict_item_status',
                                },
                                colProps: { span: 8 },
                            },
                        ]
                    },
                    "columns": [
                        {
                            title: '名称',
                            align: 'center',
                            dataIndex: 'itemText',
                            width: 200,
                            resizable: true,
                            editRow: true,
                        },
                        {
                            title: '数据值',
                            align: 'center',
                            dataIndex: 'itemValue',
                            editRow: true,
                        },
                        {
                            title: '排序值',
                            align: 'center',
                            dataIndex: 'sortOrder',
                            editRow: true,
                        },
                        {
                            title: '状态',
                            align: 'center',
                            dataIndex: 'status',
                            editComponent: 'Switch',
                            format(text) {
                            return text == '1' ? '启用' : '禁用';
                            },
                            editComponentProps: {
                            checkedValue: 1,
                            unCheckedValue: 0,
                            },
                            editRow: true,
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
            },
        ]
    })
    
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
                        tablePane.queryByIdCallback(obj, qsTr("修改"))
                    }
                }

                FluIconButton {
                    id: dictButton
                    iconSource: FluentIcons.Settings
                    iconSize: 15
                    onClicked: {
                        dictItemFormData = {}
                        var rowObj = tablePane.tableView.getRow(row)
                        dictItemFormData.id = rowObj.id
                        FluRouter.navigate("/onlineFormWindow", {
                            title: qsTr("字典列表")
                            , saveFormBtnInvisile: true
                            , formConfig: dictItemFormConfig
                            , formData: dictItemFormData
                        }, tablePane)
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
        id: comDeleteRowAction
        Item{
            RowLayout{
                anchors.centerIn: parent
                spacing: 0

                Connections{
                    target: tablePane._to
                    function onClosing(event){
                        tablePane.listCallback()
                    }
                }

                FluIconButton {
                    id: backButton
                    iconSource: FluentIcons.Refresh
                    iconSize: 15
                    onClicked: {
                        var rowObj = deleteChildTablePane.tableView.getRow(row)
                        backCallable.httpRequest(rowObj.id)
                    }
                }

                FluIconButton {
                    iconSource: FluentIcons.Delete
                    iconSize: 15
                    onClicked: {
                        deleteDialog2.open()
                    }

                    FluContentDialog {
                        id: deleteDialog2
                        title: qsTr("删除")
                        message: qsTr("是否确认删除?")
                        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
                        negativeText: qsTr("取消")
                        positiveText: qsTr("确认")
                        onPositiveClicked:{
                            var rowObj = deleteChildTablePane.tableView.getRow(row)
                            deletePhysicCallable.httpRequest(rowObj.id)
                        }
                    }
                }
            }
        }
    }

    property var deleteFormConfig: ({
        "schemas": [
            {
                field: 'delete',
                label: '回收站',
                component: 'childTable',
                componentProps: {
                },
                listUrl: "/sys/dict/deleteList",
                tableActionDelegate: null,
                rowActionDelegate: comDeleteRowAction,
                formConfig: {},
                tableConfig: {
                    "columns": [
                        {
                            title: '字典名称',
                            align: 'center',
                            dataIndex: 'dictName',
                            width: 200,
                            resizable: true,
                        },
                        {
                            title: '字典编码',
                            align: 'center',
                            dataIndex: 'dictCode',
                        },
                        {
                            title: '描述',
                            align: 'center',
                            dataIndex: 'description',
                        },
                    ],
                    "actionColumn": {
                        "width": 120,
                        "title": "操作",
                        "dataIndex": "action"
                    },
                },
            },
        ]
    })
    
    Component {
        id: comTableCustomAction
        RowLayout {
            Layout.fillWidth: true

            FluFilledButton {
                text: qsTr("回收站")
                onClicked: {
                    FluRouter.navigate("/onlineFormWindow", {
                        title: qsTr("字典回收")
                        , saveFormBtnInvisile: true
                        , formConfig: deleteFormConfig
                    }, tablePane)

                    var formPane = tablePane._to.formPane
                    deleteChildTablePane = formPane.tablePanes[0]
                }
            }

            FluFilledButton {
                text: qsTr("刷新缓存")
                onClicked: {
                    refleshCacheCallable.httpRequest()
                }
            }
        }
    }

    FluNetworkCallable{
        id: refleshCacheCallable
        property string postfixUrl: "/sys/dict/refleshCache"
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

                showInfo(jsResult.message)
            }

        function httpRequest() {
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            networkParams.go(refleshCacheCallable)
        }
    }

    FluNetworkCallable{
        id: backCallable
        property string postfixUrl: "/sys/dict/back/"
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

                deleteChildTablePane.listCallback()
            }

        function httpRequest(id) {
            var networkParams = FluNetwork.putJson(GlobalModel.basicUrl + postfixUrl + id)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            networkParams.go(backCallable)
        }
    }

    FluNetworkCallable{
        id: deletePhysicCallable
        property string postfixUrl: "/sys/dict/deletePhysic/"
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

                deleteChildTablePane.listCallback()
            }

        function httpRequest(id) {
            var networkParams = FluNetwork.deleteJson(GlobalModel.basicUrl + postfixUrl + id)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            networkParams.go(deletePhysicCallable)
        }
    }
}
