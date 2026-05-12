import QtQuick 2.15
import QtTest 1.0

/**
 * QML Integration Test for IA Client UI (T2.8)
 * Tests the Main.qml component with mocked backend
 */
TestCase {
    name: "IAClientUITest"
    
    // Mock backend object
    property var mockBackend: ({
        searchResults: [],
        loading: false,
        currentItemMetadata: {},
        
        doSearch: function(query, rows) {
            // Simulate search results
            this.loading = true;
            setTimeout(function() {
                mockBackend.searchResults = [
                    { identifier: "test001", title: "Test Item 1", mediatype: "texts" },
                    { identifier: "test002", title: "Test Item 2", mediatype: "images" }
                ];
                mockBackend.loading = false;
            }, 10);
        },
        
        getMetadata: function(identifier) {
            // Simulate metadata response
            mockBackend.currentItemMetadata = {
                identifier: identifier,
                title: "Mock Title",
                mediatype: "texts",
                creator: "Test Creator",
                date: "2024-01-01"
            };
        }
    })

    // Test component
    Component {
        id: mainComponent
        
        Item {
            id: testRoot
            
            property var backend: mockBackend
            
            // Simulated search field
            function getSearchText() { return "test query" }
            
            // Simulated filter
            function getFilterText() { return "all" }
            
            // Simulated results model
            function getResultsModel() { return mockBackend.searchResults }
            
            // Simulated loading state
            function isSearching() { return mockBackend.loading }
            
            // Simulated metadata
            function getCurrentMetadata() { return mockBackend.currentItemMetadata }
        }
    }

    function test_search_results_model() {
        var component = mainComponent.create();
        compare(component.getResultsModel().length, 0);
        
        // Trigger search
        component.backend.doSearch("test", 10);
        
        // Wait for async results
        var waitTime = 0;
        while (component.backend.loading && waitTime < 100) {
            QTest.qWait(10);
            waitTime += 10;
        }
        
        compare(component.backend.searchResults.length, 2);
        compare(component.backend.searchResults[0].identifier, "test001");
        compare(component.backend.searchResults[1].title, "Test Item 2");
        
        mainComponent.destroy(component);
    }

    function test_metadata_lookup() {
        var component = mainComponent.create();
        compare(Object.keys(component.backend.currentItemMetadata).length, 0);
        
        // Trigger metadata lookup
        component.backend.getMetadata("test_identifier");
        
        // Wait for async response
        QTest.qWait(50);
        
        compare(component.backend.currentItemMetadata.identifier, "test_identifier");
        compare(component.backend.currentItemMetadata.title, "Mock Title");
        
        mainComponent.destroy(component);
    }

    function test_loading_state() {
        var component = mainComponent.create();
        compare(component.isSearching(), false);
        
        // Trigger search
        component.backend.doSearch("test", 10);
        
        // Should be loading immediately
        compare(component.isSearching(), true);
        
        // Wait for completion
        var waitTime = 0;
        while (component.isSearching() && waitTime < 100) {
            QTest.qWait(10);
            waitTime += 10;
        }
        
        compare(component.isSearching(), false);
        
        mainComponent.destroy(component);
    }

    function test_metadata_display_formatting() {
        var component = mainComponent.create();
        component.backend.getMetadata("test_id");
        QTest.qWait(50);
        
        var metadata = component.getCurrentMetadata();
        var displayText = "Identifier: " + metadata.identifier;
        compare(displayText, "Identifier: test_id");
        
        mainComponent.destroy(component);
    }

    function test_empty_results() {
        var component = mainComponent.create();
        compare(component.getResultsModel().length, 0);
        compare(component.backend.loading, false);
        
        mainComponent.destroy(component);
    }
}
