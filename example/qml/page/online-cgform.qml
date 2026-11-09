import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id: root
    property var dataOptions: []
    Component.onCompleted: {
        getAllDataSourceCodeCallable.httpRequest()
    }

    FluNetworkCallable{
        id: getAllDataSourceCodeCallable
        property string postfixUrl: "/sys/dataSource/getAllDataSourceCode"
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

                dataOptions = jsResult.result.map(function(item) {
                    return { label: item, value: item }
                })
            }

        function httpRequest() {
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            networkParams.go(getAllDataSourceCodeCallable)
        }
    }

    FluNetworkCallable{
        id: getTablesCallable
        property string postfixUrl: "/sys/dataSource/getTables"
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

                var dataTableOptions = jsResult.result.map(function(item) {
                    return { text: item, value: item }
                })
                var formPane = tablePane._to.formPane
                for (var i = 0; i < formPane.formRepeater.count; i++) {
                    var loaderItem = formPane.formRepeater.itemAt(i).loaderItem
                    if (loaderItem.config.field === "dataTable") {
                        var dictSelectTag = loaderItem.item
                        dictSelectTag.model = Qt.createQmlObject(
                            'import QtQuick 2.15; ListModel { ListElement { text: ""; title: ""; value: "" } }',
                            dictSelectTag
                        )
                        dictSelectTag.model.append(dataTableOptions)
                        break
                    }
                }
            }

        function httpRequest() {
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            var dbCode = ""
            var formPane = tablePane._to.formPane
            for (var i = 0; i < formPane.formRepeater.count; i++) {
                var loaderItem = formPane.formRepeater.itemAt(i).loaderItem
                if (loaderItem.config.field === "dataSource") {
                    dbCode = loaderItem.value
                    break
                }
            }

            if (!dbCode) {
                showWarning(qsTr("请先选择数据源"))
                return
            }

            networkParams.addQuery("dbCode", dbCode)
            networkParams.go(getTablesCallable)
        }
    }

    FluTablePane {
        id: tablePane
        listUrl: "/online/genTableHead/list"
        deleteUrl: "/online/genTableHead/delete"
        addUrl: "/online/genTableHead/add"
        editUrl: "/online/genTableHead/edit"
        queryByIdUrl: "/online/genTableHead/queryById"
        rowActionDelegate: comRowAction
        tableTitle: "Online表单开发"
        tableConfig: {
            "tableModel": "modalSingleModel",
            "formConfig": {
                "labelWidth": 120,
                "schemas": [
                    {
                        field: 'id',
                        label: 'id',
                        component: 'SInput',
                        colProps: { span: 8 },
                    },
                    {
                        field: 'name',
                        label: '列表名称',
                        component: 'SInput',
                        colProps: { span: 8 },
                    },
                    {
                        field: 'code',
                        label: '列表编码',
                        component: 'SInput',
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
                    title: '列表名称',
                    align: 'center',
                    dataIndex: 'name',
                    width: 200,
                    resizable: true,
                },
                {
                    title: '列表编码',
                    align: 'center',
                    dataIndex: 'code',
                },
            ],
            "actionColumn": {
                "width": 120,
                "title": "操作1",
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
                    field: 'name',
                    label: '列表名称',
                    component: 'Input',
                    rules: [
                    {
                        required: true,
                        message: '请输入列表名称',
                    },
                    ],
                },
                {
                    field: 'code',
                    label: '列表编码',
                    component: 'Input',
                    rules: [
                    {
                        required: true,
                        message: '请输入列表编码',
                    },
                    ],
                },
                {
                    field: 'showNo',
                    label: '是否显示序号',
                    component: 'DictSelectTag',
                    componentProps: {
                    dictCode: 'yn',
                    },
                    defaultValue: 1,
                    rules: [
                    {
                        required: true,
                        message: '请选择是否显示序号',
                    },
                    ],
                },
                {
                    field: 'openLog',
                    label: '是否开启日志',
                    component: 'DictSelectTag',
                    componentProps: {
                    dictCode: 'yn',
                    },
                    defaultValue: 0,
                    rules: [
                    {
                        required: true,
                        message: '请选择是否开启日志',
                    },
                    ],
                },
                {
                    field: 'orderConfig',
                    label: '默认排序配置(json)',
                    component: 'Textarea',
                },
                {
                    field: 'advancedQuery',
                    label: '开启高级查询',
                    component: 'DictSelectTag',
                    componentProps: {
                    dictCode: 'yn',
                    },
                    defaultValue: 0,
                    rules: [
                    {
                        required: true,
                        message: '请选择是否开启高级查询',
                    },
                    ],
                },
                {
                    field: 'ellipsis',
                    label: '溢出省略号',
                    component: 'DictSelectTag',
                    componentProps: {
                    dictCode: 'yn',
                    },
                    defaultValue: 1,
                    rules: [
                    {
                        required: true,
                        message: '请选择是否溢出省略号',
                    },
                    ],
                },
                {
                    field: 'pageSetting',
                    label: '分页设置',
                    component: 'Input',
                },
                {
                    field: 'tableEvent',
                    label: '表格事件',
                    component: 'Textarea',
                },
                {
                    field: 'rowEvent',
                    label: '表格行事件',
                    component: 'Textarea',
                },
                {
                    field: 'cellEvent',
                    label: '单元格事件',
                    component: 'Textarea',
                },
                {
                    field: 'exendAttr',
                    label: '扩展属性',
                    component: 'Textarea',
                },
                {
                    field: 'deviceType',
                    label: '设备类型',
                    component: 'DictSelectTag',
                    componentProps: {
                    dictCode: 'device_type',
                    },
                    defaultValue: 'PC',
                    rules: [
                    {
                        required: true,
                        message: '请选择设备类型',
                    },
                    ],
                },
                {
                    field: 'dataSource',
                    label: '数据源',
                    component: 'DictSelectTag',
                    componentProps: {
                        options: dataOptions
                    },
                    rules: [
                    {
                        required: true,
                        message: '请输入数据源',
                    },
                    ],
                },
                {
                    field: 'dataTable',
                    label: '数据表',
                    component: 'DictSelectTag',
                    componentProps: {
                        options: [],
                        updateModelListener: getTablesCallable.httpRequest
                    },
                    rules: [
                    {
                        required: true,
                        message: '请输入数据表',
                    },
                    ],
                },
                {
                    field: 'tableModel',
                    label: 'table模式',
                    component: 'DictSelectTag',
                    componentProps: {
                    dictCode: 'table_model',
                    defaultValue: 'modalSingleModel',
                    },
                },
                {
                    field: 'formId',
                    label: '关联表单配置',
                    component: 'SelectRelatedFormCfg',
                },
                {
                    field: 'tableKey',
                    label: '表主键字段',
                    component: 'Input',
                    componentProps: {
                    placeholder: '多个组件用逗号隔开,对应实体对象字段',
                    defaultValue: 'id',
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
                        tablePane.queryByIdCallback(obj, qsTr("修改"))
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
                            text: qsTr("生成代码")
                            onTriggered: {
                                genCodeFormData = {}
                                var rowObj = tablePane.tableView.getRow(row)
                                genCodeFormData.tableName = rowObj.code
                                genCodeFormData.className = genCodeFormData.tableName.split("_").map(function(word) {
                                    return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
                                }).join("")
                                FluRouter.navigate("/onlineFormWindow", {
                                                    formConfig: genCodeFormConfig
                                                    , title: qsTr("代码生成 【" + genCodeFormData.tableName + "】")
                                                    , formData: genCodeFormData
                                                    , formDataSaveListener: genCodeFormDataSave
                                                }, tablePane)
                            }
                        }

                        FluMenuItem {
                            text: qsTr("自定义按钮")
                            onTriggered: {
                                customButtonFormData = {}
                                var rowObj = tablePane.tableView.getRow(row)
                                customButtonFormData.id = rowObj.id
                                FluRouter.navigate("/onlineFormWindow", {
                                                       formConfig: customButtonFormConfig
                                                       , title: qsTr("自定义按钮")
                                                       , formData: customButtonFormData
                                                       , saveFormBtnInvisile: true
                                                   }, tablePane)
                            }
                        }
                    }
                }
            }
        }
    }

    property var genCodeFormData: ({})
    property var genCodeFormConfig: ({
        schemas: [
            {
                field: 'tableName',
                label: '表名',
                component: 'Input',
                rules: [
                {
                    required: true,
                    message: '请输入数据源名称',
                },
                ],
            },
            {
                field: 'className',
                label: '实体类名',
                component: 'Input',
                rules: [
                {
                    required: true,
                    message: '请输入数据源名称',
                },
                ],
            },
            {
                field: 'packageName',
                label: '包名(小写)',
                component: 'Input',
                rules: [
                {
                    required: true,
                    message: '请输入数据源名称',
                },
                ],
            },
        ]
    })

    function genCodeFormDataSave() {
        tablePane._to.showError(qsTr("暂不支持代码生成"))
        return
    }

    property var customButtonFormData: ({})
    property var customButtonFormConfig: ({
        schemas: [
            {
                "field": "customButton",
                "label": "",
                "component": "childTable",
                "colProps": {
                    "span": 8
                },
                "componentProps": {
                    "relatedField": "id:mainId",
                },
                "listUrl": "/online/genButton/list",
                "deleteUrl": "/online/genButton/delete",
                "addUrl": "/online/genButton/add",
                "editUrl": "/online/genButton/updateMainSub",
                "queryByIdUrl": "/online/genButton/queryById",
                "updateAll": "/online/genButton/updateAll",
                "tableConfig": {
                    // "tableModel": "editSingleModel",
                    "formConfig": {
                        "labelWidth": 120,
                        "schemas": [
                            {
                                field: 'code',
                                label: '按钮编码',
                                component: 'Input',
                                colProps: { span: 8 },
                            },
                            {
                                field: 'name',
                                label: '按钮名称',
                                component: 'Input',
                                colProps: { span: 8 },
                            },
                        ]
                    },
                    "columns": [
                        {
                            title: '按钮编码',
                            align: 'center',
                            dataIndex: 'code',
                            width: 200,
                            resizable: true,
                        },
                        {
                            title: '按钮名称',
                            align: 'center',
                            dataIndex: 'name',
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
                formConfig: {
                    "schemas": [
                        {
                            field: 'code',
                            label: '按钮编号',
                            component: 'Input',
                            rules: [
                            {
                                required: true,
                                message: '请输入按钮编号',
                            },
                            ],
                        },
                        {
                            field: 'name',
                            label: '按钮名称',
                            component: 'Input',
                            rules: [
                            {
                                required: true,
                                message: '请输入按钮名称',
                            },
                            ],
                        },
                        {
                            field: 'position',
                            label: '按钮位置',
                            component: 'DictSelectTag',
                            componentProps: {
                            options: [
                                {
                                label: '列表头',
                                value: 'head',
                                key: '1',
                                },
                                {
                                label: '单身按钮',
                                value: 'action',
                                key: '2',
                                },
                            ],
                            },
                        },
                        {
                            field: 'type',
                            label: '按钮类型',
                            component: 'DictSelectTag',
                            componentProps: {
                            options: [
                                {
                                label: 'js',
                                value: 'js',
                                key: '1',
                                },
                                {
                                label: 'action',
                                value: 'action',
                                key: '2',
                                },
                            ],
                            },
                        },
                        {
                            field: 'execution',
                            label: '规则',
                            component: 'Input',
                        },
                        // {
                        //   field: '????',
                        //   label: '按钮状态',
                        //   component: 'Switch',
                        // },
                        {
                            field: 'icon',
                            label: '按钮图标',
                            component: 'Input',
                        },
                        {
                            field: 'modal',
                            label: '弹窗模式',
                            component: 'Input',
                        },
                        {
                            field: 'orderNum',
                            label: '排序',
                            component: 'Input',
                        },
                        {
                            field: 'openLog',
                            label: '开启log',
                            component: 'DictSelectTag',
                            componentProps: {
                            dictCode: 'yn',
                            },
                        },
                    ]
                }
            },
        ]
    })
}