#ifndef IA_CLIENT_BACKEND_INTERFACE_H
#define IA_CLIENT_BACKEND_INTERFACE_H

#include <QObject>
#include <QString>
#include "interface.h"

/**
 * @brief Interface for the IA Client backend plugin
 *
 * The IA Client backend inherits from IaBackendReplica (Qt Remote Objects)
 * and provides searchResultsReady signal for QML binding.
 */
class IaClientBackendInterface : public PluginInterface
{
public:
    virtual ~IaClientBackendInterface() = default;
};

#define IaClientBackendInterface_iid "org.logos.IaClientBackend"
Q_DECLARE_INTERFACE(IaClientBackendInterface, IaClientBackendInterface_iid)

#endif // IA_CLIENT_BACKEND_INTERFACE_H
