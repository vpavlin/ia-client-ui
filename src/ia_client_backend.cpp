#include "ia_client_backend.h"
#include "logos_api.h"
#include "logos_api_client.h"
#include <QDebug>

IaClientBackendPlugin::IaClientBackendPlugin(QObject* parent)
    : QObject(parent)
{
    qDebug() << "IaClientBackendPlugin: Constructor called";
}

IaClientBackendPlugin::~IaClientBackendPlugin()
{
    qDebug() << "IaClientBackendPlugin: Destructor called";
}

void IaClientBackendPlugin::initLogos(LogosAPI* logosAPIInstance) {
    if (logos) {
        delete logos;
        logos = nullptr;
    }
    if (logosAPI) {
        delete logosAPI;
        logosAPI = nullptr;
    }
    logosAPI = logosAPIInstance;
    if (logosAPI) {
        logos = new LogosModules(logosAPI);
    }
}
