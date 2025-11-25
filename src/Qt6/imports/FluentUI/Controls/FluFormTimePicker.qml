import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    FluTimePicker {
        id: control
        anchors.fill: parent
        hourFormat: FluTimePickerType.HH
        hourText: ""
        minuteText: ""
        cancelText: qsTr("取消")
        okText: qsTr("确定")

        onAccepted: {
            var whole = Date.fromLocaleString(FluApp.locale, value, "yyyy-MM-dd hh:mm:ss")
            if (whole) { //相当于格式校验
                var date = whole.toLocaleDateString(FluApp.locale, "yyyy-MM-dd")
                var time = current.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
                var split = time.split(":")
                if (split.length < 3) {
                    return
                }
                value = date + " " + split[0] +":" + split[1] +":" + split[2]
            }
        }
    }

    function initDisplay() {
        var whole = Date.fromLocaleString(FluApp.locale, value, "yyyy-MM-dd hh:mm:ss")
        if (whole) { //相当于格式校验
            var time = whole.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
            var split = time.split(":")
            if (split.length < 2) {
                return
            }
            control.hourText = split[0]
            control.minuteText = split[1]
        }
    }
}
