#include "ia_client_backend.h"
#include "logos_api.h"
#include <QDebug>

IaClientBackendPlugin::IaClientBackendPlugin(QObject* parent)
    : IaBackendReplica()
{
    setParent(parent);
    qDebug() << "IaClientBackendPlugin: Constructor called";
    
    // Connect replica signals to our slots
    connect(this, &IaBackendReplica::searchResultsReady,
            this, &IaClientBackendPlugin::onSearchResultsReady);
    connect(this, &IaBackendReplica::itemMetadataReady,
            this, &IaClientBackendPlugin::onItemMetadataReady);
}

IaClientBackendPlugin::~IaClientBackendPlugin()
{
    qDebug() << "IaClientBackendPlugin: Destructor called";
}

void IaClientBackendPlugin::initLogos(LogosAPI* logosAPIInstance) {
    if (logosAPI) {
        delete logosAPI;
        logosAPI = nullptr;
    }
    if (logos) {
        delete logos;
        logos = nullptr;
    }
    logosAPI = logosAPIInstance;
    if (logosAPI) {
        logos = new LogosModules(logosAPI);
    }
}

void IaClientBackendPlugin::onSearchResultsReady(const QVariantList& results) {
    m_searchResults = results;
    m_loading = false;
    emit loadingChanged(false);
    emit searchResultsChanged(results);
    qDebug() << "IaClientBackendPlugin: Got" << results.size() << "results";
}

void IaClientBackendPlugin::doSearch(const QString& query, int rows) {
    m_loading = true;
    emit loadingChanged(true);
    qDebug() << "IaClientBackendPlugin: Searching for" << query << "rows:" << rows;
    // Call the replica's search slot which forwards to the backend
    search(query.toStdString(), rows);
}

void IaClientBackendPlugin::getMetadata(const QString& identifier) {
    qDebug() << "IaClientBackendPlugin: Getting metadata for" << identifier;
    // Call the replica's getItemMetadata slot
    getItemMetadata(identifier.toStdString());
}

void IaClientBackendPlugin::onItemMetadataReady(const QVariantMap& metadata) {
    m_currentItemMetadata = metadata;
    emit currentItemMetadataChanged(metadata);
    qDebug() << "IaClientBackendPlugin: Got metadata for" 
             << metadata.value("identifier", "unknown").toString();
}
