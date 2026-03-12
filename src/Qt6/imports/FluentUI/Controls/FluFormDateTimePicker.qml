import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

RowLayout {
    anchors.fill: parent
    spacing: -1
    property alias dateText: calendarPicker.text
    property alias currentDate: calendarPicker.current
    property alias hourText: timePicker.hourText
    property alias minuteText: timePicker.minuteText
    property alias secondText: timePicker.secondText
    property alias currentTime: timePicker.current
    property var valueFormat: {
        if (config && config.componentProps && config.componentProps.valueFormat) {
            return config.componentProps.valueFormat.replace("YYYY", "yyyy").replace("DD", "dd")
        }
        return "yyyy-MM-dd hh:mm:ss"
    }

    FluCalendarPicker {
        id: calendarPicker

        onAccepted: {
            //主动操作pick则用pick值 没pick则用value
            var time = "00:00:00"
            if (timePicker.current) {
                time = timePicker.current.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
            } else {
                var dateTime = Date.fromLocaleString(FluApp.locale, value, valueFormat)
                if (dateTime.getTime()) { //用于校验是否有效 因为即便value无效 也会返回一个Date对象
                    time = dateTime.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
                }
            }

            var date = calendarPicker.text
            value = date + " " + time
        }
    }

    FluTimePicker {
        id: timePicker
        Layout.fillWidth: true
        hourFormat:FluTimePickerType.HH
        hourText: ""
        minuteText: ""
        secondText: ""
        cancelText: qsTr("取消")
        okText: qsTr("确定")

        onAccepted: {
            //主动操作pick则用pick值 没pick则用value
            var date = calendarPicker.text
            if (!date) {
                date = new Date().toLocaleDateString(FluApp.locale, "yyyy-MM-dd")
            }

            var time = timePicker.current.toLocaleTimeString(FluApp.locale, "hh:mm:ss")
            value = date + " " + time
        }
    }

    function initDisplay() {
        if (!value) {
            return
        }

        var dateTime = Date.fromLocaleString(FluApp.locale, value, valueFormat)
        if (dateTime.getTime()) { //用于校验是否有效 因为即便value无效 也会返回一个Date对象
            calendarPicker.current = dateTime
            timePicker.hourText = dateTime.getHours().toString().padStart(2, '0')
            timePicker.minuteText = dateTime.getMinutes().toString().padStart(2, '0')
            timePicker.secondText = dateTime.getSeconds().toString().padStart(2, '0')
        }
    }
}
