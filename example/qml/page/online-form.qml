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
        listUrl: "/online/genFormHead/list"
        deleteUrl: "/online/genFormHead/delete"
        addUrl: "/online/genFormHead/add"
        editUrl: "/online/genFormHead/edit"
        queryByIdUrl: "/online/genFormHead/queryById"
        rowActionDelegate: comRowAction
        formActionDelegate: comFormCustomAction
        tableTitle: "表单管理"
        tableConfig: {
            "tableModel": "modalSingleModel",
            "formConfig": {
                "labelWidth": 120,
                "schemas": [
                    {
                        field: 'id',
                        label: 'id',
                        component: 'Input',
                        colProps: { span: 8 },
                    },
                    {
                        field: 'dataSource',
                        label: '数据源',
                        component: 'Input',
                        colProps: { span: 8 },
                    },
                    {
                        field: 'dataTable',
                        label: '数据表',
                        component: 'Input',
                        colProps: { span: 8 },
                    },
                    {
                        field: 'name',
                        label: '表单名称',
                        component: 'Input',
                        colProps: { span: 8 },
                    },
                    {
                        field: 'code',
                        label: '表单编码',
                        component: 'Input',
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
                },
                {
                    title: '表单编码',
                    align: 'center',
                    dataIndex: 'code',
                    width: 200,
                },
                {
                    title: '表单名称',
                    align: 'center',
                    dataIndex: 'name',
                    width: 200,
                },
                {
                    title: '数据源',
                    align: 'center',
                    dataIndex: 'dataSource',
                    width: 200,
                },
                {
                    title: '数据表',
                    align: 'center',
                    dataIndex: 'dataTable',
                    width: 200,
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
                    field: 'dataSource',
                    label: '数据源',
                    component: 'Select',
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
                    field: 'code',
                    label: '表单编号',
                    component: 'Input',
                    rules: [
                    {
                        required: true,
                        message: '请输入表单编码',
                    },
                    ],
                },
                {
                    field: 'name',
                    label: '表单名称',
                    component: 'Input',
                    rules: [
                    {
                        required: true,
                        message: '请输入表单名称',
                    },
                    ],
                },
                {
                    field: 'layout',
                    label: '表单控件列数',
                    component: 'Input',
                    componentProps: {
                    placeholder: '请输入表单控件列数，默认4列',
                    },
                },
                {
                    field: 'deviceType',
                    label: '设备类型',
                    component: 'DictSelectTag',
                    componentProps: {
                    dictCode: 'device_type',
                    },
                },
                {
                    field: 'formConfig',
                    label: '表单配置扩展属性',
                    component: 'Textarea',
                    componentProps: {
                    placeholder: '请输入表单配置扩展属性',
                    },
                },
                {
                    field: 'hasSub',
                    label: '是否有子表',
                    component: 'DictSelectTag',
                    componentProps: {
                    dictCode: 'yn',
                    },
                    rules: [
                    {
                        required: true,
                        message: '请选择是否有子表',
                    },
                    ],
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
                    listUrl: '/online/genFormDetail/list',
                    deleteUrl: '/online/genFormDetail/delete',
                    deleteBatchUrl: '/online/genFormDetail/deleteBatch',
                    addUrl: '/online/genFormDetail/add',
                    editUrl: '/online/genFormDetail/edit',
                    queryByIdUrl: '/online/genFormDetail/queryById',
                    pageSize: 100,
                    tableConfig: {
                        tableModel: "editAllModel",
                        columns: [
                            {
                            title: '字段名称',
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
                            title: '显示名称',
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
                            title: '类型',
                            width: 150,
                            dataIndex: 'controlType',
                            align: 'center',
                            editRow: true,
                            editComponent: 'DictSelectTag',
                            editComponentProps: {
                                dictCode: 'form_type',
                                placeholder: '请点击选择',
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
                            title: '编辑只读',
                            width: 150,
                            dataIndex: 'isEditReadonly',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Switch',
                            editComponentProps: {
                                checkedValue: 1,
                                unCheckedValue: 0,
                            },
                            },
                            {
                            title: '编辑规则',
                            width: 150,
                            dataIndex: 'isRequire',
                            align: 'center',
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
                            title: '字典table',
                            width: 150,
                            dataIndex: 'dictTable',
                            align: 'center',
                            //visible: false,
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
                            //  visible: false,
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
                            // visible: false,
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
                            title: '提示',
                            width: 150,
                            dataIndex: 'placeholder',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '小屏列宽',
                            width: 150,
                            dataIndex: 'smallScrean',
                            align: 'center',
                            visible: false,
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },

                            {
                            title: '中屏列宽',
                            width: 150,
                            dataIndex: 'midScreen',
                            align: 'center',
                            visible: false,
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '后缀按钮',
                            width: 150,
                            dataIndex: 'afterFixButton',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '控件扩展属性',
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
                            title: '与主表关联字段',
                            width: 150,
                            dataIndex: 'relatedField',
                            align: 'center',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '顺序',
                            width: 150,
                            dataIndex: 'displayOrder',
                            align: 'center',
                            formatter: 'formatObj',
                            editRow: true,
                            editComponent: 'Input',
                            editComponentProps: {
                                placeholder: '请点击输入',
                            },
                            },
                            {
                            title: '同主表删除',
                            width: 150,
                            dataIndex: 'delWithMain',
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
                    id: dictButton
                    iconSource: FluentIcons.Settings
                    iconSize: 15
                    onClicked: {
                        customButtonFormData = {}
                        var rowObj = tablePane.tableView.getRow(row)
                        customButtonFormData.id = rowObj.id
                        FluRouter.navigate("/onlineFormWindow", {
                            title: qsTr("自定义按钮")
                            , saveFormBtnInvisile: true
                            , formConfig: customButtonFormConfig
                            , formData: customButtonFormData
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
                                label: '表单',
                                value: 'form',
                                key: '1',
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