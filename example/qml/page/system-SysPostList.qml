import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id: root
    FluTablePane {
        listUrl: '/sys/sysPost/list'
        deleteUrl: '/sys/sysPost/delete'
        addUrl: '/sys/sysPost/add'
        editUrl: '/sys/sysPost/edit'
        queryByIdUrl: '/sys/sysPost/queryById'
        tableTitle: "职称"
        tableConfig: {
            "tableModel": "modalSingleModel",
            "formConfig": {
                "labelWidth": 120,
                "schemas": [
                    {
                      field: 'code',
                      label: '编号',
                      component: 'Input',
                      colProps: { span: 4 },
                    },
                    {
                      field: 'name',
                      label: '名称',
                      component: 'Input',
                      colProps: { span: 8 },
                    },
                    {
                      field: 'member',
                      label: '成员',
                      component: 'SelectMultiUser',
                      colProps: { span: 8 },
                    },
                ]
            },
            "columns": [
                {
                  title: '编号',
                  align: 'center',
                  dataIndex: 'code',
                  width: 200,
                  resizable: true,
                },
                {
                  title: '名称',
                  align: 'center',
                  dataIndex: 'name',
                },
                {
                  title: '成员',
                  align: 'center',
                  dataIndex: 'member_dictText',
                },
                {
                  title: '备注',
                  align: 'center',
                  dataIndex: 'remark',
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
                  label: '编号',
                  component: 'Input',
                  required: true,
                },
                {
                  field: 'name',
                  label: '名称',
                  component: 'Input',
                  required: true,
                },
                {
                  field: 'member',
                  label: '成员',
                  component: 'SelectMultiUser',
                  required: true,
                },
                {
                  field: 'remark',
                  label: '备注',
                  component: 'Input',
                },
            ]
        }
    }
}
