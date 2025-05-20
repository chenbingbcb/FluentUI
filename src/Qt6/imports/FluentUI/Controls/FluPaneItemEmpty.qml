import QtQuick
import QtQuick.Controls
import FluentUI

QtObject {
    property string key
    property int _idx
    property var _ext
    property var _parent
    property bool visible: true
    property string title
    Component.onCompleted: {
        key = FluTools.uuid()
    }
}
