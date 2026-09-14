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
        ColumnLayout {
            RowLayout {
                FluFilledButton {
                    visible: true
                    text: qsTr("新增")
                    onClicked: {
                        
                    }
                }

                FluFilledButton {
                    visible: true
                    text: qsTr("添加下级")
                    onClicked: {
                        
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
                    text: qsTr("搜索")
                    onClicked: {
                        if (searchTextBox.text) {
                            searchByCallable.httpRequest(searchTextBox.text)
                        } else {
                            queryDepartTreeSyncCallable.httpRequest()
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
                    queryDepartTreeSyncCallable.httpRequest()
                }
                onCurrentChanged: {
                }
                onToggle: {
                    console.debug("treeView toggle: " + toExpand)
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

            // 如果存在children，则递归处理
            if (node.children && treeList.length) {
                node.children = procTreeList(node.children)
            }

            return node;
        });
    }

    FluNetworkCallable{
        id: queryDepartTreeSyncCallable
        property string postfixUrl: "/sys/sysDepart/queryDepartTreeSync"
        property var pid
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
                if (pid) {
                    var dataSource = []
                    tableData.forEach(function(record) {
                        record._key = FluTools.uuid()
                        record._minimumHeight = 50
                        dataSource.push(record)
                    })

                    treeView.dataSource = procTreeList(dataSource)
                } else {
                    queryDepartTreeSyncCallable.httpRequest(tableData[0].id)
                }
            }

        function httpRequest(pid) {
            this.pid = pid
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            if (pid) {
                networkParams.addQuery("pid", pid)
            }

            networkParams.go(queryDepartTreeSyncCallable)
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
