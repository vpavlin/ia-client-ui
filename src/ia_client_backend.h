#ifndef IA_CLIENT_BACKEND_H
#define IA_CLIENT_BACKEND_H

#include <QObject>
#include <QString>
#include "view_plugin_base.h"
#include "logos_api.h"
#include "ia_backend_replica.h"  // From logos-ia module

/**
 * @brief IA Client backend plugin — QML-accessible C++ backend for Internet Archive browsing
 *
 * Inherits from IaBackendReplica which connects to the logos-ia IaBackend source.
 * Provides searchResultsReady signal that QML can bind to.
 */
class IaClientBackendPlugin : public IaBackendReplica,
                               public IaClientBackendInterface,
                               public IaClientBackendViewPluginBase
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.logos.IaClientBackend" FILE "metadata.json")
    Q_INTERFACES(IaClientBackendInterface IaClientBackendViewPluginBase)

public:
    explicit IaClientBackendPlugin(QObject* parent = nullptr);
    ~IaClientBackendPlugin() override;

    QString name() const override { return "ia_client_backend"; }
    QString version() const override { return "0.1.0"; }

    Q_INVOKABLE void initLogos(LogosAPI* logosAPIInstance) override;

signals:
    // Re-emit the replica's searchResultsReady signal for QML binding
    void searchResultsReady(const QVariantList& results);

private slots:
    void onSearchResultsReady(const QVariantList& results);

private:
    LogosModules* logos = nullptr;
};

#endif // IA_CLIENT_BACKEND_H
