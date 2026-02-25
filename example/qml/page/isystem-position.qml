import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id: root
    FluTablePane {
        listUrl: '/sys/sysPosition/list'
        deleteUrl: '/sys/sysPosition/delete'
        addUrl: '/sys/sysPosition/add'
        editUrl: '/sys/sysPosition/edit'
        queryByIdUrl: '/sys/sysPosition/queryById'
        tableTitle: "职务管理"
        tableConfig: {
            "tableModel": "modalSingleModel",
            "formConfig": {
                "labelWidth": 120,
                "schemas": [
                    {
                      field: 'code',
                      label: '职务编码',
                      component: 'Input',
                      colProps: { span: 8 },
                    },
                    {
                      field: 'name',
                      label: '职务名称',
                      component: 'Input',
                      colProps: { span: 8 },
                    },
                    {
                      field: 'postRank',
                      label: '职级',
                      component: 'DictSelectTag',
                      componentProps: {
                        dictCode: 'position_rank',
                      },
                      colProps: { span: 8 },
                    },
                ]
            },
            "columns": [
                {
                  title: '职务编码',
                  align: 'center',
                  dataIndex: 'code',
                  width: 200,
                  resizable: true,
                },
                {
                  title: '职务名称',
                  align: 'center',
                  dataIndex: 'name',
                },
                {
                  title: '职级',
                  align: 'center',
                  dataIndex: 'postRank_dictText',
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
                    field: 'code',
                    label: '职务编码',
                    component: 'Input',
                    required: true,
                },
                {
                    field: 'name',
                    label: '职务名称',
                    component: 'Input',
                    required: true,
                },
                {
                    field: 'postRank',
                    label: '职级',
                    component: 'DictSelectTag',
                    componentProps: {
                      dictCode: 'position_rank',
                    },
                    required: true,
                },
            ]
        }
    }
}
