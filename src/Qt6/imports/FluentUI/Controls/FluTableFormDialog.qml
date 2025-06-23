import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import FluentUI

FluPopup {
    id: control
    property string strTitle: ""
    property var formConfig: ({}) //getFormConfig消息配置
    property var schemas: []
    property var tabConfig: ({}) //标签配置
    property var childTableConfig: []

    modal: false
    property var fields: []

    onOpened: {
        for(var i = 0;i<tabButtons.buttons.length;i++){
            var button = tabButtons.buttons[i]
            if(tabConfig.componentProps && tabConfig.componentProps.activeKey === button.contentDescription){
                tabButtons.currentIndex = i
                fields = tabConfig.componentProps.tabPanels[tabButtons.currentIndex].fields
            }
        }
    }

    ColumnLayout{
        id: root
        anchors{
            left: parent.left
            right: parent.right
            top: parent.top
        }

        RowLayout{
            anchors{
                left: parent.left
                right: parent.right
            }

            FluText{
                font: FluTextStyle.Subtitle
                text: strTitle
                leftPadding: 10
            }

            Item {
                Layout.fillWidth: true
            }

            FluIconButton{
                iconSource: FluentIcons.ChromeClose
                iconSize: 15
                text: qsTr("Close")
                display: Button.IconOnly
                onClicked:{
                    control.close()
                }
            }
        }

        FluRadioButtons{
            id: tabButtons
            spacing: 0
            orientation: Qt.Horizontal
            Component.onCompleted: {
                for (var i = 0; i < tabConfig.componentProps.tabPanels.length; i++) {
                    var panel = tabConfig.componentProps.tabPanels[i]
                    var obj = Qt.createQmlObject("import FluentUI; FluToggleButton{}", tabButtons);
                    obj.text = panel.tab;
                    obj.controlBackground.border.width = 0
                    obj.controlBackground.gradient = null
                    obj.contentDescription = panel.key
                    obj.clickListener = function(){
                        for(var i = 0;i<tabButtons.buttons.length;i++){
                            var button = tabButtons.buttons[i]
                            if(this === button){
                                tabButtons.currentIndex = i
                                fields = tabConfig.componentProps.tabPanels[tabButtons.currentIndex].fields
                            }
                        }
                    }
                    tabButtons.buttons.push(obj)
                }
            }
        }

        FluDivider{
            Layout.fillWidth: true
        }

        GridLayout{
            id: tabPanel
            columns: 24
            columnSpacing: 0
            anchors{
                left: parent.left
                right: parent.right
            }

            Repeater {
                model: fields
                delegate: Item {
                    Layout.columnSpan: modelData.colProps.span
                    Layout.preferredWidth: parent.width / (24 / modelData.colProps.span)
                    Layout.alignment: Qt.AlignRight
                    Layout.topMargin: 5
                    Layout.bottomMargin: 5
                    height: label.height
                    property alias textBox: textBoxQueryValue
                    FluText{
                        id: label
                        anchors{
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        text: modelData.label
                        height: 32
                        width: 120
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignRight
                    }

                    FluTextBox {
                        id: textBoxQueryValue
                        anchors{
                            left: label.right
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                            leftMargin: 5
                            rightMargin: 5
                        }
                        placeholderText: qsTr("请输入")
                    }
                }
                onItemAdded: (index, item) => {

                             }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        GridLayout{
            columns: 24
            columnSpacing: 0
            anchors{
                left: parent.left
                right: parent.right
            }

            Repeater {
                model: formConfig.schemas
                delegate: Item {
                    Layout.columnSpan: modelData.colProps.span
                    Layout.preferredWidth: parent.width / (24 / modelData.colProps.span)
                    Layout.alignment: Qt.AlignRight
                    Layout.topMargin: 5
                    Layout.bottomMargin: 5
                    height: label2.height
                    property alias textBox: textBoxQueryValue2
                    FluText{
                        id: label2
                        anchors{
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        text: modelData.label
                        height: 32
                        width: 120
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignRight
                    }

                    FluTextBox {
                        id: textBoxQueryValue2
                        anchors{
                            left: label2.right
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                            leftMargin: 5
                            rightMargin: 5
                        }
                        placeholderText: qsTr("请输入")
                    }
                }
                onItemAdded: (index, item) => {

                             }
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }
}
