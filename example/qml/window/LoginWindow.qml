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
    property string loginUrl: "http://10.18.254.51:9999/sys/login"
    property string captchaUrl: "http://10.18.254.51:9999/sys/randomImage/"
    property string getUserPermissionByTokenUrl: "http://10.18.254.51:9999/sys/permission/getUserPermissionByToken"

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

    NetworkCallable{
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
                        showError(qsTr("Login failed: " + result))
                        return
                    }
                }
                settings.username = textbox_uesrname.text

                var token = jsResult.result.token
                Network.get(getUserPermissionByTokenUrl)
                .addHeader("X-Access-Token",token)
                .addQuery("_t",Math.floor(Date.now()/1000))
                .bind(window)
                .go(getUserPermissionByTokenUrlCallable)
            }
    }

    NetworkCallable{
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
                    showError(qsTr("Get captcha failed: " + result))
                    return
                }

                row_captcha.visible = true
                img_captcha.source = jsResult.result
            }
    }

    NetworkCallable{
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
        textbox_password.text = "csqwe123!@#";
        var encrypted = AesEncryptor.encrypt(textbox_password.text);
        console.log("Encrypted:", encrypted);

        Network.postJson(loginUrl)
        .add("captcha",captcha)
        .add("checkKey",Date.now())
        .add("password",encrypted)
        .add("username",textbox_uesrname.text)
        .bind(window)
        .go(loginCallable)
    }

    function procCaptcha() {
        var timestamp = Date.now()
        Network.get(captchaUrl + timestamp)
        .addQuery("_t",Math.floor(timestamp/1000))
        .bind(window)
        .go(captchaCallable)
    }
}
