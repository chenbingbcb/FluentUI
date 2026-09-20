import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id: root

    RowLayout {
        ColumnLayout {
            RowLayout {
                FluTextBox {
                    id: searchTextBox
                    Layout.fillWidth: true
                    placeholderText: qsTr("输入名称搜索")
                }

                FluFilledButton {
                    text: qsTr("搜索")
                    onClicked: {
                        if (searchTextBox.text) {
                            searchByCallable.httpRequest(searchTextBox.text)
                        } else {
                            queryTreeListCallable.httpRequest(false)
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
                columnSource: [{ title: "部门", dataIndex: "title", align: "left", width: treeView.width }]
                Component.onCompleted: {
                    queryTreeListCallable.httpRequest(true)
                }
                onCurrentChanged: {
                    queryByOrgCodeForAddressListCallable.httpRequest(current.data.orgCode)
                }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: root.width / 2

            FluTablePane {
                id: tablePane
                listCallback: queryByOrgCodeForAddressListCallable.httpRequest
                tableTitle: "业务权限"
                pageNo: 1
                pageSize: 15
                tableConfig: {
                    "formConfig": {
                        "labelWidth": 120,
                        "schemas": [
                            {
                                "field": "realname",
                                "label": "姓名",
                                "component": "Input",
                                "colProps": { "span": 8 }
                            },
                            {
                                "field": "workNo",
                                "label": "工号",
                                "component": "Input",
                                "colProps": { "span": 8 }
                            },
                        ]
                    },
                    "columns": [
                        {
                            title: '姓名',
                            align: 'center',
                            dataIndex: 'realname',
                            width: 200,
                            resizable: true,
                        },
                        {
                            title: '工号',
                            align: 'center',
                            dataIndex: 'workNo',
                        },
                        {
                            title: '部门',
                            align: 'center',
                            dataIndex: 'departName',
                        },
                        {
                            title: '职务',
                            align: 'center',
                            dataIndex: 'post',
                        },
                        {
                            title: '手机',
                            align: 'center',
                            dataIndex: 'telephone',
                        },
                        {
                            title: '公司邮箱',
                            align: 'center',
                            dataIndex: 'email',
                        },
                    ],
                    // "defaultButtons": {
                    //     "add": {
                    //         "visible": true
                    //     },
                    // },
                }
                formConfig: {
                    "schemas": [
                        {
                            field: 'userId',
                            label: '用户ID',
                            component: 'Input',
                        },
                        {
                            field: 'busiKey',
                            label: '业务key',
                            component: 'DictSelectTag',
                            componentProps: {
                            dictCode: 'sys_busi_rule',
                            },
                            rules: [
                            {
                                required: true,
                                message: '请选择业务key',
                            },
                            ],
                        },
                        {
                            field: 'busiValue',
                            label: '业务值',
                            component: 'Input',
                            rules: [
                            {
                                required: true,
                                message: '请输入业务值',
                            },
                            ],
                        },
                    ]
                }
            }
        }
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

    FluNetworkCallable {
        id: queryTreeListCallable
        property string postfixUrl: "/sys/sysDepart/queryTreeList"
        property bool collapse: false
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
                if (collapse) {
                    treeView.allCollapse()
                }
            }

        function httpRequest(collapse) {
            this.collapse = collapse
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            networkParams.go(queryTreeListCallable)
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
        id: queryByOrgCodeForAddressListCallable
        property string postfixUrl: "/sys/user/queryByOrgCodeForAddressList"
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
                    dataSource.push(record)
                })

                tablePane.tableItemCount = tableData.total || 0
                tablePane.pageSize = tableData.size || 15
                tablePane.tableView.dataSource = dataSource
            }

        function httpRequest(orgCode) {
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)
            .addQuery("order", "desc")
            .addQuery("column", "createTime")
            .addQuery("pageNo", tablePane.pageNo)
            .addQuery("pageSize", tablePane.pageSize)
            
            if (orgCode) {
                networkParams.addQuery("orgCode", orgCode)
            }

            for(var key in tablePane.queryParams) {
                var loaderItem = tablePane.queryParams[key]
                if (loaderItem.value) {
                    networkParams.addQuery(key, loaderItem.value)
                }
            }

            networkParams.go(queryByOrgCodeForAddressListCallable)
        }
    }
}
