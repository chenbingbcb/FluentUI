# FluentUI 仓库目录（概览）

```
FluentUI/
├── 3rdparty/ 第三方开源库
├── doc/
│   └── md/
│       ├── all_components.md
│       └── directory_tree.md
├── example/ 应用层
│   ├── qml/
│   │   ├── page/
│   │   │   ├── online-onlineList.qml
│   │   │   └── ... (其他 QML 页面)
│   │   └── window/
│   │       ├── OnlineFormWindow.qml
│   │       └── ... (其他 QML 窗口)
│   └── src/ c++代码
└── src/ 组件层
    ├── Qt6/
    │   └── imports/
    │       └── FluentUI/
    │           ├── Controls/
    │           │   ├── FluApp.qml
    │           │   └── ... (其他 QML 组件)
    │           └── ... (其他模块/资源)
    ├── FluApp.cpp
    └── ... (其他c++代码)

```