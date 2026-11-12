import XCTest
@testable import TemplateApp

final class TemplateAppTests: XCTestCase {
    
    var service: MockDataService!
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "shopping_list_items_v1")
        service = MockDataService()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "shopping_list_items_v1")
        service = nil
        super.tearDown()
    }
    
    func testInitialMockData() {
        XCTAssertFalse(service.items.isEmpty, "Mock service should initialize with default shopping items")
        XCTAssertTrue(service.items.contains { $0.title.contains("Молоко") })
    }
    
    func testAddItemWithQuantity() {
        let initialCount = service.items.count
        service.addItem(title: "Мандарины", quantity: 4, isCompleted: false)
        
        XCTAssertEqual(service.items.count, initialCount + 1)
        XCTAssertEqual(service.items.first?.title, "Мандарины")
        XCTAssertEqual(service.items.first?.quantity, 4)
        XCTAssertEqual(service.items.first?.isCompleted, false)
    }
    
    func testEmptyAndWhitespaceTitleRejected() {
        let countBefore = service.items.count
        service.addItem(title: "", quantity: 1)
        service.addItem(title: "   \n\t  ", quantity: 2)
        
        XCTAssertEqual(service.items.count, countBefore, "Empty or whitespace-only titles must not be added")
    }
    
    func testToggleItemCompletion() {
        guard let firstItem = service.items.first else {
            XCTFail("List should not be empty")
            return
        }
        
        let initialStatus = firstItem.isCompleted
        service.toggleCompletion(for: firstItem)
        XCTAssertEqual(service.items.first?.isCompleted, !initialStatus)
        
        service.toggleCompletion(for: service.items.first!)
        XCTAssertEqual(service.items.first?.isCompleted, initialStatus)
    }
    
    func testUpdateItemTitleAndQuantity() {
        guard let firstItem = service.items.first else {
            XCTFail("List should not be empty")
            return
        }
        
        service.updateItem(id: firstItem.id, title: "Молоко овсяное 1.5%", quantity: 3)
        let updated = service.items.first { $0.id == firstItem.id }
        
        XCTAssertEqual(updated?.title, "Молоко овсяное 1.5%")
        XCTAssertEqual(updated?.quantity, 3)
    }
    
    func testDeleteItem() {
        guard let firstItem = service.items.first else {
            XCTFail("List should not be empty")
            return
        }
        
        let initialCount = service.items.count
        service.deleteItem(id: firstItem.id)
        
        XCTAssertEqual(service.items.count, initialCount - 1)
        XCTAssertFalse(service.items.contains { $0.id == firstItem.id })
    }
    
    func testEmptyListState() {
        for item in service.items {
            service.deleteItem(id: item.id)
        }
        XCTAssertTrue(service.items.isEmpty, "List should be empty when all items are removed")
    }
    
    func testLocalPersistence() {
        service.addItem(title: "Свежая мята", quantity: 2, isCompleted: false)
        
        // Create new service instance to verify reading from storage
        let newService = MockDataService()
        XCTAssertTrue(newService.items.contains { $0.title == "Свежая мята" && $0.quantity == 2 })
    }
}
