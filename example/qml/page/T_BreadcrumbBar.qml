import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../component"

FluScrollablePage{

    title: qsTr("BreadcrumbBar")

    Component.onCompleted: {
        var items = []
        for(var i=0;i<10;i++){
            items.push({title: qsTr("Item_%1").arg(i+1)})
        }
        breadcrumb_1.items = items
        breadcrumb_2.items = items
    }

    FluFrame{
        Layout.fillWidth: true
        Layout.preferredHeight: 68
        padding: 10

        FluBreadcrumbBar{
            id:breadcrumb_1
            width:parent.width
            anchors.verticalCenter: parent.verticalCenter
            onClickItem:
                (model)=>{
                    showSuccess(model.title)
                }
        }
    }


    FluFrame{
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        padding: 10
        Layout.topMargin: 20

        ColumnLayout{
            anchors.verticalCenter: parent.verticalCenter
            width:parent.width
            spacing: 10

            FluFilledButton{
                text: qsTr("Reset sample")
                onClicked:{
                    var items = []
                    for(var i=0;i<10;i++){
                        items.push({title: qsTr("Item_")+(i+1)})
                    }
                     breadcrumb_2.items = items
                }
            }

            FluBreadcrumbBar{
                id:breadcrumb_2
                separator:">"
                spacing:8
                textSize:18
                Layout.fillWidth: true
                onClickItem:
                    (model)=>{
                        if(model.index+1!==count()){
                            breadcrumb_2.remove(model.index+1,count()-model.index-1)
                        }
                        showSuccess(model.title)
                    }
            }
        }
    }

    CodeExpander{
        Layout.fillWidth: true
        Layout.topMargin: -6
        code:'FluBreadcrumbBar{
    width:parent.width
    separator:">"
    spacing:8
    textSize:18
    onClickItem: (model)=>{

    }
}'
    }


}
