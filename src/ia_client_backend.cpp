#include "ia_client_backend.h"
#include "logos_api.h"
#include <QDebug>

IaClientBackendPlugin::IaClientBackendPlugin(QObject* parent)
    : IaBackendReplica(parent)
{
    qDebug() << "IaClientBackendPlugin: Constructor called";
    
    // Connect replica signal to our re-emitted signal for QML binding
    connect(this, &IaBackendReplica::searchResultsReady, this, &IaClientBackendPlugin::onSearchResultsReady);
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
    // Re-emit for QML binding
    emit searchResultsReady(results);
}
