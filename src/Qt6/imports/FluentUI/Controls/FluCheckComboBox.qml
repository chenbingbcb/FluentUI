// FluCheckComboBox.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FluentUI

FluFrame {
    id: control
    implicitWidth: 300
    height: 32

    // 公共属性
    property var model: []
    property string placeholder: qsTr("")
    property var selectedItems: []
    property bool popupVisible: false
    property var listUrl: qsTr("")
    property var valField: qsTr("")
    property var txtField: qsTr("")
    property bool listMore: false
    property int listPageNo: 1

    // 内部属性
    property var filteredModel: []
    property string searchText: qsTr("")
    property string displayText: calculateDisplayText()

    // 信号
    signal selectionChanged()
    signal moreButtonClicked()

    // 初始化
    Component.onCompleted: {
        filteredModel = model
    }

    // 输入框显示
    Flickable {
        id: scroll
        clip: true
        anchors.fill: parent
        anchors.rightMargin: 30
        ScrollBar.vertical: srcollBar
        boundsBehavior: Flickable.StopAtBounds
        TextArea.flickable: FluMultilineTextBox {
            id: textBox
            text: control.displayText
            placeholderText: control.placeholder
            readOnly: true
            wrapMode: Text.WrapAnywhere
            activeFocusOnPress: false
            verticalAlignment: TextInput.AlignVCenter
            rightPadding: 12
        }
    }

    FluScrollBar {
        id: srcollBar
        policy: scroll.contentHeight > scroll.height + 2 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        anchors{
            right: scroll.right
            rightMargin: 1
            top: scroll.top
            bottom: scroll.bottom
            topMargin: 3
            bottomMargin: 3
        }
    }

    // 下拉按钮
    FluIconButton {
        width: 30
        height: parent.height
        anchors.right: parent.right
        iconSource: FluentIcons.ChevronDown
        iconSize: 15
        onClicked: popup.visible ? popup.close() : popup.open()
    }

    // 下拉菜单
    FluPopup {
        id: popup
        parent: control
        modal: false
        closePolicy: Popup.CloseOnPressOutsideParent
        width: control.width
        height: Math.min(300, listView.contentHeight + searchBox.height + 20)
        y: control.y + control.height + 2

        contentItem: ColumnLayout {
            // spacing: 10

            Item{
                implicitWidth: control.width
                height: 32

                // More按钮
                FluButton {
                    // parent: listMore ? parent : null
                    width: 60
                    height: 32//parent.height
                    text: qsTr("More...")
                    onClicked: {
                        moreButtonClicked()
                    }
                }

                // 搜索框
                FluTextBox {
                    id: searchBox
                    anchors.right: parent.right
                    width: listMore ? parent.width - 60 : parent.width
                    height: parent.height
                    rightPadding: 30
                    placeholderText: qsTr("搜索...")
                    onTextChanged: {
                        searchText = text
                        filterModel()
                    }
                }
            }

            // 列表视图
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: filteredModel
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AlwaysOn
                                    }
                delegate: ItemDelegate {
                    width: listView.width
                    height: 32
                    leftPadding: 10

                    contentItem: RowLayout {
                        spacing: 10

                        FluCheckBox {
                            id: checkBox
                            checked: isSelected(modelData)
                            onClicked: toggleSelection(modelData)
                        }

                        FluText {
                            text: modelData.text || modelData
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }

        onOpened: {
            filterModel()
            popupVisible = true
        }
        onClosed: popupVisible = false
    }

    // 方法：计算显示文本
    function calculateDisplayText() {
        if (selectedItems.length === 0) return ""
        return selectedItems.map(function(item) {
            return item.text || item
        }).join(", ")
    }

    // 方法：过滤模型
    function filterModel() {
        if (!model) return
        if (searchText === "") {
            filteredModel = model
            return
        }

        filteredModel = model.filter(function(item) {
            const itemText = item.text || item.toString()
            return itemText.toLowerCase().includes(searchText.toLowerCase())
        })
    }

    // 方法：检查是否选中
    function isSelected(item) {
        return selectedItems.some(function(selected) {
            return JSON.stringify(selected) === JSON.stringify(item)
        })
    }

    // 方法：切换选择状态
    function toggleSelection(item) {
        if (isSelected(item)) {
            selectedItems = selectedItems.filter(function(selected) {
                return JSON.stringify(selected) !== JSON.stringify(item)
            })
        } else {
            selectedItems.push(item)
        }
        selectedItems = selectedItems
        selectionChanged()
    }

    // 方法：设置值列表
    function setValues(values) {
        model = values
        filteredModel = model
    }

    // 方法：添加值
    function pushBackValue(value) {
        model.push(value)
        filteredModel = model
    }

    // 方法：清空值
    function clearValues() {
        model = []
        filteredModel = []
        selectedItems = []
    }

    // 方法：获取选中文本
    function getText() {
        return displayText
    }

    function update() {
        if (popup.visible) {
            popup.close()
            popup.open()
        }
    }
}
