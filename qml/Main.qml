import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * IA Client UI — Main entry point
 * 
 * This is the QML entry point for the IA Client module loaded by Basecamp.
 * It provides a search interface, collection browsing, bookmarking, and download management.
 */
Item {
    id: root
    anchors.fill: parent

    property var backend: logos.module("ia_client_backend")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Search bar
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

            ComboBox {
                id: filterCombo
                Layout.preferredWidth: 120
                model: ["All", "Texts", "Images", "Audio", "Video", "Web"]
                currentIndex: 0
            }
        }

        // Results list
        ListView {
            id: resultsView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: backend ? backend.searchResults : 0

            delegate: ItemDelegate {
                width: resultsView.width
                contentItem: RowLayout {
                    spacing: 12
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 4

                    Label {
                        text: "📄"
                        font.pixelSize: 16
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: modelData.title || modelData.identifier
                            font.bold: true
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }

                        Label {
                            text: modelData.collection ? modelData.collection.join(", ") : ""
                            font.pixelSize: 10
                            opacity: 0.6
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    Button {
                        text: "Bookmark"
                        onClicked: backend.bookmarkCollection(modelData.identifier, modelData.title)
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }
    }

    function performSearch() {
        var filter = filterCombo.currentText.toLowerCase()
        var query = searchField.text
        if (filter !== "all") {
            query = "mediatype:" + filter + " " + query
        }
        backend.search(query, 20)
    }
}
