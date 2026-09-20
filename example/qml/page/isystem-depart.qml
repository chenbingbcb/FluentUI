import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id: root
    property var loadedRecursiveTreeData: []
    property var addCallback: sysDepartAddCallable.httpRequest //新增单行数据回调

    RowLayout {
        ColumnLayout {
            Layout.preferredWidth: root.width / 2
            RowLayout {
                FluFilledButton {
                    visible: true
                    text: qsTr("新增")
                    onClicked: {
                        var formConfig = {
                            "schemas": [
                                {
                                    field: 'departName',
                                    label: '机构名称',
                                    component: 'Input',
                                    componentProps: {
                                    placeholder: '请输入机构/部门名称',
                                    },
                                    rules: [{ required: true, message: '机构名称不能为空' }],
                                    colProps: { span: 24 },
                                    required: true,
                                },
                                {
                                    field: 'orgCode',
                                    label: '机构编码',
                                    component: 'Input',
                                    componentProps: {
                                    placeholder: '请输入机构编码',
                                    },
                                    colProps: { span: 24 },
                                    required: true,
                                },
                                {
                                    field: 'orgCategory',
                                    label: '机构类型',
                                    component: 'RadioButtonGroup',
                                    componentProps: {
                                        options: [
                                            { label: '公司', value: "1" },
                                        ],
                                    },
                                    colProps: { span: 24 },
                                },
                                {
                                    field: 'departOrder',
                                    label: '排序',
                                    component: 'Input',
                                    componentProps: {},
                                    colProps: { span: 24 },
                                },
                                {
                                    field: 'mobile',
                                    label: '电话',
                                    component: 'Input',
                                    componentProps: {
                                    placeholder: '请输入电话',
                                    },
                                    colProps: { span: 24 },
                                },
                                {
                                    field: 'fax',
                                    label: '传真',
                                    component: 'Input',
                                    componentProps: {
                                    placeholder: '请输入传真',
                                    },
                                    colProps: { span: 24 },
                                },
                                {
                                    field: 'address',
                                    label: '地址',
                                    component: 'Input',
                                    componentProps: {
                                    placeholder: '请输入地址',
                                    },
                                    colProps: { span: 24 },
                                },
                                {
                                    field: 'memo',
                                    label: '备注',
                                    component: 'Textarea',
                                    componentProps: {
                                    placeholder: '请输入备注',
                                    },
                                    colProps: { span: 24 },
                                },
                            ]
                        }

                        openFormWindow(qsTr("新增"), formConfig, {orgCategory: "1", departOrder: 0})
                    }
                }

                FluFilledButton {
                    visible: true
                    text: qsTr("添加下级")
                    onClicked: {
                        var currentData = treeView.current.data
                        var treeData = currentData.parentId ? findNodeByKeyRecursively(currentData.parentId).children : loadedRecursiveTreeData

                        var formConfig = {
                            "schemas": [
                                {
                                    field: 'departName',
                                    label: '机构名称',
                                    component: 'Input',
                                    componentProps: {
                                    placeholder: '请输入机构/部门名称',
                                    },
                                    rules: [{ required: true, message: '机构名称不能为空' }],
                                    colProps: { span: 24 },
                                    required: true,
                                },
                                {
                                    field: 'parentId',
                                    label: '上级部门',
                                    component: 'TreeSelect',
                                    componentProps: {
                                        replaceFields: {
                                            title: 'title',
                                            key: 'id',
                                            value: 'id',
                                        },
                                        treeData: treeData,
                                        placeholder: '无',
                                        dropdownStyle: { maxHeight: '200px', overflow: 'auto' },
                                    },
                                    colProps: { span: 24 },
                                    dynamicDisabled: true
                                },
                                {
                                    field: 'orgCode',
                                    label: '机构编码',
                                    component: 'Input',
                                    componentProps: {
                                    placeholder: '请输入机构编码',
                                    },
                                    colProps: { span: 24 },
                                    required: true,
                                },
                                {
                                    field: 'orgCategory',
                                    label: '机构类型',
                                    component: 'RadioButtonGroup',
                                    componentProps: {
                                        options: [
                                            { label: '部门', value: "2" },
                                            { label: '岗位', value: "3" },
                                        ],
                                    },
                                    colProps: { span: 24 },
                                },
                                {
                                    field: 'departOrder',
                                    label: '排序',
                                    component: 'Input',
                                    componentProps: {},
                                    colProps: { span: 24 },
                                },
                                {
                                    field: 'mobile',
                                    label: '电话',
                                    component: 'Input',
                                    componentProps: {
                                    placeholder: '请输入电话',
                                    },
                                    colProps: { span: 24 },
                                },
                                {
                                    field: 'fax',
                                    label: '传真',
                                    component: 'Input',
                                    componentProps: {
                                    placeholder: '请输入传真',
                                    },
                                    colProps: { span: 24 },
                                },
                                {
                                    field: 'address',
                                    label: '地址',
                                    component: 'Input',
                                    componentProps: {
                                    placeholder: '请输入地址',
                                    },
                                    colProps: { span: 24 },
                                },
                                {
                                    field: 'memo',
                                    label: '备注',
                                    component: 'Textarea',
                                    componentProps: {
                                    placeholder: '请输入备注',
                                    },
                                    colProps: { span: 24 },
                                },
                            ]
                        }

                        openFormWindow(qsTr("添加下级"), formConfig, {orgCategory: "2", departOrder: 0, parentId: currentData._key})
                    }
                }

                FluFilledButton {
                    visible: true
                    text: qsTr("批量删除")
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
                            var checkedKeys = treeView.getCheckedKeys()
                            deleteBatchCallable.httpRequest({ids: checkedKeys.join(",")})
                        }
                    }
                }
            }

            FluFrame {
                Layout.fillWidth: true
            }

            RowLayout {
                FluTextBox {
                    id: searchTextBox
                    Layout.fillWidth: true
                    placeholderText: qsTr("输入名称搜索")
                }

                FluFilledButton {
                    id: searchButton
                    text: qsTr("搜索")
                    onClicked: {
                        treeView.loadedKeys.clear()
                        if (searchTextBox.text) {
                            treeView.loadData = null
                            searchByCallable.httpRequest(searchTextBox.text)
                        } else {
                            treeView.loadData = loadDepartTreeData
                            queryDepartTreeSyncCallable.httpRequest(null)
                        }
                    }
                }
            }

            FluTreeView {
                id: treeView
                Layout.fillWidth: true
                Layout.preferredHeight: 640
                cellHeight: 30
                depthPadding: 30
                showHeader: false
                checkable: true
                checkStrictly: true
                defaultExpandAll: false
                columnSource: [{ title: "部门", dataIndex: "title", align: "left", width: treeView.width }]
                Component.onCompleted: {
                    queryDepartTreeSyncCallable.httpRequest(null)
                }
                onCurrentChanged: {
                    var treeData = []
                    if (current.data.parentId) {
                        var node = findNodeByKeyRecursively(current.data.parentId)
                        treeData = node.parentId ? findNodeByKeyRecursively(node.parentId).children : loadedRecursiveTreeData
                    }

                    for (var j = 0; j < formPane.formConfig.schemas.length; j++) {
                        var formConfig = formPane.formConfig.schemas[j]
                        if (formConfig.field === "parentId") {
                            formConfig.componentProps.treeData = treeData
                            break
                        }
                    }
                    formPane.formConfig = formPane.formConfig
                    formPane.formData = current.data
                }
                loadData: loadDepartTreeData
            }
        }

        FluFormPane {
            id: formPane
            title: "基本信息"
            formConfig: {
                "schemas": [
                    {
                        field: 'departName',
                        label: '机构名称',
                        component: 'Input',
                        componentProps: {
                        placeholder: '请输入机构/部门名称',
                        },
                        rules: [{ required: true, message: '机构名称不能为空' }],
                        colProps: { span: 24 },
                    },
                    {
                        field: 'parentId',
                        label: '上级部门',
                        component: 'TreeSelect',
                        componentProps: {
                            replaceFields: {
                                title: 'title',
                                key: 'id',
                                value: 'id',
                            },
                            treeData: [],
                            placeholder: '无',
                            dropdownStyle: { maxHeight: '200px', overflow: 'auto' },
                        },
                        colProps: { span: 24 },
                        dynamicDisabled: true
                    },
                    {
                        field: 'orgCode',
                        label: '机构编码',
                        component: 'Input',
                        componentProps: {
                        placeholder: '请输入机构编码',
                        },
                        colProps: { span: 24 },
                        dynamicDisabled: true
                    },
                    {
                        field: 'orgCategory',
                        label: '机构类型',
                        component: 'RadioButtonGroup',
                        componentProps: {
                            options: [
                                { label: '公司', value: "1" },
                                { label: '部门', value: "2" },
                                { label: '岗位', value: "3" },
                            ],
                        },
                        colProps: { span: 24 },
                    },
                    {
                        field: 'departOrder',
                        label: '排序',
                        component: 'Input',
                        componentProps: {},
                        colProps: { span: 24 },
                    },
                    {
                        field: 'mobile',
                        label: '电话',
                        component: 'Input',
                        componentProps: {
                        placeholder: '请输入电话',
                        },
                        colProps: { span: 24 },
                    },
                    {
                        field: 'fax',
                        label: '传真',
                        component: 'Input',
                        componentProps: {
                        placeholder: '请输入传真',
                        },
                        colProps: { span: 24 },
                    },
                    {
                        field: 'address',
                        label: '地址',
                        component: 'Input',
                        componentProps: {
                        placeholder: '请输入地址',
                        },
                        colProps: { span: 24 },
                    },
                    {
                        field: 'memo',
                        label: '备注',
                        component: 'Textarea',
                        componentProps: {
                        placeholder: '请输入备注',
                        },
                        colProps: { span: 24 },
                    },
                ]
            }
        }
    }

    function loadDepartTreeData(row, rowData) {
        queryDepartTreeSyncCallable.httpRequest(rowData)
    }

    function procTreeList(treeList) {
        if (!treeList || !treeList.length) {
            return [];
        }

        return treeList.map(node => {
            node._key = node.id || node.key
            node._minimumHeight = 50

            // 如果存在children，则递归处理
            if (node.children && treeList.length) {
                node.children = procTreeList(node.children)
            }

            return node;
        });
    }

    function updateTreeChildrenData(key, dataSource) {
        var node = findNodeByKeyRecursively(key)
        node.children = dataSource
    }

    function findNodeByKeyRecursively(key) {
        function search(nodes, key) {
            for (var i = 0; i < nodes.length; i++) {
                if (nodes[i]._key === key) {
                    return nodes[i]
                }
                if (nodes[i].children && nodes[i].children.length) {
                    var found = search(nodes[i].children, key)
                    if (found) {
                        return found
                    }
                }
            }
            return null
        }
        return search(loadedRecursiveTreeData, key)
    }

    function openFormWindow(formTitle, formConfig, rowFormData) {
        FluRouter.navigate("/onlineFormWindow", {
                               formConfig: formConfig
                               , formData: rowFormData
                               , title: formTitle
                           }, root)
    }

    FluNetworkCallable{
        id: queryDepartTreeSyncCallable
        property string postfixUrl: "/sys/sysDepart/queryDepartTreeSync"
        property var pid
        property var rowData: null
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

                var dataSource = procTreeList(jsResult.result)
                if (rowData) {
                    rowData.children = dataSource
                    treeView.loadedKeys.add(rowData._key)
                    treeView.insertChildNodes(rowData._key, dataSource)
                    updateTreeChildrenData(rowData._key, dataSource)
                } else {
                    //根节点
                    treeView.dataSource = dataSource
                    // formPane.formData = dataSource[0]
                    treeView.setCurrentByKey(dataSource[0]._key) //设置初始节点
                    treeView.loadData(0, treeView.getRow(0))
                    loadedRecursiveTreeData = dataSource
                }
            }

        function httpRequest(rowData) {
            this.rowData = rowData
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            if (rowData) {
                networkParams.addQuery("pid", rowData._key)
            }

            networkParams.go(queryDepartTreeSyncCallable)
        }
    }

    FluNetworkCallable {
        id: searchByCallable
        property string postfixUrl: "/sys/sysDepart/searchBy"
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

                treeView.dataSource = procTreeList(jsResult.result)
            }

        function httpRequest(searchText) {
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)
            .addQuery("keyWord", searchText)

            networkParams.go(searchByCallable)
        }
    }

    FluNetworkCallable {
        id: sysDepartAddCallable
        property string postfixUrl: "/sys/sysDepart/add"
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

                treeView.loadedKeys.clear()
                treeView.loadData = loadDepartTreeData
                queryDepartTreeSyncCallable.httpRequest(null)
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.postJson(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            for(var key in params) {
                networkParams.add(key, params[key])
            }

            networkParams.go(sysDepartAddCallable)
        }
    }

    FluNetworkCallable {
        id: deleteBatchCallable
        property string postfixUrl: "/sys/sysDepart/deleteBatch"
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

                treeView.loadedKeys.clear()
                treeView.loadData = loadDepartTreeData
                queryDepartTreeSyncCallable.httpRequest(null)
            }

        function httpRequest(params) {
            var networkParams = FluNetwork.deleteJson(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            for(var key in params) {
                networkParams.addQuery(key, params[key])
            }

            networkParams.go(deleteBatchCallable)
        }
    }
}
