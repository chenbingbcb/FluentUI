import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtCore
import FluentUI 1.0
import example 1.0
import "../component"
import "../global"

FluWindow {

    id: window
    title: qsTr("Login")
    width: 400
    height: 400
    fixSize: true
    modality: Qt.ApplicationModal
    property string password: ""
    property string loginUrl: "/sys/login"
    property string captchaUrl: "/sys/randomImage/"
    property string getUserInfoUrl: "/sys/user/getUserInfo"
    property string getUserPermissionByTokenUrl: "/sys/permission/getUserPermissionByToken"

    appBar: FluAppBar {
        title: window.title
        icon: FluApp.windowIcon
        showStayTop: false
        closeClickListener: ()=>{FluRouter.exit(0)}
    }

    onInitArgument:
        (argument)=>{
            // textbox_uesrname.updateText(argument.username)
            textbox_password.focus =  true
        }

    Settings {
        id: settings
        category: "login"
        property string username: ""
    }

    FluNetworkCallable{
        id:loginCallable
        onStart: {
            showLoading()
        }
        onFinish: {
            hideLoading()
        }
        onError:
            (status,errorString,result)=>{
                showError(qsTr(status+";"+errorString+";"+result))
            }
        onCache:
            (result)=>{
                console.debug("onCache: "+result)
            }
        onSuccess:
            (result)=>{
                var jsResult = JSON.parse(result)
                console.debug(JSON.stringify(jsResult, null, 2))
                if (jsResult.code !== 200) {
                    if (jsResult.code === 500 && jsResult.message === "验证码错误") {
                        procCaptcha()
                    } else {
                        showError(qsTr("login failed: " + result))
                        return
                    }
                }

                settings.username = textbox_uesrname.text
                GlobalModel.token = jsResult.result.token

                FluNetwork.get(GlobalModel.basicUrl + getUserInfoUrl)
                .addHeader("S-Token",GlobalModel.token)
                .bind(window)
                .go(getUserInfoUrlCallable)
            }
    }

    FluNetworkCallable{
        id:captchaCallable
        onStart: {
            showLoading()
        }
        onFinish: {
            hideLoading()
        }
        onError:
            (status,errorString,result)=>{
                showError(qsTr(status+";"+errorString+";"+result))
            }
        onSuccess:
            (result)=>{
                var jsResult = JSON.parse(result)
                console.debug(JSON.stringify(jsResult, null, 2))
                if (jsResult.code !== 0) {
                    showError(qsTr("captcha failed: " + result))
                    return
                }

                row_captcha.visible = true
                img_captcha.source = jsResult.result
            }
    }

    FluNetworkCallable{
        id:getUserInfoUrlCallable
        onStart: {
            showLoading()
        }
        onFinish: {
            hideLoading()
        }
        onError:
            (status,errorString,result)=>{
                showError(qsTr(status+";"+errorString+";"+result))
            }
        onSuccess:
            (result)=>{
                var jsResult = JSON.parse(result)
                console.debug(JSON.stringify(jsResult, null, 2))
                if (jsResult.code !== 200 || jsResult.result === null) {
                    showError(qsTr("getUserInfoUrl failed: " + result))
                    return
                }

                GlobalModel.sysAllDictItems = jsResult.result.sysAllDictItems

                FluNetwork.get(GlobalModel.basicUrl + getUserPermissionByTokenUrl)
                .addHeader("S-Token",GlobalModel.token)
                .bind(window)
                .go(getUserPermissionByTokenUrlCallable)
            }
    }

    FluNetworkCallable{
        id:getUserPermissionByTokenUrlCallable
        onStart: {
            showLoading()
        }
        onFinish: {
            hideLoading()
        }
        onError:
            (status,errorString,result)=>{
                showError(qsTr(status+";"+errorString+";"+result))
            }
        onSuccess:
            (result)=>{
                var jsResult = JSON.parse(result)
                console.debug(JSON.stringify(jsResult, null, 2))
                if (jsResult.code !== 200 || jsResult.result === null) {
                    showError(qsTr("getUserPermissionByToken failed: " + result))
                    return
                }

                var menu = jsResult.hasOwnProperty("result") ? jsResult.result.menu : []
                ItemsOriginal.paneItemModel = menu

                FluRouter.navigate("/")
                window.close()
            }
    }

    ColumnLayout{
        anchors{
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        FluTextBox{
            id: textbox_uesrname
            text: settings.username
            // items:[{title:"Admin"},{title:"User"}]
            placeholderText: qsTr("Please enter the account")
            Layout.preferredWidth: 260
            Layout.alignment: Qt.AlignHCenter
        }

        FluTextBox{
            id: textbox_password
            Layout.topMargin: 20
            Layout.preferredWidth: 260
            placeholderText: qsTr("Please enter your password")
            echoMode:TextInput.Password
            Layout.alignment: Qt.AlignHCenter
            onCommit: {
                btnLogin.clicked()
            }
        }

        RowLayout{
            id: row_captcha
            visible : false
            Layout.topMargin: 20
            Layout.preferredWidth: 260
            Layout.alignment: Qt.AlignHCenter
            FluTextBox{
                id:textbox_captcha
                Layout.preferredWidth: 140
                placeholderText: qsTr("captcha")
            }
            FluImage{
                id: img_captcha
                // height: textbox_uesrname.height
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        procCaptcha()
                    }
                }
            }
        }

        FluFilledButton{
            id: btnLogin
            text: qsTr("Login")
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            onClicked:{
                // if(textbox_password.text === ""){
                //     showError(qsTr("Please feel free to enter a password"))
                //     return
                // }
                setResult({password:textbox_password.text})

                procLogin(row_captcha.visible ? textbox_captcha.text : "")
            }
        }
    }

    function procLogin(captcha = "") {
        textbox_password.text = "csqwe123!@#" //写死方便调试
        var encrypted = FluAesEncryptor.encrypt(textbox_password.text)
        console.log("Encrypted:", encrypted)

        FluNetwork.postJson(GlobalModel.basicUrl + loginUrl)
        .add("captcha",captcha)
        .add("checkKey",Date.now())
        .add("password",encrypted)
        .add("username",textbox_uesrname.text)
        .bind(window)
        .go(loginCallable)
    }

    function procCaptcha() {
        var timestamp = Date.now()
        FluNetwork.get(GlobalModel.basicUrl + captchaUrl + timestamp)
        .addQuery("_t",Math.floor(timestamp/1000))
        .bind(window)
        .go(captchaCallable)
    }
}
