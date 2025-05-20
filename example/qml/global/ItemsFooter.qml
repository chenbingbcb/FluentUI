pragma Singleton

import QtQuick 2.15
import FluentUI 1.0

FluObject{

    property var navigationView
    property var paneItemMenu

    id:footer_items

    // FluPaneItemSeparator{}

    // Instantiator{
    //     model:[
    //         {
    //             title:qsTr("About"),
    //             icon:FluentIcons.Contact,
    //             onTapListener:function(){
    //                 FluRouter.navigate("/about")
    //             }
    //         }
    //         ,{
    //             title:qsTr("Settings"),
    //             icon:FluentIcons.Settings,
    //             url:"qrc:/example/qml/page/T_Settings.qml"
    //         }
    //         ,{
    //             title:qsTr("FluentUI Pro"),
    //             icon:FluentIcons.Airplane,
    //             url:"qrc:/example/qml/page/T_FluentPro.qml"
    //         }
    //     ]
    //     delegate:FluPaneItem{
    //         title:modelData.title
    //         menuDelegate: paneItemMenu
    //         icon:modelData.icon
    //         url:modelData.url
    //         onTapListener:modelData.onTapListener
    //         onTap:{
    //             navigationView.push(url)
    //         }
    //     }
    //     onObjectAdded: (index, object) => {
    //         footer_items.children.push(object)
    //     }
    // }

    // FluPaneItem{
    //     title:qsTr("About")
    //     icon:FluentIcons.Contact
    //     onTapListener:function(){
    //         FluRouter.navigate("/about")
    //     }
    // }

    // FluPaneItem{
    //     title:qsTr("Settings")
    //     menuDelegate: paneItemMenu
    //     icon:FluentIcons.Settings
    //     url:"qrc:/example/qml/page/T_Settings.qml"
    //     onTap:{
    //         navigationView.push(url)
    //     }
    // }

    // FluPaneItem{
    //     title:qsTr("FluentUI Pro")
    //     menuDelegate: paneItemMenu
    //     icon: FluentIcons.Airplane
    //     url:"qrc:/example/qml/page/T_FluentPro.qml"
    //     onTap:{
    //         navigationView.push(url)
    //     }
    // }
}
