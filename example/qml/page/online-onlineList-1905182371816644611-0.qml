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
            columnsUrl: "/online/genFormAPI/getColumns/1905182371816644611/1977646922356641793"
            listUrl: "/online/genFormAPI/getTableData/1905182371816644611"
            deleteUrl: "/online/genFormAPI/delDataByParams/1905182371816644611"
            addUrl: ""
            editUrl: ""
            queryByIdUrl: ""
            updateAllUrl: ""
            formConfig: ({
                saveFormBtnInvisile: true
            })
        }
    }
}
