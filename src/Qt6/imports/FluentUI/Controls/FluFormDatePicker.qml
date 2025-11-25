import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    FluCalendarPicker {
        id: control
        anchors.fill: parent
        onAccepted: {
            value = control.current.toLocaleString(FluApp.locale,"yyyy-MM-dd hh:mm:ss")
        }
    }

    function initDisplay() {
        control.current = Date.fromLocaleString(FluApp.locale, value, "yyyy-MM-dd hh:mm:ss")
    }
}
