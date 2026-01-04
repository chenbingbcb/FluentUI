# 基础组件

|Catalog|Detail|Notes / Demos|
|:----:|:----:|:----:|
|FluApp|The initial entry of the program|Router supported(SPA)|
|FluWindow|Frameless Window|*This only works on windows|
|FluAppBar|Title bar on top of the window|Drag, minimize, maximize and close are supported.|
|FluText|Common text||
|FluButton|Common button|![btn](../preview/demo_standardbtn.png) |
|FluFilledButton|Filled button|![filledbtn](../preview/demo_filledbtn.png)|
|FluTextButton|Text button|![textbtn](../preview/demo_textbtn.png)|
|FluToggleButton|Toggle buttons|![togglebtn](../preview/demo_toggle_btn.png)|
|FluIcon|fluent icons|![icons](../preview/demo_icon.png)|
|FluRadioButton|radio button|![radiobtn](../preview/demo_radiobtn.png)|
|FluTextBox|Single-line input box|![textbox](../preview/demo_textbox.png)|
|FluMultiLineTextBox|Multi-lines input area|![textarea](../preview/demo_multiline_textbox.png)|
|FluToggleSwitch|toggle switch|![toggleswitch](../preview/demo_toggle_switch.png)|
|FluSlider|Slider|![slider](../preview/demo_slider.png)|
|FluInfoBar|提示Toast|![infobar](../preview/demo_infobar.png)|
|FluContentDialog| dialog |![dialog](../preview/demo_content_dialog.png)|
|FluProgressBar| progress bar |![progress](../preview/demo_progress_bar_ring.png)|
|FluProgressRing|circle progress||
|FluRectangle|reactangle| ![rect](../preview/demo_rectangle.png)</br>*partially support `round` and `clip` feature|
|FluMenu|menu||
|FluTooltip|tooltip|![tooltip](../preview/demo_tooltip.png)|
|FluTreeView|tree view component|![treeview](../preview/demo_tree_view.png)|
|FluTheme|theme settings|theme color changes, dark mode are supported|
|FluCarousel|-||
|FluTimePicker| time picker ||
|FluDatePicker|date picker||
|FluMenu|the menu popup||
|FluNavigationView|responsive navigation view||
|FluScrollbar|scroll bar||
|FluPagination|||
|FluTableView|table component||
|FluMediaPlayer|multimedia components||
|FluFlipView| flip view||
|其它组件|示例详见https://github.com/zhuzichu520/FluentUI||

# 封装组件

|Catalog|Detail|Notes / Demos|
|:----:|:----:|:----:|
|FluTablePane|列表面板, 包含查询表单, 列表及其action按钮, 页码||
|FluFormPane|表单面板, 包含各种常用的表单控件, 如用户, 部门, 单选下拉, 多选下拉, 单选框, 多选框, 搜索框, 日期, 时间等||
|FluSelectBizDialog|选择对话框, 用户和部门等组件的基类||
|FluCheckComboBox|多选下拉框||
|FluFormControl|以FluFormXxx前缀表示的各类表单控件的基类, 目前表单控件所用的config和value属性由动态FluLoader委托定义, 或者静态实例化时再定义||
|FluFormDatePicker|日期表单控件||
|FluFormDateTimePicker|日期时间表单控件||
|FluFormDictSelectTag|单选下拉表单控件||
|FluFormDictSelectTagRadio|单选框表单控件||
|FluFormInput|文本输入框表单控件||
|FluFormMultiSelectTag|多选下拉表单控件||
|FluFormMultiSelectTagCheckBox|多选框表单控件||
|FluFormSearchSelect|下拉搜索框表单控件||
|FluFormSelectMultiDep|部门表单控件||
|FluFormSelectMultiUser|用户表单控件||
|FluFormSwitch|开关表单控件||
|FluFormTextArea|多行文本框表单控件||
|FluFormTimePicker|时间表单控件||
|FluFormUnsupported|用于暂未支持的表单控件||

# 组件使用说明

- 在线开发页面online-onlineList.qml及其表单窗口OnlineFormWindow.qml也算是一套模板, 其数据可由web后端获取, 配置了默认的url. 而使用该模板自定义开发时也可以自行设置url, 例如常见案例->一对多示例. 还可以对列表配置(即tableConfig属性)和表单配置(即formConfig属性)直接赋值json数据, 无需由web后端获取, 例如系统管理->业务权限.