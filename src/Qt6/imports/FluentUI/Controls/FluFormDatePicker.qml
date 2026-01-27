import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluCalendarPicker {
    id: calendarPicker
    anchors.fill: parent
    onAccepted: {
        //主动操作pick则用pick值 没pick则用value
        var dateTime = Date.fromLocaleString(FluApp.locale, value, valueFormat)
        var time = dateTime.getTime() ? dateTime.toLocaleTimeString(FluApp.locale, "hh:mm:ss") : "00:00:00"

        var date = calendarPicker.text
        value = date + " " + time
    }

    property var valueFormat: {
        if (config && config.componentProps && config.componentProps.valueFormat) {
            return config.componentProps.valueFormat.replace("YYYY", "yyyy").replace("DD", "dd")
        }
        return "yyyy-MM-dd hh:mm:ss"
    }

    function initDisplay() {
        if (!value) {
            return
        }

        var dateTime = Date.fromLocaleString(FluApp.locale, value, valueFormat)
        if (dateTime.getTime()) { //用于校验是否有效 因为即便value无效 也会返回一个Date对象
            calendarPicker.current = dateTime
        }
    }
}
