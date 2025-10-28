import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import example 1.0
import "../global"

FluTableQueryBasic{
    id:root

    // tableConfig: { //查询列表配置
    //     formConfig: {} //查询字段配置
    //     columns: [] //列表表头配置
    // }
    // tableData: { //列表数据
    //     records: []
    // }
    // formConfig: { //编辑表单配置
    //     schemas: [] //控件配置
    // }
    // isLocalConfig: false //是否本地配置 默认false 表示配置由web后端提供
    getTableDataListener: getTableDataRequest
    addFormDataListener: addFormDataRequest
    updateFormDataListener: updateFormDataRequest
    updateAllListener: updateAllRequest
    delDataByParamsListener: delDataByParamsRequest
    getDataByParamsListener: getDataByParamsRequest
    getDictItemsListener: getDictItemsRequest
    listUrlListener: listUrlRequest
    sysUserListListener: sysUserListRequest
    sysDepartListListener: sysDepartListRequest

    sysAllDictItems: GlobalModel.sysAllDictItems
    property string getColumnsUrl: "/online/genFormAPI/getColumns/1920671189235699714/0"
    property string getFormConfigUrl: "/online/genFormAPI/getFormConfig/1920759948459421697/0"
    property string getTableDataUrl: "/demo/testDemo2/list"
    property string addFormDataUrl: "/demo/testDemo2/add"
    property string updateFormDataUrl: "/demo/testDemo2/updateMainSub"
    property string updateAllUrl: "/demo/testDemo2/updateAll"
    property string delDataByParamsUrl: "/demo/testDemo2/deleteByParams"
    property string getDataByParamsUrl: "/demo/testDemo2/queryByParams"
    property string getDictItemsUrl: "/sys/dict/getDictItems/"
    property string sysUserListUrl: "/sys/user/list"
    property string sysDepartListUrl: "/sys/sysDepart/list"

    Component.onCompleted: {
        if (isLocalConfig) {
            return
        }
        requestConfig()
    }

    function requestConfig() {
        FluNetwork.get(GlobalModel.basicUrl + getColumnsUrl)
        .addHeader("S-Token", GlobalModel.token)
        .bind(root)
        .go(getColumnsCallable)
    }

    FluNetworkCallable{
        id: getColumnsCallable
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
                    showError(qsTr(getColumnsUrl + " failed: " + result))
                    return
                }

                tableConfig = jsResult.result
                getTableDataRequest()
            }
    }

    function getTableDataRequest() {
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + getTableDataUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("order", "desc")
        .addQuery("column", "createTime")
        .addQuery("pageNo", pageNo)
        .addQuery("pageSize", pageSize)

        for(var key in queryParams) {
            if (queryParams[key].text !== "") {
                networkParams.addQuery(key, queryParams[key].text)
            }
        }

        networkParams.go(getTableDataCallable)
    }

    FluNetworkCallable{
        id: getTableDataCallable
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
                    showError(qsTr(getTableDataUrl + " failed: " + result))
                    return
                }

                tableData = jsResult.result
                getFormConfigRequest()
            }
    }

    function getFormConfigRequest() {
        if (formConfig || (tableModel === "editSingleModel" || tableModel === "editAllModel")) {
            return
        }

        FluNetwork.get(GlobalModel.basicUrl + getFormConfigUrl)
        .addHeader("S-Token", GlobalModel.token)
        .bind(root)
        .go(getFormConfigCallable)
    }

    FluNetworkCallable{
        id: getFormConfigCallable
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
                    showError(qsTr(getFormConfigUrl + " failed: " + result))
                    return
                }

                formConfig = jsResult.result
            }
    }

    function addFormDataRequest(updateObj, noRefresh) {
        var networkParams = FluNetwork.postJson(GlobalModel.basicUrl + addFormDataUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        // .openLog(true)

        for(var key in updateObj) {
            networkParams.add(key, updateObj[key])
        }

        addFormDataCallable.noRefresh = noRefresh
        networkParams.go(addFormDataCallable)
    }

    FluNetworkCallable{
        id: addFormDataCallable
        property var noRefresh
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
                    showError(qsTr(addFormDataUrl + " failed: " + result))
                    return
                }

                if (!noRefresh) {
                    getTableDataRequest()
                }
            }
    }

    function updateFormDataRequest(updateObj, noRefresh) {
        var networkParams = FluNetwork.putJson(GlobalModel.basicUrl + updateFormDataUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        // .openLog(true)

        for(var key in updateObj) {
            networkParams.add(key, updateObj[key])
        }

        updateFormDataCallable.noRefresh = noRefresh
        networkParams.go(updateFormDataCallable)
    }

    FluNetworkCallable{
        id: updateFormDataCallable
        property var noRefresh //默认刷新
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
                    showError(qsTr(updateFormDataUrl + " failed: " + result))
                    return
                }

                if (!noRefresh) {
                    getTableDataRequest()
                }
            }
    }

    function updateAllRequest(updateObj) {
        var networkParams = FluNetwork.putJson(GlobalModel.basicUrl + updateAllUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        // .openLog(true)

        for(var key in updateObj) {
            networkParams.add(key, updateObj[key])
        }

        networkParams.go(updateAllCallable)
    }

    FluNetworkCallable{
        id: updateAllCallable
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
                    showError(qsTr(updateAllUrl + " failed: " + result))
                    return
                }

                getTableDataRequest()
            }
    }

    function delDataByParamsRequest(row) {
        var obj = tableView.getRow(row)
        var networkParams = FluNetwork.deleteJson(GlobalModel.basicUrl + delDataByParamsUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("id", obj.id)
        .go(delDataByParamsCallable)
    }

    FluNetworkCallable{
        id: delDataByParamsCallable
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
                    showError(qsTr(delDataByParamsUrl + " failed: " + result))
                    return
                }

                getTableDataRequest()
            }
    }

    function getDataByParamsRequest(row) {
        var obj = tableView.getRow(row)
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + getDataByParamsUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)
        .addQuery("id", obj.id)
        .go(getDataByParamsCallable)
    }

    FluNetworkCallable{
        id: getDataByParamsCallable
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
                    showError(qsTr(getDataByParamsUrl + " failed: " + result))
                    return
                }

                rowFormData = jsResult.result
            }
    }

    function getDictItemsRequest(dictCode) {
        var callable = comNetworkDictCode.createObject(root, {dictCode: dictCode})
        FluNetwork.get(GlobalModel.basicUrl + getDictItemsUrl + dictCode)
        .addHeader("S-Token",GlobalModel.token)
        .bind(root)
        .go(callable)
    }

    Component {
        id: comNetworkDictCode
        FluNetworkCallable{
            property var dictCode
            onStart: {
                showLoading()
            }
            onFinish: {
                hideLoading()
                FluTools.deleteLater(this)
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
                        showError(qsTr(getDictItemsUrl + " failed: " + result))
                        return
                    }

                    dictItemsUpdated(dictCode, jsResult.result)
                }
        }
    }

    function listUrlRequest(listUrl, fields, pageNo) {
        var callable = comNetworkListUrl.createObject(root, {listUrl: listUrl})
        FluNetwork.get(GlobalModel.basicUrl + listUrl)
        .bind(root)
        .addHeader("S-Token",GlobalModel.token)
        .addQuery("superQueryMatchType", "or")
        .addQuery("field", fields.toString())
        .addQuery("pageNo", pageNo)
        .addQuery("pageSize", 20)
        .go(callable)
    }

    Component {
        id: comNetworkListUrl
        FluNetworkCallable{
            property var listUrl
            onStart: {
                showLoading()
            }
            onFinish: {
                hideLoading()
                FluTools.deleteLater(this)
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
                        showError(qsTr(listUrl + " failed: " + result))
                        return
                    }

                    dictItemsUpdated(listUrl, jsResult.result)
                }
        }
    }

    function sysUserListRequest(control, queryParams, display) {
        var callable = comNetworkSysUserList.createObject(root, {control: control, display: display})
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + sysUserListUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)

        for(var key in queryParams) {
            networkParams.addQuery(key, queryParams[key])
        }

        networkParams.go(callable)
    }

    Component {
        id: comNetworkSysUserList
        FluNetworkCallable{
            property var control
            property var display
            onStart: {
                showLoading()
            }
            onFinish: {
                hideLoading()
                FluTools.deleteLater(this)
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
                        showError(qsTr(sysUserListUrl + " failed: " + result))
                        return
                    }

                    control.sysUserListResp(jsResult.result, display)
                }
        }
    }

    function sysDepartListRequest(control, queryParams, display) {
        var callable = comNetworkSysDepartList.createObject(root, {control: control, display: display})
        var networkParams = FluNetwork.get(GlobalModel.basicUrl + sysDepartListUrl)
        .bind(root)
        .addHeader("S-Token", GlobalModel.token)

        for(var key in queryParams) {
            networkParams.addQuery(key, queryParams[key])
        }

        networkParams.go(callable)
    }

    Component {
        id: comNetworkSysDepartList
        FluNetworkCallable{
            property var control
            property var display
            onStart: {
                showLoading()
            }
            onFinish: {
                hideLoading()
                FluTools.deleteLater(this)
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
                        showError(qsTr(sysDepartListUrl + " failed: " + result))
                        return
                    }

                    control.sysDepartListResp(jsResult.result, display)
                }
        }
    }
}
