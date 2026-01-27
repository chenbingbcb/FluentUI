import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id:root
    property string tableId: ""
    property string formId: ""
    property string menuId: ""

    onPageConfigChanged: {
        var paths = pageConfig.path.split("/")
        if (paths && paths.length > 1) {
            formId = paths[paths.length - 1]
            tableId = paths[paths.length - 2]
        }
        menuId = pageConfig.meta.menuId || pageConfig.id
        loaderTablePane.sourceComponent = comTablePane
    }

    FluLoader {
        id: loaderTablePane
        Layout.fillWidth: true
    }

    Component {
        id: comTablePane
        FluTablePane {
            tableId: root.tableId
            formId: root.formId
            menuId: root.menuId
            childTableCustomConfig: [
                {
                    tableModel: "editAllModel"
                }
                , {
                    tableModel: "editAllModel"
                }
            ]
        }
    }
}
