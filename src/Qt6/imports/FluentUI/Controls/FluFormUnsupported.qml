import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    FluText {
        id: control
        anchors.fill: parent
        enabled: false
        text: qsTr("暂未支持")
        verticalAlignment: Qt.AlignVCenter
    }
}
