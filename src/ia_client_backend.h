#ifndef IA_CLIENT_BACKEND_H
#define IA_CLIENT_BACKEND_H

#include <string>
using namespace std;  // For repc-generated ia_backend_replica.h (uses 'string' without std::)
#include <QObject>
#include <QString>
#include "interface.h"  // PluginInterface from logos-module
#include "logos_api.h"
#include "logos_sdk.h"  // LogosModules
#include "ia_backend_replica.h"  // From logos-ia module
#include "ia_client_backend_interface.h"  // IaClientBackendInterface

/**
 * @brief IA Client backend plugin — QML-accessible C++ backend for Internet Archive browsing
 *
 * Inherits from IaBackendReplica which connects to the logos-ia IaBackend source.
 * Provides searchResultsReady signal that QML can bind to.
 */
class IaClientBackendPlugin : public IaBackendReplica,
                               public IaClientBackendInterface
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.logos.IaClientBackend" FILE "metadata.json")
    Q_INTERFACES(IaClientBackendInterface)
    
    Q_PROPERTY(QVariantList searchResults READ searchResults NOTIFY searchResultsChanged)
    Q_PROPERTY(bool loading READ isLoading NOTIFY loadingChanged)
    Q_PROPERTY(QVariantMap currentItemMetadata READ currentItemMetadata NOTIFY currentItemMetadataChanged)

public:
    explicit IaClientBackendPlugin(QObject* parent = nullptr);
    ~IaClientBackendPlugin() override;

    QString name() const override { return "ia_client_backend"; }
    QString version() const override { return "0.1.0"; }

    Q_INVOKABLE virtual void initLogos(LogosAPI* logosAPIInstance);
    
    // Property accessors for QML binding
    QVariantList searchResults() const { return m_searchResults; }
    bool isLoading() const { return m_loading; }
    QVariantMap currentItemMetadata() const { return m_currentItemMetadata; }

signals:
    void searchResultsChanged(const QVariantList& results);
    void loadingChanged(bool loading);
    void currentItemMetadataChanged(const QVariantMap& metadata);

private slots:
    void onSearchResultsReady(const QVariantList& results);
    void onItemMetadataReady(const QVariantMap& metadata);
    
    // Trigger search from QML (invokes the replica's search slot)
    Q_INVOKABLE void doSearch(const QString& query, int rows = 20);
    
    // Trigger metadata lookup from QML
    Q_INVOKABLE void getMetadata(const QString& identifier);

private:
    LogosModules* logos = nullptr;
    QVariantList m_searchResults;
    bool m_loading = false;
    QVariantMap m_currentItemMetadata;
};

#endif // IA_CLIENT_BACKEND_H
