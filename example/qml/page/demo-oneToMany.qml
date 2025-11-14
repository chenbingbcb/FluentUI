import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import example 1.0
import "../global"

FluTableQueryBasic{
    getColumnsUrl: "/online/genFormAPI/getColumns/1920671189235699714/0"
    getFormConfigUrl: "/online/genFormAPI/getFormConfig/1920759948459421697/0"
    getTableDataUrl: "/demo/testDemo2/list"
    addFormDataUrl: "/demo/testDemo2/add"
    updateFormDataUrl: "/demo/testDemo2/updateMainSub"
    updateAllUrl: "/demo/testDemo2/updateAll"
    delDataByParamsUrl: "/demo/testDemo2/deleteByParams"
    getDataByParamsUrl: "/demo/testDemo2/queryByParams"

    FluButton{
        text: "Reload Table"
        anchors{
            right: parent.right
            rightMargin: 10
            top: parent.top
            topMargin: 10
        }
        onClicked:{
            tableLoader.reload()
        }
    }
}
