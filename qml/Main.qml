import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * IA Client UI — Main entry point (T2.5-T2.7)
 * 
 * Provides search interface, results list with mediatype icons,
 * pagination controls, and item detail panel.
 */
Item {
    id: root
    anchors.fill: parent

    property var backend: logos.module("ia_client_backend")
    property int currentPage: 0
    property int pageSize: 20
    property string currentQuery: ""
    property string selectedItemIdentifier: ""
    property bool showDetailPanel: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Search bar with filter chips (T2.5)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Search Internet Archive..."
                    focus: true
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            performSearch()
                        }
                    }
                }

                Button {
                    text: "Search"
                    onClicked: performSearch()
                }
            }

            // Filter chips row
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: ["All", "Texts", "Images", "Audio", "Video", "Web"]
                    
                    RadioButton {
                        text: modelData
                        checked: filterGroup.checkedButton === this
                        onClicked: performSearch()
                        
                        indicator: Rectangle {
                            implicitWidth: 16
                            implicitHeight: 16
                            radius: 8
                            color: parent.checked ? "#0078d4" : "transparent"
                            border.color: parent.checked ? "#0078d4" : "#999"
                            
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: parent.checked ? "white" : "transparent"
                                anchors.centerIn: parent
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }
                
                Label {
                    text: filterGroup.checkedButton !== null ? filterGroup.checkedButton.text : ""
                    font.pixelSize: 10
                    opacity: 0.5
                }
            }
        }

        // Status bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Label {
                text: backend && backend.loading ? "⏳ Searching..." : ""
                font.pixelSize: 11
                color: "#666"
                visible: backend && backend.loading
            }
            
            Label {
                text: backend && !backend.loading && backend.searchResults.length > 0 
                    ? `${backend.searchResults.length} results` : ""
                font.pixelSize: 11
                color: "#444"
                visible: backend && !backend.loading && backend.searchResults.length > 0
            }
            
            Label {
                text: backend && !backend.loading && backend.searchResults.length === 0 
                    && currentQuery !== "" ? "No results found" : ""
                font.pixelSize: 11
                color: "#888"
                visible: backend && !backend.loading && backend.searchResults.length === 0 && currentQuery !== ""
            }
            
            Item { Layout.fillWidth: true }
        }

        // Results list (T2.5)
        ListView {
            id: resultsView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: backend && backend.searchResults ? backend.searchResults : []
            
            delegate: ItemDelegate {
                width: resultsView.width
                hoverEnabled: true
                
                contentItem: RowLayout {
                    spacing: 10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 6

                    // Mediatype icon (T2.5)
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 4
                        color: getMediatypeColor(modelData.mediatype || "")
                        
                        Label {
                            text: getMediatypeIcon(modelData.mediatype || "")
                            anchors.centerIn: parent
                            font.pixelSize: 16
                        }
                    }

                    // Title and metadata (T2.5)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Label {
                            text: modelData.title || modelData.identifier || "Untitled"
                            font.bold: true
                            font.pixelSize: 13
                            elide: Text.ElideMiddle
                            color: "#222"
                            Layout.fillWidth: true
                        }

                        // Collection tags (T2.5)
                        Flow {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Repeater {
                                model: modelData.collection ? modelData.collection.split(",") : []
                                
                                Label {
                                    text: "🏷️ " + modelData
                                    font.pixelSize: 9
                                    color: "#666"
                                    background: Rectangle {
                                        color: "#e8e8e8"
                                        radius: 3
                                        implicitWidth: contentWidth + 8
                                        implicitHeight: 14
                                    }
                                }
                            }
                        }

                        Label {
                            text: modelData.description ? truncateText(modelData.description, 100) : ""
                            font.pixelSize: 11
                            opacity: 0.7
                            elide: Text.ElideRight
                            visible: modelData.description
                            Layout.fillWidth: true
                        }

                        Label {
                            text: formatIdentifier(modelData.identifier)
                            font.pixelSize: 9
                            opacity: 0.4
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // View button
                    Button {
                        text: "View"
                        onClicked: showItemDetails(modelData.identifier)
                        
                        background: Rectangle {
                            color: parent.pressed ? "#005a9e" : "#0078d4"
                            radius: 4
                        }
                        contentItem: Label {
                            text: "View"
                            color: "white"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
                
                onMouseClicked: {
                    showItemDetails(modelData.identifier)
                }
            }
            
            ScrollBar.vertical: ScrollBar {}
        }

        // Pagination controls (T2.6)
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Button {
                text: "← Previous"
                enabled: currentPage > 0
                onClicked: {
                    currentPage--
                    performSearch()
                }
                
                background: Rectangle {
                    color: parent.enabled ? "#e8e8e8" : "#f0f0f0"
                    radius: 4
                }
            }
            
            Label {
                text: `Page ${currentPage + 1}`
                font.pixelSize: 12
                Layout.preferredWidth: 80
                horizontalAlignment: Text.AlignHCenter
            }
            
            Button {
                text: "Next →"
                enabled: backend && backend.searchResults.length >= pageSize
                onClicked: {
                    currentPage++
                    performSearch()
                }
                
                background: Rectangle {
                    color: parent.enabled ? "#e8e8e8" : "#f0f0f0"
                    radius: 4
                }
            }
            
            Item { Layout.fillWidth: true }
        }
    }

    // Detail panel (T2.7)
    Rectangle {
        id: detailPanel
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: showDetailPanel ? Math.min(500, root.width * 0.5) : 0
        color: "#f8f8f8"
        opacity: showDetailPanel ? 1.0 : 0.0
        
        Behavior on width { NumberAnimation { duration: 200 } }
        Behavior on opacity { OpacityAnimator { duration: 200 } }
        
        visible: true
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Label {
                    text: "Item Details"
                    font.bold: true
                    font.pixelSize: 16
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "✕"
                    onClicked: root.showDetailPanel = false
                    
                    background: Rectangle {
                        color: "#e0e0e0"
                        radius: 4
                    }
                }
            }
            
            Divider { Layout.fillWidth: true }
            
            // Metadata display
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                TextArea {
                    id: metadataText
                    text: formatMetadataDisplay(backend.currentItemMetadata)
                    readOnly: true
                    wrapMode: Text.Wrap
                    font.pixelSize: 12
                    color: "#333"
                    
                    background: Rectangle {
                        color: "white"
                        border.color: "#ddd"
                        radius: 4
                    }
                }
            }
            
            Divider { Layout.fillWidth: true }
            
            // Download button
            Button {
                text: "⬇ Download Original"
                Layout.fillWidth: true
                enabled: backend.currentItemMetadata && backend.currentItemMetadata.identifier
                
                background: Rectangle {
                    color: parent.enabled ? "#28a745" : "#6c757d"
                    radius: 4
                }
                contentItem: Label {
                    text: "⬇ Download Original"
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    console.log("Download clicked for:", backend.currentItemMetadata.identifier)
                }
            }
        }
    }

    // Helper functions
    function performSearch() {
        var filter = ""
        if (filterGroup.checkedButton !== null) {
            filter = filterGroup.checkedButton.text.toLowerCase()
        }
        
        var query = searchField.text
        if (filter !== "all" && filter !== "") {
            query = "mediatype:" + filter + " " + query
        }
        
        root.currentQuery = query
        root.currentPage = 0
        
        if (backend) {
            backend.doSearch(query, root.pageSize)
        }
    }

    function showItemDetails(identifier) {
        root.selectedItemIdentifier = identifier
        root.showDetailPanel = true
        
        if (backend) {
            backend.getMetadata(identifier)
        }
    }

    function formatIdentifier(id) {
        if (!id) return ""
        return id.length > 60 ? id.substring(0, 57) + "..." : id
    }

    function truncateText(text, maxLength) {
        if (!text || text.length <= maxLength) return text
        return text.substring(0, maxLength - 3) + "..."
    }

    function formatMetadataDisplay(metadata) {
        if (!metadata || Object.keys(metadata).length === 0) {
            return "No metadata available."
        }
        
        var lines = []
        lines.push("Identifier: " + (metadata.identifier || "N/A"))
        lines.push("Title: " + (metadata.title || "N/A"))
        lines.push("Mediatype: " + (metadata.mediatype || "N/A"))
        
        if (metadata.creator) {
            lines.push("Creator: " + metadata.creator)
        }
        if (metadata.description) {
            lines.push("Description: " + truncateText(metadata.description, 200))
        }
        if (metadata.date) {
            lines.push("Date: " + metadata.date)
        }
        if (metadata.subject) {
            lines.push("Subject: " + metadata.subject)
        }
        if (metadata.collection) {
            lines.push("Collection: " + metadata.collection)
        }
        
        return lines.join("\n")
    }

    function getMediatypeIcon(mediatype) {
        switch(mediatype.toLowerCase()) {
            case "texts": return "📄"
            case "images": return "🖼️"
            case "audio": return "🎵"
            case "video": return "🎬"
            case "web": return "🌐"
            default: return "📦"
        }
    }

    function getMediatypeColor(mediatype) {
        switch(mediatype.toLowerCase()) {
            case "texts": return "#e3f2fd"
            case "images": return "#fce4ec"
            case "audio": return "#f3e5f5"
            case "video": return "#fff3e0"
            case "web": return "#e8f5e9"
            default: return "#f5f5f5"
        }
    }

    // Filter group for radio buttons
    ButtonGroup { id: filterGroup }
}
