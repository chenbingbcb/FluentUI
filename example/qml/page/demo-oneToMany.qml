import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id: root

    Component.onCompleted: {
        loaderTablePane.sourceComponent = comTablePane
    }

    FluLoader {
        id: loaderTablePane
        Layout.fillWidth: true
    }

    Component {
        id: comTablePane
        FluTablePane {
            columnsUrl: "/online/genFormAPI/getColumns/1920671189235699714/0"
            formConfigUrl: "/online/genFormAPI/getFormConfig/1920759948459421697/0"
            listUrl: "/demo/testDemo2/list"
            deleteUrl: "/demo/testDemo2/deleteByParams"
            addUrl: "/demo/testDemo2/add"
            editUrl: "/demo/testDemo2/updateMainSub"
            queryByIdUrl: "/demo/testDemo2/queryByParams"
            updateAllUrl: "/demo/testDemo2/updateAll"
            childTableCustomConfig: [
                {
                    label: "子表1",
                    tableModel: "editAllModel",
                    columnsUrl: "/online/genFormAPI/getColumns/1920671189235622714/fb367426764077dcf94640c843733985",
                    listUrl: "/demo/testDemo2d1/list",
                },
                {
                    label: "子表2",
                    tableModel: "editAllModel",
                    columnsUrl: "/online/genFormAPI/getColumns/1920671189335622714/fb367426764077dcf94640c843733985",
                    listUrl: "/demo/testDemo2d2/list",
                }
            ]
            tableActionDelegate: comCustomAction
            formBelowDelegate: comCustomAction
        }
    }

    Component {
        id: comCustomAction
        FluIconButton {
            iconSource: FluentIcons.Wifi
        }
    }
}
