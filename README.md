# ia-client-ui — IA Client QML UI Module

QML frontend module for the Logos platform providing Internet Archive collection browsing with search, results list, pagination, and item detail panel.

## Features

- **Search Bar**: Text input with Enter key support and filter chips (All/Texts/Images/Audio/Video/Web)
- **Results List**: Mediatype icons, titles, collection tags, descriptions
- **Pagination**: Previous/Next navigation for result sets
- **Detail Panel**: Slide-in panel showing item metadata with download button
- **Loading Indicators**: Visual feedback during search operations

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Main.qml                          │
│  ┌───────────┐ ┌──────────┐ ┌──────────────────┐   │
│  │ Search Bar│ │Results   │ │Detail Panel      │   │
│  │ + Filters │ │ ListView │ │ (metadata)        │   │
│  └───────────┘ └──────────┘ └──────────────────┘   │
│                      ▲                               │
│                      │ logos.module()               │
│              ┌───────┴────────┐                     │
│              │ IaClientBackend│                     │
│              │ (C++ plugin)   │                     │
│              └───────┬────────┘                     │
│                      │ IaBackendReplica             │
│              ┌───────┴────────┐                     │
│              │  logos-ia       │                     │
│              │  (backend)      │                     │
│              └─────────────────┘                     │
└─────────────────────────────────────────────────────┐
```

## Building

```bash
# Build the module library + plugin .so
nix build .#default

# Build LGX bundle for Basecamp loading
nix build .#packages.x86_64-linux.lgx           # Dev variant
nix build .#packages.x86_64-linux.lgx-portable   # Portable variant
```

## LGX Outputs

| Output | Description | Use Case |
|--------|-------------|----------|
| `default` | Module library + plugin .so + headers | Development, dependency |
| `packages.x86_64-linux.lgx` | Dev variant LGX bundle | Loading in Basecamp (dev mode) |
| `packages.x86_64-linux.lgx-portable` | Portable LGX bundle | Distribution/deployment |

## UI Components

### Main.qml

Entry point QML component with:
- Search field with filter chips
- Results ListView with ItemDelegate delegates
- Pagination controls
- Slide-in detail panel

### IaClientBackend (C++)

Backend plugin that:
- Inherits from `IaBackendReplica` (Qt Remote Objects replica)
- Provides `searchResults` and `currentItemMetadata` QProperties
- Exposes `doSearch()` and `getMetadata()` Q_INVOKABLE methods
- Connects replica signals to QML-accessible slots

## IPC Interface

The module communicates with the logos-ia backend via Qt Remote Objects:

```cpp
// ia_backend.rep
class IaBackend {
    SIGNAL(searchResultsReady(QVariantList results))
    SIGNAL(itemMetadataReady(QVariantMap metadata))
    SLOT(QVariantList search(string query, int rows))
    SLOT(QVariantMap getItemMetadata(string identifier))
}
```

## Testing

QML integration test:
```bash
# Run with qmltestrunner (requires Qt test infrastructure)
qmltestrunner -import . tests/test_main.qml
```

Tests mock backend interactions for:
- Search result model population
- Metadata lookup flow
- Loading state transitions

## Module Dependencies

- logos-ia (core backend module)
- Qt 6 (Quick, QuickControls, Network, RemoteObjects)

## License

MIT
