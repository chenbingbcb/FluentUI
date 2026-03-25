import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import "../component"

FluScrollablePage {
    id: root
    property var isRootMenu: (type) => type === 0
    property var isChildMenu: (type) => type === 1
    property var isButtonPermission: (type) => type === 2

    FluTreePane {
        id: treePane
        listUrl: '/sys/permission/list'
        deleteUrl: '/sys/permission/delete'
        addUrl: '/sys/permission/add'
        editUrl: '/sys/permission/edit'
        queryByIdUrl: '/sys/permission/queryById'
        treeActionDelegate: comTreeAction
        rowActionDelegate: comRowAction
        treeTitle: "菜单管理"
        treeConfig: {
            "columns": [
                {
                  title: '菜单名称',
                  dataIndex: 'name',
                  width: 200*1.5,
                  align: 'left',
                },
                {
                  title: '菜单类型',
                  dataIndex: 'menuType',
                  width: 150*1.5,
                  format: 'dict|menu_type',
                },
                {
                  title: '图标',
                  dataIndex: 'icon',
                  width: 50*1.5,
                },
                {
                  title: '组件',
                  dataIndex: 'component',
                  align: 'left',
                  width: 150*1.5,
                },
                {
                  title: '路径',
                  dataIndex: 'url',
                  align: 'left',
                  width: 150*1.5,
                },
                {
                  title: '排序',
                  dataIndex: 'sortNo',
                  width: 50*1.5,
                },
            ],
            "actionColumn": {
                "width": 120,
                "title": "操作",
                "dataIndex": "action"
            },
        }
        formConfig: {
            "schemas": [
                {
                  label: 'id',
                  field: 'id',
                  component: 'Input',
                  ifShow: false,
                },
                {
                  field: 'menuType',
                  label: '菜单类型',
                  component: 'RadioButtonGroup',
                  componentProps: {
                      options: [
                          { label: '一级菜单', value: 0 },
                          { label: '子菜单', value: 1 },
                          { label: '按钮/权限', value: 2 },
                        ],
                  },
                  defaultValue: 0,
                  updateSchema: true,
                },
                {
                  field: 'name',
                  label: '名称',
                  component: 'Input',
                  required: true,
                },
                {
                  field: 'parentId',
                  label: '上级菜单',
                  component: 'TreeSelect',
                  required: (values) => !isRootMenu(values.menuType),
                  componentProps: {
                    replaceFields: {
                      title: 'name',
                      key: 'id',
                      value: 'id',
                    },
                    dropdownStyle: {
                      maxHeight: '50vh',
                    },
                    getPopupContainer: (node) => node.parentNode,
                  },
                  ifShow: (values) => !isRootMenu(values.menuType),
                },
                {
                  field: 'url',
                  label: '访问路径',
                  component: 'Input',
                  required: (values) => !isButtonPermission(values.menuType),
                  ifShow: (values) => !isButtonPermission(values.menuType),
                },
                {
                  field: 'component',
                  label: '前端组件',
                  component: 'Input',
                  componentProps: {
                    placeholder: '请输入前端组件',
                  },
                  required: true,
                  ifShow: (values) => !isButtonPermission(values.menuType),
                },
                {
                  field: 'frameSrc',
                  label: 'Iframe地址',
                  component: 'Input',
                  rules: [
                    { required: true, message: '请输入Iframe地址' },
                  ],
                  ifShow: false, //暂不支持iframe地址输入
                },
                {
                  field: 'isCppComp',
                  label: 'C++组件',
                  component: 'SInput',
                  ifShow: (values) => isRootMenu(values.menuType),
                },
                {
                  field: 'redirect',
                  label: '默认跳转地址',
                  component: 'Input',
                  ifShow: (values) => isRootMenu(values.menuType),
                },
                {
                  field: 'permsType',
                  label: '授权策略',
                  component: 'RadioGroup',
                  defaultValue: '1',
                  helpMessage: ['可见/可访问(授权后可见/可访问)', '可编辑(未授权时禁用)'],
                  componentProps: {
                    options: [
                      { label: '可见/可访问', value: '1' },
                      { label: '可编辑', value: '2' },
                    ],
                  },
                  ifShow: (values) => isButtonPermission(values.menuType),
                },
                {
                  field: 'status',
                  label: '状态',
                  component: 'RadioGroup',
                  defaultValue: '1',
                  componentProps: {
                    options: [
                      { label: '有效', value: '1' },
                      { label: '无效', value: '0' },
                    ],
                  },
                  ifShow: (values) => isButtonPermission(values.menuType),
                },
                {
                  field: 'icon',
                  label: '菜单图标',
                  component: 'Input',
                  ifShow: (values) => !isButtonPermission(values.menuType),
                },
                {
                  field: 'sortNo',
                  label: '排序',
                  component: 'Input',
                  defaultValue: 1,
                  ifShow: (values) => !isButtonPermission(values.menuType),
                },
                {
                  field: 'route',
                  label: '是否路由菜单',
                  component: 'Switch',
                  defaultValue: true,
                  componentProps: {
                  },
                  ifShow: (values) => !isButtonPermission(values.menuType),
                },
                {
                  field: 'hidden',
                  label: '隐藏路由',
                  component: 'Switch',
                  defaultValue: 0,
                  componentProps: {
                  },
                  ifShow: (values) => !isButtonPermission(values.menuType),
                },
                {
                  field: 'hideTab',
                  label: '隐藏Tab',
                  component: 'Switch',
                  defaultValue: 0,
                  componentProps: {
                  },
                  ifShow: (values) => !isButtonPermission(values.menuType),
                },
                {
                  field: 'keepAlive',
                  label: '是否缓存路由',
                  component: 'Switch',
                  defaultValue: false,
                  componentProps: {
                  },
                  ifShow: (values) => !isButtonPermission(values.menuType),
                },
                {
                  field: 'alwaysShow',
                  label: '聚合路由',
                  component: 'Switch',
                  defaultValue: false,
                  componentProps: {
                  },
                  ifShow: (values) => !isButtonPermission(values.menuType),
                },
                {
                  field: 'internalOrExternal',
                  label: '是否外部打开方式',
                  component: 'Switch',
                  defaultValue: false,
                  componentProps: {
                  },
                  ifShow: (values) => !isButtonPermission(values.menuType),
                },
            ]
        }
    }

    property var permissionRuleFormData: ({})
    property var permissionRuleFormConfig: ({
        schemas: [
            {
                "field": "permissionRule",
                "label": "",
                "component": "childTable",
                "colProps": {
                    "span": 8
                },
                "componentProps": {
                    "relatedField": "id:permissionId",
                },
                "listUrl": "/sys/permission/queryPermissionRule",
                "deleteUrl": "/sys/permission/deletePermissionRule",
                "addUrl": "/sys/permission/addPermissionRule",
                "editUrl": "/sys/permission/editPermissionRule",
                queryByIdUrl: "",
                "tableConfig": {
                    // "tableModel": "editSingleModel",
                    "formConfig": {
                        "labelWidth": 120,
                        "schemas": [
                            {
                              field: 'ruleName',
                              label: '规则名称',
                              component: 'Input',
                              colProps: { span: 6 },
                            },
                            {
                              field: 'ruleValue',
                              label: '规则值',
                              component: 'Input',
                              colProps: { span: 6 },
                            },
                        ]
                    },
                    "columns": [
                        {
                          title: '规则名称',
                          dataIndex: 'ruleName',
                          width: 150*1.5,
                        },
                        {
                          title: '规则字段',
                          dataIndex: 'ruleColumn',
                          width: 100*1.5,
                        },
                        {
                          title: '规则值',
                          dataIndex: 'ruleValue',
                          width: 100*1.5,
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
                          label: 'id',
                          field: 'id',
                          component: 'Input',
                          ifShow: false,
                        },
                        {
                          field: 'ruleName',
                          label: '规则名称',
                          component: 'Input',
                          required: true,
                        },
                        {
                          field: 'ruleColumn',
                          label: '规则字段',
                          component: 'Input',
                          ifShow: (values) => {
                            return values.ruleConditions !== 'USE_SQL_RULES';
                          },
                        },
                        {
                          field: 'ruleConditions',
                          label: '条件规则',
                          required: true,
                          component: 'DictSelectTag',
                          componentProps: {
                            dictCode: 'rule_conditions',
                          },
                        },
                        {
                          field: 'ruleValue',
                          label: '规则值',
                          component: 'Input',
                          required: true,
                        },
                        {
                          field: 'status',
                          label: '状态',
                          component: 'RadioButtonGroup',
                          defaultValue: '1',
                          componentProps: {
                            options: [
                              { label: '无效', value: '0' },
                              { label: '有效', value: '1' },
                            ],
                          },
                        },
                    ]
                }
            },
        ]
    })

    Component {
        id: comTreeAction
        FluFilledButton {
            visible: true
            text: qsTr("新增")
            onClicked: {
                permissionListCallable.httpRequest(null)
            }
        }
    }

    Component {
        id: comRowAction
        Item{
            RowLayout{
                anchors.centerIn: parent
                spacing: 0

                FluTextButton {
                    text: qsTr("编辑")
                    onClicked: {
                        var rowObj = treePane.treeView.getRow(row)
                        permissionListCallable.httpRequest(rowObj)
                    }
                }

                FluIconButton {
                    id: moreButton
                    iconSource: FluentIcons.More
                    iconSize: 15
                    iconColor: FluTheme.primaryColor
                    onClicked: {
                        menu.popup()
                    }

                    FluMenu {
                        id: menu
                        width: 100
                        FluMenuItem {
                            text: qsTr("添加下级")
                            onTriggered: {
                              var rowObj = treePane.treeView.getRow(row)
                              permissionListCallable.httpRequest(rowObj)
                            }
                        }

                        FluMenuItem {
                            text: qsTr("数据规则")
                            onTriggered: {
                              permissionRuleFormData = {}
                              var rowObj = treePane.treeView.getRow(row)
                              permissionRuleFormData.id = rowObj.id
                              FluRouter.navigate("/onlineFormWindow", {
                                                      formPaneData: {
                                                          formConfig: permissionRuleFormConfig
                                                          , title: qsTr("数据权限规则")
                                                          , formData: permissionRuleFormData
                                                          , saveButtonInvisile: true
                                                      }
                                                 }, treePane)
                            }
                        }

                        FluMenuItem {
                            text: qsTr("删除")
                            onTriggered: {
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
                                    var rowObj = treePane.treeView.getRow(row)
                                    if (rowObj.id) {
                                        treePane.deleteCallback(row)
                                    }

                                    treePane.treeView.removeRow(row)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    FluNetworkCallable{
        id: permissionListCallable
        property string postfixUrl: "/sys/permission/list"
        property var rowObj
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

                var formConfig = Object.assign({}, treePane.formConfig)
                // if (formConfig && formConfig.schemas) {
                //     var config = formConfig.schemas.find(item => item.component === "TreeSelect")
                //     if (config) {
                //   config.componentProps = config.componentProps || {}
                //         Object.assign(config.componentProps, {treeList: jsResult.result})
                //         config.componentProps.options = jsResult.result
                //     }
                // }

                var formTitle = rowObj ? qsTr("编辑") : qsTr("新增")
                FluRouter.navigate("/onlineFormWindow", {
                                       formPaneData: {
                                           formConfig: formConfig
                                           , formData: rowObj
                                           , title: formTitle
                                       }
                                   }, treePane)
            }

        function httpRequest(rowObj) {
            permissionListCallable.rowObj = rowObj
            var networkParams = FluNetwork.get(GlobalModel.basicUrl + postfixUrl)
            .bind(root)
            .addHeader("S-Token", GlobalModel.token)

            networkParams.go(permissionListCallable)
        }
    }
}
