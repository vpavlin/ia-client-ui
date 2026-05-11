#ifndef IA_CLIENT_BACKEND_H
#define IA_CLIENT_BACKEND_H

#include <QObject>
#include <QString>
#include "ia_client_backend_replica.h"
#include "ia_client_backend_simple_source.h"
#include "view_plugin_base.h"
#include "logos_api.h"

/**
 * @brief IA Client backend plugin — process-isolated C++ backend for QML UI
 */
class IaClientBackendPlugin : public IaClientBackendSimpleSource,
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
    void searchResultsReady(const QVariantList& results);

private:
    LogosModules* logos = nullptr;
};

#endif // IA_CLIENT_BACKEND_H
