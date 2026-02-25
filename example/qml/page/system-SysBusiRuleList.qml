import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id: root
    FluTablePane {
        listUrl: "/sys/sysBusiRule/list"
        deleteUrl: "/sys/sysBusiRule/delete"
        addUrl: "/sys/sysBusiRule/add"
        editUrl: "/sys/sysBusiRule/edit"
        queryByIdUrl: "/sys/sysBusiRule/queryById"
        tableTitle: "业务权限"
        tableConfig: {
            "tableModel": "modalSingleModel",
            "formConfig": {
                "labelWidth": 120,
                "schemas": [
                    {
                        "field": "userId",
                        "label": "用户ID",
                        "component": "SInput",
                        "componentProps": {
                            "type": "LIKE"
                        },
                        "colProps": {
                            "span": 8
                        }
                    },
                    {
                        "field": "busiKey",
                        "label": "业务key",
                        "component": "DictSelectTag",
                        "componentProps": {
                            "dictCode": "sys_busi_rule"
                        },
                        "colProps": {
                            "span": 8
                        }
                    },
                    {
                        "field": "busiValue",
                        "label": "业务值",
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
            "columns": [
                {
                    "title": "用户ID",
                    "dataIndex": "userId",
                    "width": 200
                },
                {
                    "title": "业务key",
                    "dataIndex": "busiKey_dictText",
                    "width": 200
                },
                {
                    "title": "业务值",
                    "dataIndex": "busiValue",
                    "width": 200
                }
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
                    "field": "userId",
                    "label": "用户ID",
                    "component": "Input",
                    "colProps": {
                        "span": 8
                    },
                    "componentProps": {}
                },
                {
                    "field": "busiKey",
                    "label": "业务key",
                    "component": "DictSelectTag",
                    "colProps": {
                        "span": 8
                    },
                    "required": true,
                    "componentProps": {
                        "dictCode": "sys_busi_rule"
                    }
                },
                {
                    "field": "busiValue",
                    "label": "业务值",
                    "component": "Input",
                    "colProps": {
                        "span": 8
                    },
                    "required": true,
                    "componentProps": {}
                }
            ]
        }
    }
}
