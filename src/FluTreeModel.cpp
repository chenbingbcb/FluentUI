#include "FluTreeModel.h"

#include <QMetaEnum>

FluTreeNode::FluTreeNode(QObject *parent) : QObject{parent} {
}

FluTreeModel::FluTreeModel(QObject *parent) : QAbstractTableModel{parent} {
    _dataSourceSize = 0;
}

int FluTreeModel::rowCount(const QModelIndex &parent) const {
    return _rows.count();
}

int FluTreeModel::columnCount(const QModelIndex &parent) const {
    return this->_columnSource.size();
}

QVariant FluTreeModel::data(const QModelIndex &index, int role) const {
    switch (role) {
        case TreeModelRoles::RowModel:
            return QVariant::fromValue(_rows.at(index.row()));
        case TreeModelRoles::ColumnModel:
            return QVariant::fromValue(_columnSource.at(index.column()));
        default:
            break;
    }
    return {};
}

QHash<int, QByteArray> FluTreeModel::roleNames() const {
    return {
        {TreeModelRoles::RowModel,    "rowModel"   },
        {TreeModelRoles::ColumnModel, "columnModel"}
    };
}

void FluTreeModel::setData(QList<FluTreeNode *> data) {
    beginResetModel();
    _rows = std::move(data);
    endResetModel();
}

void FluTreeModel::removeRows(int row, int count) {
    if (row < 0 || row + count > _rows.size() || count == 0)
        return;
    beginRemoveRows(QModelIndex(), row, row + count - 1);
    QList<FluTreeNode *> firstPart = _rows.mid(0, row);
    QList<FluTreeNode *> secondPart = _rows.mid(row + count);
    _rows.clear();
    _rows.append(firstPart);
    _rows.append(secondPart);
    endRemoveRows();
}

void FluTreeModel::insertRows(int row, const QList<FluTreeNode *> &data) {
    if (row < 0 || row > _rows.size() || data.empty())
        return;
    beginInsertRows(QModelIndex(), row, row + data.size() - 1);
    QList<FluTreeNode *> firstPart = _rows.mid(0, row);
    QList<FluTreeNode *> secondPart = _rows.mid(row);
    _rows.clear();
    _rows.append(firstPart);
    _rows.append(data);
    _rows.append(secondPart);
    endInsertRows();
}

QObject *FluTreeModel::getRow(int row) {
    return _rows.at(row);
}

void FluTreeModel::setRow(int row, QVariantMap data) {
    _rows.at(row)->_data = std::move(data);
    Q_EMIT dataChanged(index(row, 0), index(row, columnCount() - 1));
}

void FluTreeModel::checkRow(int row, bool checked, bool checkStrictly) {
    if (checkStrictly) {
        auto itemData = _rows.at(row);
        if (itemData->_checked == checked) {
            return;
        }
        itemData->_checked = checked;
        Q_EMIT dataChanged(index(row, 0), index(row, 0));
        return;
    }
    auto itemData = _rows.at(row);
    if (itemData->hasChildren()) {
        QList<FluTreeNode *> stack = itemData->_children;
        std::reverse(stack.begin(), stack.end());
        while (stack.count() > 0) {
            auto item = stack.at(stack.count() - 1);
            stack.pop_back();
            if (!item->hasChildren()) {
                item->_checked = checked;
            }
            QList<FluTreeNode *> children = item->_children;
            if (!children.isEmpty()) {
                std::reverse(children.begin(), children.end());
                foreach (auto c, children) {
                    stack.append(c);
                }
            }
        }
    } else {
        if (itemData->_checked == checked) {
            return;
        }
        itemData->_checked = checked;
    }
    Q_EMIT dataChanged(index(0, 0), index(rowCount() - 1, 0));
}

void FluTreeModel::setDataSource(QList<QMap<QString, QVariant>> data) {
    bool hasChecked = false;
    _dataSource.clear();
    if (_root) {
        _root->deleteLater();
        _root = nullptr;
    }
    _root = new FluTreeNode(this);
    std::reverse(data.begin(), data.end());
    while (data.count() > 0) {
        auto item = data.at(data.count() - 1);
        data.pop_back();
        auto *node = new FluTreeNode(_root);
        node->_depth = item.value("__depth").toInt();
        node->_parent = item.value("__parent").value<FluTreeNode *>();
        node->_data = item;
        node->_isLeaf = item.value("isLeaf").toBool();
        node->_isExpanded = _defaultExpandAll;
        node->_checkStrictly = _checkStrictly;
        if (node->_parent) {
            node->_parent->_children.append(node);
        } else {
            node->_parent = _root;
            _root->_children.append(node);
        }
        node->_checked = item.value("checked").toBool();
        if (node->_checked) {
            hasChecked = true;
        }
        node->_orderIndex = _dataSource.size();
        _dataSource.append(node);
        if (item.contains("children")) {
            QList<QVariant> children = item.value("children").toList();
            if (!children.isEmpty()) {
                std::reverse(children.begin(), children.end());
                for (int i = 0; i <= children.count() - 1; ++i) {
                    auto child = children.at(i).toMap();
                    child.insert("__depth", item.value("__depth").toInt(nullptr) + 1);
                    child.insert("__parent", QVariant::fromValue(node));
                    data.append(child);
                }
            }
        }
    }
    beginResetModel();
    _rows = _dataSource;
    endResetModel();
    dataSourceSize(_dataSource.size());
    if (hasChecked) {
        Q_EMIT dataChanged(index(0, 0), index(rowCount() - 1, 0));
    }
}

void FluTreeModel::collapse(int row) {
    if (!_rows.at(row)->_isExpanded) {
        return;
    }
    _rows.at(row)->_isExpanded = false;
    Q_EMIT dataChanged(index(row, 0), index(row, 0));
    auto modelData = _rows.at(row);
    int removeCount = 0;
    for (int i = row + 1; i < _rows.count(); i++) {
        auto obj = _rows[i];
        if (obj->_depth <= modelData->_depth) {
            break;
        }
        removeCount = removeCount + 1;
    }
    removeRows(row + 1, removeCount);
}

void FluTreeModel::expand(int row) {
    if (_rows.at(row)->_isExpanded) {
        return;
    }
    _rows.at(row)->_isExpanded = true;
    Q_EMIT dataChanged(index(row, 0), index(row, 0));
    auto modelData = _rows.at(row);
    QList<FluTreeNode *> insertData;
    QList<FluTreeNode *> stack = modelData->_children;
    std::reverse(stack.begin(), stack.end());
    while (stack.count() > 0) {
        auto item = stack.at(stack.count() - 1);
        stack.pop_back();
        if (item->isShown()) {
            insertData.append(item);
        }
        QList<FluTreeNode *> children = item->_children;
        if (!children.isEmpty()) {
            std::reverse(children.begin(), children.end());
            foreach (auto c, children) {
                stack.append(c);
            }
        }
    }
    insertRows(row + 1, insertData);
}

bool FluTreeModel::hitHasChildrenExpanded(int row) {
    auto itemData = _rows.at(row);
    if (itemData->hasChildren() && itemData->_isExpanded) {
        return true;
    }
    return false;
}

void FluTreeModel::refreshNode(int row) {
    Q_EMIT dataChanged(index(row, 0), index(row, 0));
}

FluTreeNode *FluTreeModel::getNode(int row) {
    return _rows.at(row);
}

void FluTreeModel::allExpand() {
    beginResetModel();
    QList<FluTreeNode *> data;
    QList<FluTreeNode *> stack = _root->_children;
    std::reverse(stack.begin(), stack.end());
    while (stack.count() > 0) {
        auto item = stack.at(stack.count() - 1);
        stack.pop_back();
        if (item->hasChildren()) {
            item->_isExpanded = true;
        }
        data.append(item);
        QList<FluTreeNode *> children = item->_children;
        if (!children.isEmpty()) {
            std::reverse(children.begin(), children.end());
            foreach (auto c, children) {
                stack.append(c);
            }
        }
    }
    _rows = data;
    endResetModel();
}

void FluTreeModel::allCollapse() {
    beginResetModel();
    QList<FluTreeNode *> stack = _root->_children;
    std::reverse(stack.begin(), stack.end());
    while (stack.count() > 0) {
        auto item = stack.at(stack.count() - 1);
        stack.pop_back();
        if (item->hasChildren()) {
            item->_isExpanded = false;
        }
        QList<FluTreeNode *> children = item->_children;
        if (!children.isEmpty()) {
            std::reverse(children.begin(), children.end());
            foreach (auto c, children) {
                stack.append(c);
            }
        }
    }
    _rows = _root->_children;
    endResetModel();
}

QVariant FluTreeModel::selectionModel() {
    QList<FluTreeNode *> data;
    foreach (auto item, _dataSource) {
        if (item->checked()) {
            data.append(item);
        }
    }
    return QVariant::fromValue(data);
}

void FluTreeModel::setCheckStrictly(bool checkStrictly) {
    if (_checkStrictly == checkStrictly) {
        return;
    }
    _checkStrictly = checkStrictly;
    for (auto node : _dataSource) {
        node->_checkStrictly = checkStrictly;
    }
    if (_root) {
        _root->_checkStrictly = checkStrictly;
    }
    Q_EMIT dataChanged(index(0, 0), index(rowCount() - 1, 0));
    Q_EMIT checkStrictlyChanged();
}

FluTreeNode *FluTreeModel::findNodeByKey(const QString &key) {
    for (auto *node : _dataSource) {
        if (node->_data.value("_key").toString() == key) {
            return node;
        }
    }
    return nullptr;
}

QStringList FluTreeModel::getCheckedKeys() {
    QStringList keys;
    for (auto *node : _dataSource) {
        if (node->checked()) {
            QString key = node->_data.value("_key").toString();
            if (!key.isEmpty()) {
                keys.append(key);
            }
        }
    }
    return keys;
}

void FluTreeModel::insertChildNodes(const QString &parentKey, QList<QMap<QString, QVariant>> childrenData) {
    FluTreeNode *parent = findNodeByKey(parentKey);
    if (!parent) {
        return;
    }
    if (childrenData.isEmpty()) {
        parent->_isLeaf = true;
        int parentRow = _rows.indexOf(parent);
        if (parentRow >= 0) {
            Q_EMIT dataChanged(index(parentRow, 0), index(parentRow, 0));
        }
        return;
    }

    QList<FluTreeNode *> directChildren;
    int baseDepth = parent->_depth + 1;

    std::reverse(childrenData.begin(), childrenData.end());
    while (childrenData.count() > 0) {
        auto item = childrenData.at(childrenData.count() - 1);
        childrenData.pop_back();

        int depth = item.value("__depth").toInt();
        if (!item.contains("__depth")) {
            depth = baseDepth;
        }

        FluTreeNode *nodeParent = item.value("__parent").value<FluTreeNode *>();
        if (!nodeParent) {
            nodeParent = parent;
        }

        auto *node = new FluTreeNode(this);
        node->_depth = depth;
        node->_parent = nodeParent;
        node->_data = item;
        node->_isLeaf = item.value("isLeaf").toBool();
        node->_isExpanded = _defaultExpandAll;
        node->_checkStrictly = _checkStrictly;
        nodeParent->_children.append(node);
        node->_checked = item.value("checked").toBool();
        node->_orderIndex = _dataSource.size();
        _dataSource.append(node);

        if (nodeParent == parent) {
            directChildren.append(node);
        }

        if (item.contains("children")) {
            QList<QVariant> nested = item.value("children").toList();
            if (!nested.isEmpty()) {
                std::reverse(nested.begin(), nested.end());
                for (int i = 0; i <= nested.count() - 1; ++i) {
                    auto child = nested.at(i).toMap();
                    child.insert("__depth", depth + 1);
                    child.insert("__parent", QVariant::fromValue(node));
                    childrenData.append(child);
                }
            }
        }
    }

    int parentRow = _rows.indexOf(parent);
    if (parentRow >= 0) {
        if (parent->_isExpanded) {
            QList<FluTreeNode *> visibleNodes;
            for (auto *child : directChildren) {
                visibleNodes.append(child);
                if (child->_isExpanded && child->hasChildren()) {
                    QList<FluTreeNode *> stack = child->_children;
                    std::reverse(stack.begin(), stack.end());
                    while (!stack.isEmpty()) {
                        auto *item = stack.takeLast();
                        if (item->isShown()) {
                            visibleNodes.append(item);
                        }
                        if (item->_isExpanded && item->hasChildren()) {
                            QList<FluTreeNode *> sub = item->_children;
                            std::reverse(sub.begin(), sub.end());
                            for (auto *c : sub) {
                                stack.append(c);
                            }
                        }
                    }
                }
            }
            int insertPos = parentRow + 1;
            for (int i = insertPos; i < _rows.size(); i++) {
                if (_rows[i]->_depth <= parent->_depth) {
                    break;
                }
                insertPos = i + 1;
            }
            insertRows(insertPos, visibleNodes);
        } else {
            expand(parentRow);
        }
    }

    dataSourceSize(_dataSource.size());
}