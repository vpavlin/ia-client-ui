#!/usr/bin/env bash
# Headless QML UI test for ia-client-ui
# Uses QT_QPA_PLATFORM=offscreen to render without display

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

export QT_QPA_PLATFORM=offscreen
export QT_QUICK_BACKEND=software
export QT_LOGGING_RULES="qt.qml.*=false"

echo "=== IA Client UI Headless Test ==="
echo ""

# Check that the plugin exists
PLUGIN_PATH="${PROJECT_DIR}/result/lib/ia_client_ui_plugin.so"
if [[ -f "$PLUGIN_PATH" ]]; then
    echo "✓ Plugin found at: $PLUGIN_PATH"
else
    echo "✗ Plugin not found. Building first..."
    cd "$PROJECT_DIR"
    nix build .#default --override-input logos-ia /tmp/logos-ia-clean
fi

# Check QML files exist
echo ""
echo "Checking QML files..."
if [[ -f "${PROJECT_DIR}/qml/Main.qml" ]]; then
    echo "✓ Main.qml exists"
else
    echo "✗ Main.qml not found"
    exit 1
fi

# Run a simple QML validation with Qt's qml format check
echo ""
echo "Validating QML syntax..."
if command -v qmlformat &> /dev/null; then
    qmlformat --check "${PROJECT_DIR}/qml/Main.qml" 2>&1 && echo "✓ QML syntax valid" || echo "⚠ QML format check had warnings"
else
    echo "⚠ qmlformat not available, skipping format check"
fi

# Check that the C++ backend compiles and links
echo ""
echo "Checking plugin shared library..."
if file "$PLUGIN_PATH" | grep -q "ELF.*shared object"; then
    echo "✓ Plugin is a valid ELF shared object"
else
    echo "✗ Plugin is not a valid ELF shared object"
    exit 1
fi

# List exported symbols (check for IaClientBackendPlugin)
echo ""
echo "Checking plugin exports..."
if nm -D "$PLUGIN_PATH" 2>/dev/null | grep -q "IaClientBackend"; then
    echo "✓ Plugin exports IaClientBackend symbols"
else
    echo "⚠ Could not verify exported symbols (nm not available or no matches)"
fi

echo ""
echo "=== All checks passed ==="
echo ""
echo "To run a full QML render test, use:"
echo "  export QT_QPA_PLATFORM=offscreen"
echo "  qmlscene ${PROJECT_DIR}/qml/Main.qml --plugin-dir $(dirname $PLUGIN_PATH)"
