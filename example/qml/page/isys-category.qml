import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import "../component"

FluScrollablePage {
    id: root
    FluTreePane {
        listUrl: '/sys/sysCategory/list'
        deleteUrl: '/sys/sysCategory/delete'
        addUrl: '/sys/sysCategory/add'
        editUrl: '/sys/sysCategory/edit'
        queryByIdUrl: '/sys/sysCategory/queryById'
        treeTitle: "分类字典"
        treeConfig: {
            "columns": [
                {
                  title: '分类名称',
                  dataIndex: 'name',
                  width: 200*1.5,
                },
                {
                  title: '分类编码',
                  dataIndex: 'code',
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
                  field: 'name',
                  label: '分类名称',
                  component: 'Input',
                  required: true,
                },
                {
                  field: 'pid',
                  label: '父节点',
                  ifShow: false,
                  component: 'Input',
                },
            ]
        }
    }
}
