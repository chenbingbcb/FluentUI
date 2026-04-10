import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import FluentUI
import QtQuick.Templates as T

T.ComboBox {
    id: control
    textRole: "name" //默认 应用层可改
    valueRole: "id" //默认 应用层可改
    model: ListModel {}
    signal commit(string text)
    property bool disabled: false
    property color normalColor: FluTheme.dark ? Qt.rgba(62/255,62/255,62/255,1) : Qt.rgba(254/255,254/255,254/255,1)
    property color hoverColor: FluTheme.dark ? Qt.rgba(68/255,68/255,68/255,1) : Qt.rgba(251/255,251/255,251/255,1)
    property color disableColor: FluTheme.dark ? Qt.rgba(59/255,59/255,59/255,1) : Qt.rgba(252/255,252/255,252/255,1)
    property alias treeView: treeView

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)
    font: FluTextStyle.Body
    leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    enabled: !disabled

    delegate: FluItemDelegate {
        width: control.popup.width
        text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
        palette.text: control.palette.text
        font: control.font
        palette.highlightedText: control.palette.highlightedText
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
    }

    focusPolicy:Qt.TabFocus
    indicator: FluIcon {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 28
        iconSource:FluentIcons.ChevronDown
        iconSize: 15
        opacity: enabled ? 1 : 0.3
    }
    contentItem: T.TextField {
        id: text_field
        property bool disabled: !control.editable
        leftPadding: !control.mirrored ? 10 : control.editable && activeFocus ? 3 : 1
        rightPadding: control.mirrored ? 10 : control.editable && activeFocus ? 3 : 1
        topPadding: 6 - control.padding
        bottomPadding: 6 - control.padding
        renderType: FluTheme.nativeText ? Text.NativeRendering : Text.QtRendering
        selectionColor: FluTools.withOpacity(FluTheme.primaryColor,0.5)
        selectedTextColor: color
        text: control.editable ? control.editText : control.displayText
        enabled: control.editable
        autoScroll: control.editable
        font:control.font
        readOnly: control.down
        color: {
            if(!control.enabled) {
                return FluTheme.dark ? Qt.rgba(131/255,131/255,131/255,1) : Qt.rgba(160/255,160/255,160/255,1)
            }
            return FluTheme.dark ?  Qt.rgba(255/255,255/255,255/255,1) : Qt.rgba(27/255,27/255,27/255,1)
        }
        inputMethodHints: control.inputMethodHints
        validator: control.validator
        selectByMouse: true
        verticalAlignment: Text.AlignVCenter
        background: FluTextBoxBackground{
            border.width: 1
            bottomMargin: {
                if(!control.editable){
                    return 1
                }
                return contentItem && contentItem.activeFocus ? 2 : 1
            }
            inputItem: contentItem
        }
        Component.onCompleted: {
            forceActiveFocus()
        }
        Keys.onEnterPressed: (event)=> handleCommit(event)
        Keys.onReturnPressed:(event)=> handleCommit(event)
        function handleCommit(event){
            control.commit(control.editText)
            accepted()
        }
    }
    background: Rectangle {
        implicitWidth: 140
        implicitHeight: 32
        border.color: FluTheme.dark ? "#505050" : "#DFDFDF"
        border.width: 1
        visible: !control.flat || control.down
        radius: 4
        FluFocusRectangle{
            visible: control.visualFocus
            radius:4
            anchors.margins: -2
        }
        color:{
            if(!enabled){
                return disableColor
            }
            return hovered ? hoverColor :normalColor
        }
    }
    popup: T.Popup {
        y: control.height
        width: control.width
        height: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin)
        topMargin: 32
        bottomMargin: 6
        modal: true
        contentItem: FluTreeView {
            id: treeView
            showLine: false
            implicitHeight: view.contentHeight
            showHeader: false
            columnSource: [{ title: "Name", dataIndex: control.textRole, align: "left", width: control.width }] //需要设置单列 隐藏表头

            onDataSourceChanged: {
                if (!dataSource || !dataSource.length) {
                    return
                }

                // 递归遍历数据源，将嵌套结构扁平化
                function traverse(nodes) {
                    for (let i = 0; i < nodes.length; i++) {
                        var nodeCopy = {}
                        nodeCopy[control.textRole] = nodes[i][control.textRole]
                        nodeCopy[control.valueRole] = nodes[i][control.valueRole]
                        control.model.append(nodeCopy)

                        if (nodes[i].children && nodes[i].children.length) {
                            traverse(nodes[i].children)
                        }
                    }
                }

                control.model.clear()
                traverse(dataSource)
            }

            onCurrentChanged: {
                if (current) {
                    control.currentIndex = current.orderIndex
                    control.popup.close()
                }
            }
        }
        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from:0
                to:1
                duration: FluTheme.animationEnabled ? 83 : 0
            }
        }
        exit:Transition {
            NumberAnimation {
                property: "opacity"
                from:1
                to:0
                duration: FluTheme.animationEnabled ? 83 : 0
            }
        }
        background:Rectangle{
            radius: 5
            color: FluTheme.dark ? Qt.rgba(43/255,43/255,43/255,1) : Qt.rgba(1,1,1,1)
            border.color: FluTheme.dark ? Qt.rgba(26/255,26/255,26/255,1) : Qt.rgba(191/255,191/255,191/255,1)
            FluShadow{
                radius: 5
            }
        }
    }
}
