import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import "../component"

FluWindow {
    id: window
    minimumWidth: 1000
    minimumHeight: 668
    property string roleId: ""
    property var rolePermissions: []

    onInitArgument:
        (argument)=>{
            roleId = argument.roleId || ""
            rolePermissions = argument.rolePermissions || []
            var procTreeList = (treeList) => {
                if (!treeList || !treeList.length) {
                    return [];
                }

                return treeList.map(node => {
                    const newNode = {
                        _key: node.key,
                        title: node.slotTitle,
                        checked: rolePermissions.indexOf(node.key) > -1
                    };

                    // 如果存在children，则递归处理
                    if (node.children && treeList.length) {
                        newNode.children = procTreeList(node.children);
                    }

                    return newNode;
                });
            }

            treeView.dataSource = procTreeList(argument.treeList)
        }

    FluScrollablePage {
        id: root
        anchors.fill: parent

        FluTreeView {
            id: treeView
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.fillWidth: true
            Layout.preferredHeight: 620
            cellHeight: 30
            depthPadding: 30
            showLine: false
            checkable: true
            onCurrentChanged: {
                showInfo(current.data.title)
            }
            columnSource: [
                {
                    title: qsTr("所拥有的权限"),
                    dataIndex: 'title',
                    width: treeView.width,
                    align: 'left',
                }
            ]
            Component.onCompleted: {
            }
        }

        RowLayout {
            Item {
                Layout.fillWidth: true
            }

            FluButton {
                text: qsTr("树操作")
                onClicked: {
                    menu.popup()
                }

                FluMenu {
                    id: menu
                    width: 100
                    FluMenuItem {
                        text: qsTr("父子关联")
                        onTriggered: {
                            showWarning(qsTr("暂未支持"))
                        }
                    }

                    FluMenuItem {
                        text: qsTr("取消关联")
                        onTriggered: {
                            showWarning(qsTr("暂未支持"))
                        }
                    }

                    FluMenuItem {
                        text: qsTr("全部勾选")
                        onTriggered: {
                            treeView.allCheck()
                        }
                    }

                    FluMenuItem {
                        text: qsTr("取消全选")
                        onTriggered: {
                            treeView.allUncheck()
                        }
                    }

                    FluMenuItem {
                        text: qsTr("展开所有")
                        onTriggered: {
                            treeView.allExpand()
                        }
                    }

                    FluMenuItem {
                        text: qsTr("合并所有")
                        onTriggered: {
                            treeView.allCollapse()
                        }
                    }
                }
            }

            FluButton {
                text: qsTr("取消")
                onClicked: {
                    cancelDialog.open()
                }

                FluContentDialog {
                    id: cancelDialog
                    title: qsTr("取消")
                    message: qsTr("确定放弃编辑?")
                    buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
                    negativeText: qsTr("取消")
                    positiveText: qsTr("确定")
                    onPositiveClicked: {
                        window.close()
                    }
                }
            }

            FluButton {
                text: qsTr("仅保存")
                onClicked: {
                    saveRolePermissionCallable.httpRequest()
                }
            }

            FluFilledButton {
                text: qsTr("保存并关闭")
                onClicked: {
                    saveRolePermissionCallable.httpRequest()
                    close()
                }
            }
        }
    }

    FluNetworkCallable{
        id: saveRolePermissionCallable
        property string postfixUrl: "/sys/role/saveRolePermission"
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
            }

        function httpRequest() {
            var networkParams = FluNetwork.postJson(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            var permissionIds = ""
            var selectionModel = treeView.selectionModel()
            for(var i = 0; i <= selectionModel.length - 1; i++){
                var data = selectionModel[i].data
                if (selectionModel[i].checked) {
                    permissionIds += data._key + ","
                }
            }

            if (permissionIds.length > 0) {
                permissionIds = permissionIds.substring(0, permissionIds.length - 1) //去掉最后一个逗号
            }

            networkParams.add("lastpermissionIds", rolePermissions.join(","))
            networkParams.add("permissionIds", permissionIds)
            networkParams.add("roleId", roleId)
            networkParams.go(saveRolePermissionCallable)
            rolePermissions = permissionIds.split(",")
        }
    }
}
