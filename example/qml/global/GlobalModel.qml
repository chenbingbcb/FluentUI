pragma Singleton

import QtQuick 2.15
import FluentUI 1.0

QtObject{

    property int displayMode: FluNavigationViewType.Auto
    property string basicUrl: "http://10.18.254.51:8079/basic-api"
    property string token: ""
}
