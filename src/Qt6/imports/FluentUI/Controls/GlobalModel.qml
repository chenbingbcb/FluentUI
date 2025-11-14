pragma Singleton

import QtQuick
import FluentUI

QtObject{

    property int displayMode: FluNavigationViewType.Auto
    property string basicUrl: "http://10.18.254.51:8079/basic-api"
    property string token: ""
    property var sysAllDictItems: ({}) //所有字典数据
}
