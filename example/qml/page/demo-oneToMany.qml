import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id:root

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
            getColumnsUrl: "/online/genFormAPI/getColumns/1920671189235699714/0"
            getFormConfigUrl: "/online/genFormAPI/getFormConfig/1920759948459421697/0"
            getTableDataUrl: "/demo/testDemo2/list"
            getDataByParamsUrl: "/demo/testDemo2/queryByParams"
            delDataByParamsUrl: "/demo/testDemo2/deleteByParams"
            addFormDataUrl: "/demo/testDemo2/add"
            updateFormDataUrl: "/demo/testDemo2/updateMainSub"
            updateAllUrl: "/demo/testDemo2/updateAll"
            childTableCustomConfig: [
                {
                    getColumnsUrl: "/online/genFormAPI/getColumns/1920671189235622714/fb367426764077dcf94640c843733985"
                    , getTableDataUrl: "/demo/testDemo2d1/list"
                    , tableModel: "editAllModel"
                    , label: "子表1"
                }
                , {
                    getColumnsUrl: "/online/genFormAPI/getColumns/1920671189335622714/fb367426764077dcf94640c843733985"
                    , getTableDataUrl: "/demo/testDemo2d2/list"
                    , tableModel: "editAllModel"
                    , label: "子表2"
                }
            ]
            rowCustomActionListener: rowCustomAction
            tableCustomActionListener: tableCustomAction
            customAfterFormListener: customAfterForm
        }
    }

    Component {
        id: comCustomAction
        FluIconButton {
            iconSource: FluentIcons.Wifi
        }
    }

    // table自定义操作回调 开口暴露给应用层自定义
    function tableCustomAction(loaderTableCustomAction) {
        loaderTableCustomAction.sourceComponent = comCustomAction
    }

    // row自定义操作回调 开口暴露给应用层自定义
    function rowCustomAction(row, loaderRowCustomAction) {
        loaderRowCustomAction.sourceComponent = comCustomAction
    }

    // 表单后面自定义组件回调 开口暴露给应用层自定义
    function customAfterForm(loaderCustomAfterForm) {
        loaderCustomAfterForm.sourceComponent = comCustomAction
    }
}
