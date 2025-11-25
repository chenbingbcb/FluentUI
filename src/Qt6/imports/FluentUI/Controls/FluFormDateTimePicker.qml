import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    RowLayout {
        anchors.fill: parent
        spacing: -1
        FluCalendarPicker{
            id: calendarPicker
            // Layout.fillWidth: true

            onAccepted: {
                var date = calendarPicker.text
                var time = timePicker.current.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
                var split = time.split(":")
                if (split.length < 3) {
                    return
                }
                value = date + " " + split[0] +":" + split[1] +":" + split[2]
            }
        }

        FluTimePicker {
            id: timePicker
            Layout.fillWidth: true
            hourFormat:FluTimePickerType.HH
            hourText: ""
            minuteText: ""
            cancelText: qsTr("取消")
            okText: qsTr("确定")

            onAccepted: {
                var date = calendarPicker.text
                var time = timePicker.current.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
                var split = time.split(":")
                if (split.length < 3) {
                    return
                }
                value = date + " " + split[0] +":" + split[1] +":" + split[2]
            }
        }
    }

    function initDisplay() {
        calendarPicker.current = Date.fromLocaleString(FluApp.locale, value, "yyyy-MM-dd hh:mm:ss")
        if (calendarPicker.current) { //相当于格式校验
            var time = calendarPicker.current.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
            var split = time.split(":")
            if (split.length < 2) {
                return
            }
            timePicker.hourText = split[0]
            timePicker.minuteText = split[1]
        }
    }
}
