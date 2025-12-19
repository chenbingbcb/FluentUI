import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "../global"

FluScrollablePage {
    id:root
    FluTablePane {
        getTableDataUrl: "/sys/sysBusiRule/list"
        getDataByParamsUrl: "/sys/sysBusiRule/queryById"
        delDataByParamsUrl: "/sys/sysBusiRule/delete"
        addFormDataUrl: "/sys/sysBusiRule/add"
        updateFormDataUrl: "/sys/sysBusiRule/edit"
        tableConfig: ({
                          "tableModel": "modalSingleModel",
                          "primaryKey": [
                              "id"
                          ],
                          "useSearchForm": true,
                          "formConfig": {
                              "labelWidth": 120,
                              "schemas": [
                                  {
                                      "field": "userId",
                                      "label": "用户ID",
                                      "component": "SInput",
                                      "componentProps": {
                                          "type": "LIKE"
                                      },
                                      "colProps": {
                                          "span": 8
                                      }
                                  },
                                  {
                                      "field": "busiKey",
                                      "label": "业务key",
                                      "component": "DictSelectTag",
                                      "componentProps": {
                                          "dictCode": "sys_busi_rule"
                                      },
                                      "colProps": {
                                          "span": 8
                                      }
                                  },
                                  {
                                      "field": "busiValue",
                                      "label": "业务值",
                                      "component": "SInput",
                                      "componentProps": {
                                          "type": "LIKE"
                                      },
                                      "colProps": {
                                          "span": 8
                                      }
                                  }
                              ]
                          },
                          "ellipsis": true,
                          "orderConfig": "{}",
                          "showIndexColumn": true,
                          "columns": [
                              {
                                  "title": "用户ID",
                                  "dataIndex": "userId",
                                  "width": 200
                              },
                              {
                                  "title": "业务key",
                                  "dataIndex": "busiKey_dictText",
                                  "width": 200
                              },
                              {
                                  "title": "业务值",
                                  "dataIndex": "busiValue",
                                  "width": 200
                              }
                          ],
                          "showTableSetting": true,
                          "bordered": true,
                          "actionColumn": {
                              "width": 120,
                              "title": "操作",
                              "dataIndex": "action"
                          },
                          "defaultButtons": {
                              "add": {
                                  "visible": true
                              },
                              "edit": {
                                  "visible": true
                              },
                              "delete": {
                                  "visible": true
                              }
                          },
                          "customButtons": {},
                          "rowKey": "id",
                          "rowSelection": {
                              "type": "checkbox"
                          },
                          "showSelectionBar": true
                      })
        formConfig: ({
                         "primaryKey": [
                             "id"
                         ],
                         "defaultButtons": {
                             "add": {
                                 "visible": true
                             },
                             "edit": {
                                 "visible": true
                             },
                             "delete": {
                                 "visible": true
                             }
                         },
                         "customButtons": {},
                         "schemas": [
                             {
                                 "field": "userId",
                                 "label": "用户ID",
                                 "component": "Input",
                                 "colProps": {
                                     "span": 8
                                 },
                                 "componentProps": {}
                             },
                             {
                                 "field": "busiKey",
                                 "label": "业务key",
                                 "component": "DictSelectTag",
                                 "colProps": {
                                     "span": 8
                                 },
                                 "required": true,
                                 "componentProps": {
                                     "dictCode": "sys_busi_rule"
                                 }
                             },
                             {
                                 "field": "busiValue",
                                 "label": "业务值",
                                 "component": "Input",
                                 "colProps": {
                                     "span": 8
                                 },
                                 "required": true,
                                 "componentProps": {}
                             }
                         ]
                     })
    }
}
