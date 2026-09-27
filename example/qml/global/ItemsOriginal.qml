pragma Singleton

import QtQuick 2.15
import FluentUI 1.0
import Qt.labs.folderlistmodel

FluObject{
    id:original_items

    property var navigationView
    property var paneItemMenu: null
    property var paneItemModel
    property int paneItemIndex: 0
    property int paneItemIcon: 0

    FolderListModel {
        id: folderModel
        folder: "qrc:/example/qml/page"
        property var urlMap: ({})
        onStatusChanged: {
            if (folderModel.status === FolderListModel.Ready) {
                for (var i = 0; i < folderModel.count; i++) {
                    urlMap[folderModel.get(i, "fileName")] = true //标记已实现的component页面文件
                }
            }
        }
    }

    Component {
        id: com_pane_item
        FluPaneItem {
            title: element.meta.menuTitle || element.meta.title
            menuDelegate: paneItemMenu
            onTap: {
                var wholeUrl = folderModel.folder + "/T_Home.qml"
                if (folderModel.urlMap[url] === true) {
                    wholeUrl = folderModel.folder + "/" + url
                }
                navigationView.push(wholeUrl, {tabTitle: element.meta.title, pageConfig: element})
            }

            Component.onCompleted: {
                icon = element.meta.icon ? FluentIcons.GlobalNavButton + paneItemIcon++ : 0
                url = element.name + ".qml"
            }
        }
    }

    //一级菜单
    Instantiator {
        model: paneItemModel
        delegate: FluLoader {
            property var element: model.modelData
            sourceComponent: {
                if (element.hidden === true) {
                    return
                }

                if(element.children !== undefined) {
                    return com_expander0
                } else {
                    return com_pane_item
                }
            }
        }
        onObjectAdded: (index, object) => {
            if (object.item instanceof FluPaneItemExpander || object.item instanceof FluPaneItem) {
                original_items.children.push(object.item)
            }
        }
    }

    //二级菜单
    Component {
        id: com_expander0
        FluPaneItemExpander {
            id: pane_item_expander0
            title: element.meta.title
            Instantiator {
                model: element.children
                delegate: FluLoader {
                    property var element: model.modelData
                    property var temp_expander0: pane_item_expander0 //下级Component无法识别上级Component的id 所以加个变量过渡
                    sourceComponent: {
                        if (element.hidden === true) {
                            return
                        }

                        if(element.children !== undefined)
                            return com_expander1
                        else
                            return com_pane_item
                    }
                }
                onObjectAdded: (index, object) => {
                    if (object.item instanceof FluPaneItem) {
                        pane_item_expander0.children.push(object.item)
                    }
                }
            }
            Component.onCompleted: {
                icon = element.meta.icon ? FluentIcons.GlobalNavButton + paneItemIcon++ : 0
            }
        }
    }

    //三级菜单目前难搞 先支持到二级并将三级整到二级
    Component {
        id: com_expander1
        Instantiator {
            model: element.children
            property string preTitle: element.meta.title + ">"
            delegate: FluLoader {
                property var element: model.modelData
                sourceComponent: {
                    if (element.hidden === true) {
                        return
                    }

                    element.meta.menuTitle = preTitle + element.meta.title
                    return com_pane_item
                }
            }
            onObjectAdded: (index, object) => {
                if (object.item instanceof FluPaneItem) {
                    temp_expander0.children.push(object.item)
                }
            }
        }
    }

    function rename(item, newName){
        if(newName && newName.trim().length>0){
            item.title = newName;
        }
    }

    function getRecentlyAddedData(){
        var arr = []
        var items = navigationView.getItems();
        for(var i=0;i<items.length;i++){
            var item = items[i]
            if(item instanceof FluPaneItem && item.extra && item.extra.recentlyAdded){
                arr.push(item)
            }
        }
        arr.sort(function(o1,o2){ return o2.extra.order-o1.extra.order })
        return arr
    }

    function getRecentlyUpdatedData(){
        var arr = []
        var items = navigationView.getItems();
        for(var i=0;i<items.length;i++){
            var item = items[i]
            if(item instanceof FluPaneItem && item.extra && item.extra.recentlyUpdated){
                arr.push(item)
            }
        }
        return arr
    }

    function getSearchData(){
        if(!navigationView){
            return
        }
        var arr = []
        var items = navigationView.getItems();
        for(var i=0;i<items.length;i++){
            var item = items[i]
            if(item instanceof FluPaneItem){
                if (item.parent instanceof FluPaneItemExpander)
                {
                    arr.push({title:`${item.parent.title} -> ${item.title}`,key:item.key})
                }
                else
                    arr.push({title:item.title,key:item.key})
            }
        }
        return arr
    }

    function startPageByItem(data){
        navigationView.startPageByItem(data)
    }

}
