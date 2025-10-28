#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QFile>
#include <QJsonValue>
#include <QJSValue>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QByteArray>
#include "stdafx.h"
#include "singleton.h"
#include <openssl/aes.h>
#include <openssl/evp.h>

namespace FluNetworkType {
    Q_NAMESPACE
    enum CacheMode {
        NoCache = 0x0000,
        RequestFailedReadCache = 0x0001,
        IfNoneCacheRequest = 0x0002,
        FirstCacheThenRequest = 0x0004,
    };

    Q_ENUM_NS(CacheMode)

    QML_NAMED_ELEMENT(FluNetworkType)
}

/**
 * @brief The FluNetworkCallable class
 */
class FluNetworkCallable : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(FluNetworkCallable)
public:
    explicit FluNetworkCallable(QObject *parent = nullptr);

    Q_SIGNAL void start();

    Q_SIGNAL void finish();

    Q_SIGNAL void error(int status, QString errorString, QString result);

    Q_SIGNAL void success(QString result);

    Q_SIGNAL void cache(QString result);

    Q_SIGNAL void uploadProgress(qint64 sent, qint64 total);

    Q_SIGNAL void downloadProgress(qint64 recv, qint64 total);
};

/**
 * @brief The FluDownloadParam class
 */
class FluDownloadParam : public QObject {
    Q_OBJECT
public:
    explicit FluDownloadParam(QObject *parent = nullptr);

    FluDownloadParam(QString destPath, bool append, QObject *parent = nullptr);

public:
    QString _destPath;
    bool _append{};
};

/**
 * @brief The FluNetworkParams class
 */
class FluNetworkParams : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(FluNetworkParams)
public:
    enum Method { METHOD_GET, METHOD_HEAD, METHOD_POST, METHOD_PUT, METHOD_PATCH, METHOD_DELETE };
    enum Type { TYPE_NONE, TYPE_FORM, TYPE_JSON, TYPE_JSONARRAY, TYPE_BODY };

    explicit FluNetworkParams(QObject *parent = nullptr);

    FluNetworkParams(QString url, Type type, Method method, QObject *parent = nullptr);

    Q_INVOKABLE FluNetworkParams *addQuery(const QString &key, const QVariant &val);

    Q_INVOKABLE FluNetworkParams *addHeader(const QString &key, const QVariant &val);

    Q_INVOKABLE FluNetworkParams *add(const QString &key, const QVariant &val);

    Q_INVOKABLE FluNetworkParams *addFile(const QString &key, const QVariant &val);

    Q_INVOKABLE FluNetworkParams *setBody(QString val);

    Q_INVOKABLE FluNetworkParams *setTimeout(int val);

    Q_INVOKABLE FluNetworkParams *setRetry(int val);

    Q_INVOKABLE FluNetworkParams *setCacheMode(int val);

    Q_INVOKABLE FluNetworkParams *toDownload(QString destPath, bool append = false);

    Q_INVOKABLE FluNetworkParams *bind(QObject *target);

    Q_INVOKABLE FluNetworkParams *openLog(QVariant val);

    Q_INVOKABLE void go(FluNetworkCallable *result);

    QString buildCacheKey() const;

    QString method2String() const;

    int getTimeout() const;

    int getRetry() const;

    bool getOpenLog() const;

public:
    FluDownloadParam *_downloadParam = nullptr;
    QObject *_target = nullptr;
    Method _method;
    Type _type;
    QString _url;
    QString _body;
    QMap<QString, QVariant> _queryMap;
    QMap<QString, QVariant> _headerMap;
    QMap<QString, QVariant> _paramMap;
    QMap<QString, QVariant> _fileMap;
    int _timeout = -1;
    int _retry = -1;
    QVariant _openLog;
    int _cacheMode = FluNetworkType::CacheMode::NoCache;
};

/**
 * @brief The FluNetwork class
 */
class FluNetwork : public QObject {
    Q_OBJECT
    Q_PROPERTY_AUTO(int, timeout)
    Q_PROPERTY_AUTO(int, retry)
    Q_PROPERTY_AUTO(QString, cacheDir)
    Q_PROPERTY_AUTO(bool, openLog)
    QML_NAMED_ELEMENT(FluNetwork)
    QML_SINGLETON

private:
    explicit FluNetwork(QObject *parent = nullptr);

public:
    SINGLETON(FluNetwork)

    static FluNetwork *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine) {
        return getInstance();
    }

    Q_INVOKABLE FluNetworkParams *get(const QString &url);

    Q_INVOKABLE FluNetworkParams *head(const QString &url);

    Q_INVOKABLE FluNetworkParams *postBody(const QString &url);

    Q_INVOKABLE FluNetworkParams *putBody(const QString &url);

    Q_INVOKABLE FluNetworkParams *patchBody(const QString &url);

    Q_INVOKABLE FluNetworkParams *deleteBody(const QString &url);

    Q_INVOKABLE FluNetworkParams *postForm(const QString &url);

    Q_INVOKABLE FluNetworkParams *putForm(const QString &url);

    Q_INVOKABLE FluNetworkParams *patchForm(const QString &url);

    Q_INVOKABLE FluNetworkParams *deleteForm(const QString &url);

    Q_INVOKABLE FluNetworkParams *postJson(const QString &url);

    Q_INVOKABLE FluNetworkParams *putJson(const QString &url);

    Q_INVOKABLE FluNetworkParams *patchJson(const QString &url);

    Q_INVOKABLE FluNetworkParams *deleteJson(const QString &url);

    Q_INVOKABLE FluNetworkParams *postJsonArray(const QString &url);

    Q_INVOKABLE FluNetworkParams *putJsonArray(const QString &url);

    Q_INVOKABLE FluNetworkParams *patchJsonArray(const QString &url);

    Q_INVOKABLE FluNetworkParams *deleteJsonArray(const QString &url);

    Q_INVOKABLE void setInterceptor(QJSValue interceptor);

    void handle(FluNetworkParams *params, FluNetworkCallable *result);

    void handleDownload(FluNetworkParams *params, FluNetworkCallable *result);

private:
    static void sendRequest(QNetworkAccessManager *manager, QNetworkRequest request,
                            FluNetworkParams *params, QNetworkReply *&reply, bool isFirst,
                            const QPointer<FluNetworkCallable> &callable);

    static void addQueryParam(QUrl *url, const QMap<QString, QVariant> &params);

    static void addHeaders(QNetworkRequest *request, const QMap<QString, QVariant> &headers);

    void saveResponse(const QString &key, const QString &response);

    QString readCache(const QString &key);

    bool cacheExists(const QString &key);

    QString getCacheFilePath(const QString &key);

    static QString headerList2String(const QList<QNetworkReply::RawHeaderPair> &data);

    static void printRequestStartLog(const QNetworkRequest &request, FluNetworkParams *params);

    static void printRequestEndLog(const QNetworkRequest &request, FluNetworkParams *params,
                                   QNetworkReply *&reply, const QString &response);

    static QString map2String(const QMap<QString, QVariant> &map);

public:
    QJSValue _interceptor;
};

/**
 * AES加密
 */
class FluAesEncryptor : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    SINGLETON(FluAesEncryptor)
    QML_NAMED_ELEMENT(FluAesEncryptor)
public:
    explicit FluAesEncryptor(QObject *parent = nullptr) : QObject(parent) {}

    /**
     * 加密方法
     * @param data  要加密的数据
     * @param key 加密key
     * @param iv 加密iv
     * @return 加密的结果
     */
    Q_INVOKABLE QString encrypt(const QString &data, const QString &key, const QString &iv);

    /**
     * 解密方法
     * @param data 要解密的数据
     * @param key  解密key
     * @param iv 解密iv
     * @return 解密的结果
     */
    Q_INVOKABLE QString decrypt(const QString &data, const QString &key, const QString &iv);

    Q_INVOKABLE QString encrypt(const QString &data);

    Q_INVOKABLE QString decrypt(const QString &data);

private:
    //使用AES-128-CBC加密模式，key需要为16位,key和iv可以相同！
    static const QString KEY;
    static const QString IV;
};
