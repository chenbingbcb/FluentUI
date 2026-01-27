import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import "../component"

FluWindow {
    id:window
    minimumWidth: 1000
    minimumHeight: 668
    launchMode: FluWindowType.SingleInstance
    property var formPane

    Component.onCompleted: {
        // showMaximized()
    }

    onInitArgument:
        (argument)=>{
            // Object.assign(formPane, argument)
            loaderFormPane.sourceComponent = comFormPane
            formPane = loaderFormPane.item
        }

    FluScrollablePage {
        id: root
        anchors.fill: parent
        Component.onCompleted: {
        }


        FluLoader {
            id: loaderFormPane
            Layout.fillWidth: true
        }

        Component {
            id: comFormPane
            FluFormPane {
                formPaneData: argument.formPaneData
            }
        }
    }
}
