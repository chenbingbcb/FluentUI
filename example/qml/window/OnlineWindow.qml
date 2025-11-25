import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import "../component"

FluWindow {
    id:window
    minimumWidth: 1000
    minimumHeight: 668

    Component.onCompleted: {
        // showMaximized()
    }

    onInitArgument:
        (argument)=>{
            // root.pageConfig = argument.pageConfig
            Object.assign(root, argument)
        }

    FluTableQueryBasic{
        id:root
    }

}
