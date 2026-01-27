import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

Item {
    anchors.fill: parent
    Flickable{
        clip: true
        anchors.fill: parent
        ScrollBar.vertical: srcollBar
        boundsBehavior: Flickable.StopAtBounds
        TextArea.flickable: FluMultilineTextBox {
            id: textBox
            readOnly: false
            wrapMode: Text.WrapAnywhere
            verticalAlignment: TextInput.AlignVCenter
            isCtrlEnterForNewline: true
            Component.onCompleted: {
                forceActiveFocus()
                // selectAll()
            }
            rightPadding: 30
            onTextChanged: {
                value = textBox.text
            }
        }
    }

    FluIconButton{
        iconSource:FluentIcons.ChromeClose
        iconSize: 10
        width: 20
        height: 20
        padding: 0
        verticalPadding: 0
        horizontalPadding: 0
        visible: {
            if(textBox.readOnly)
                return false
            return textBox.text !== ""
        }
        anchors{
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 15
        }
        onClicked:{
            textBox.text = ""
        }
    }

    FluScrollBar{
        id: srcollBar
        anchors{
            right: parent.right
            rightMargin: 3
            top: parent.top
            bottom: parent.bottom
            topMargin: 3
            bottomMargin: 3
        }
    }

    function initDisplay() {
        textBox.text = value
    }
}
