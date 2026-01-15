import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFormControl {
    property var valueFormat: {
        if (config && config.componentProps && config.componentProps.valueFormat) {
            return config.componentProps.valueFormat.replace("YYYY", "yyyy").replace("DD", "dd")
        }
        return "yyyy-MM-dd hh:mm:ss"
    }

    FluTimePicker {
        id: timePicker
        anchors.fill: parent
        hourFormat: FluTimePickerType.HH
        hourText: ""
        minuteText: ""
        secondText: ""
        cancelText: qsTr("取消")
        okText: qsTr("确定")

        onAccepted: {
            //主动操作pick则用pick值 没pick则用value
            var dateTime = Date.fromLocaleString(FluApp.locale, value, valueFormat)
            if (!dateTime.getTime()) {
                dateTime = new Date()
            }
            var date = dateTime.toLocaleDateString(FluApp.locale, "yyyy-MM-dd")

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
            timePicker.hourText = dateTime.getHours().toString().padStart(2, '0')
            timePicker.minuteText = dateTime.getMinutes().toString().padStart(2, '0')
            timePicker.secondText = dateTime.getSeconds().toString().padStart(2, '0')
        }
    }
}
