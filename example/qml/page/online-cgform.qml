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

    FluTablePane {
        id: tablePane
        listUrl: "/online/genTableHead/list"
        deleteUrl: "/online/genTableHead/delete"
        addUrl: "/online/genTableHead/add"
        editUrl: "/online/genTableHead/edit"
        queryByIdUrl: "/online/genTableHead/queryById"
        rowActionDelegate: comRowAction
        formActionDelegate: comFormCustomAction
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
                {
                    field: 'columnData',
                    label: '列表字段',
                    component: 'childTable',
                    componentProps: {
                        relatedField: "id:mainId",
                    },
                    listUrl: '/online/genTableColumn/list',
                    deleteUrl: '/online/genTableColumn/delete',
                    deleteBatchUrl: '/online/genTableColumn/deleteBatch',
                    addUrl: '/online/genTableColumn/add',
                    editUrl: '/online/genTableColumn/edit',
                    queryByIdUrl: '/online/genTableColumn/queryById',
                    pageSize: 100,
                    tableConfig: {
                        tableModel: "editAllModel",
                        columns: [
                            {
                            title: '数据库字段',
                            width: 150,
                            dataIndex: 'fieldName',
                            align: 'center',
                            fixed: 'left',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '显示列名',
                            width: 150,
                            dataIndex: 'name',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '字段别名',
                            width: 150,
                            dataIndex: 'filedAs',
                            align: 'center',
                            visible: false,
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '列宽',
                            width: 150,
                            dataIndex: 'width',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '是否显示',
                            width: 150,
                            dataIndex: 'isShow',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Switch',
                            editComponentProps: {
                                checkedValue: 1,
                                unCheckedValue: 0,
                            },
                            },
                            {
                            title: '是否编辑',
                            width: 150,
                            dataIndex: 'isEdit',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Switch',
                            editComponentProps: {
                                checkedValue: 1,
                                unCheckedValue: 0,
                            },
                            },
                            {
                            title: '控件类型',
                            width: 250,
                            dataIndex: 'controlType',
                            align: 'center',
                            editRow: true,
                            editComponent: 'DictSelectTag',
                            editComponentProps: {
                                dictCode: 'control_type',
                                placeholder: '请点击选择',
                            },
                            },
                            {
                            title: '字典table',
                            width: 150,
                            dataIndex: 'dictTable',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '字典code',
                            width: 150,
                            dataIndex: 'dictCode',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '字典text',
                            width: 150,
                            dataIndex: 'dictText',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '编辑规则',
                            width: 150,
                            dataIndex: 'editRuler',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '默认值',
                            width: 150,
                            dataIndex: 'defaultVal',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '文本对齐',
                            width: 150,
                            dataIndex: 'align',
                            align: 'center',
                            editRow: true,
                            editComponent: 'DictSelectTag',
                            editComponentProps: {
                                dictCode: 'align',
                                placeholder: '请点击选择',
                                width: '100%',
                            },
                            },
                            {
                            title: '是否排序',
                            width: 150,
                            dataIndex: 'isOrder',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Switch',
                            editComponentProps: {
                                checkedValue: 1,
                                unCheckedValue: 0,
                            },
                            },
                            {
                            title: '锁定',
                            width: 150,
                            dataIndex: 'fixed',
                            align: 'center',
                            editRow: true,
                            editComponent: 'DictSelectTag',
                            editComponentProps: {
                                dictCode: 'align',
                                placeholder: '请点击选择',
                                width: '100%',
                            },
                            },
                            {
                            title: '显示顺序',
                            width: 150,
                            dataIndex: 'displayOrder',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '控件扩展参数',
                            width: 150,
                            dataIndex: 'controlExtend',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '是否溢出省略号',
                            width: 150,
                            dataIndex: 'ellipsis',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Switch',
                            editComponentProps: {
                                checkedValue: 1,
                                unCheckedValue: 0,
                            },
                            },
                            {
                            title: '是否导出',
                            width: 150,
                            dataIndex: 'isExport',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Switch',
                            editComponentProps: {
                                checkedValue: 1,
                                unCheckedValue: 0,
                            },
                            },
                            {
                            title: '是否表字段',
                            width: 150,
                            dataIndex: 'isTableField',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Switch',
                            editComponentProps: {
                                checkedValue: 1,
                                unCheckedValue: 0,
                            },
                            },
                            {
                            title: '字段类型',
                            width: 150,
                            dataIndex: 'fieldType',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
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
                },
                {
                    field: 'queryData',
                    label: '查询字段',
                    component: 'childTable',
                    componentProps: {
                        relatedField: "id:mainId",
                    },
                    listUrl: '/online/genTableQuery/list',
                    deleteUrl: '/online/genTableQuery/delete',
                    deleteBatchUrl: '/online/genTableQuery/deleteBatch',
                    addUrl: '/online/genTableQuery/add',
                    editUrl: '/online/genTableQuery/edit',
                    queryByIdUrl: '/online/genTableQuery/queryById',
                    pageSize: 100,
                    tableConfig: {
                        tableModel: "editAllModel",
                        columns: [
                            {
                            title: '字段名称',
                            width: 150,
                            dataIndex: 'fieldName',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '显示列名',
                            width: 150,
                            dataIndex: 'name',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '是否查询',
                            width: 150,
                            dataIndex: 'isQuery',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Switch',
                            editComponentProps: {
                                checkedValue: 1,
                                unCheckedValue: 0,
                            },
                            },
                            {
                            title: '查询控件',
                            width: 150,
                            dataIndex: 'controlType',
                            align: 'center',
                            editRow: true,
                            editComponent: 'DictSelectTag',
                            editComponentProps: {
                                dictCode: 'control_type',
                                placeholder: '请点击选择',
                            },
                            },
                            {
                            title: '控件宽度',
                            width: 150,
                            dataIndex: 'width',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '6为一行4列，8为一行3列，24为一行1列，默认4列',
                            },
                            },
                            {
                            title: '匹配方式',
                            width: 150,
                            dataIndex: 'queryMatch',
                            align: 'center',
                            editRow: true,
                            editComponent: 'DictSelectTag',
                            editComponentProps: {
                                dictCode: 'rule_conditions',
                                placeholder: '请点击选择',
                            },
                            },
                            {
                            title: '必填',
                            width: 150,
                            dataIndex: 'isRequire',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Switch',
                            editComponentProps: {
                                checkedValue: 1,
                                unCheckedValue: 0,
                            },
                            },
                            {
                            title: '查询类型',
                            width: 150,
                            dataIndex: 'queryType',
                            align: 'center',
                            editRow: true,
                            editComponent: 'DictSelectTag',
                            editComponentProps: {
                                dictCode: 'query_type',
                                placeholder: '请点击选择',
                            },
                            },
                            {
                            title: '显示顺序',
                            width: 150,
                            dataIndex: 'displayOrder',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                min: 0,
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '控件扩展参数',
                            width: 150,
                            dataIndex: 'controlExtend',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '默认值',
                            width: 150,
                            dataIndex: 'defaultVal',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '字典table',
                            width: 150,
                            dataIndex: 'dictTable',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '字典code',
                            width: 150,
                            dataIndex: 'dictCode',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '字典text',
                            width: 150,
                            dataIndex: 'dictText',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
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
                },
            ]
        }
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
    
    //该组件在FluFormPane类中用formActionLoader实例化, 所以可以访问formPane对象
    Component {
        id: comFormCustomAction
        RowLayout {
            Layout.fillWidth: true

            FluFilledButton {
                text: qsTr("同步表字段")
                visible: {
                    var formData = formPane.formData
                    return formData && formData.dataSource && formData.dataTable ? true : false
                }
                onClicked: {
                    getTableColumnsCallable.httpRequest()
                }
            }

            FluNetworkCallable{
                id: getTableColumnsCallable
                property string postfixUrl: "/sys/dataSource/getTableColumns"
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

                        if (!jsResult.result || !jsResult.result.length) {
                            return
                        }

                        var columnMap = {}
                        var childTablePane = formPane.tablePanes[0]
                        var tableView = childTablePane.tableView
                        for (var i = 0; i < tableView.rows; i++) {
                            var obj = tableView.getRow(i)
                            columnMap[obj.fieldName] = obj
                        }

                        jsResult.result.forEach(function(item) {
                            if (!columnMap[item.id]) { //无需二次数组遍历
                                var uuid = FluTools.uuid()
                                var rowObj = {
                                    _key: uuid
                                    , _minimumHeight: childTablePane.defaultCellHeight
                                    , action: tableView.customItem(childTablePane.rowActionDelegate, {newRow: uuid})
                                }

                                for (var field in childTablePane.editFieldColumn) {
                                    rowObj[field] = null
                                }
                                rowObj.fieldName = item.id
                                rowObj.name = item.name

                                tableView.editedRows[uuid] = tableView.sourceModel.rowCount
                                tableView.appendRow(rowObj)
                            }
                        })
                    }

                function httpRequest() {
                    var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
                    .bind(root)
                    .addHeader("S-Token", GlobalModel.token)

                    var formData = formPane.formData
                    if (formData) {
                        networkParams.addQuery("dbCode", formData.dataSource)
                        networkParams.addQuery("tableId", formData.dataTable)
                    }
                    networkParams.go(getTableColumnsCallable)
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