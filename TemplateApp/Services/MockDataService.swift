import Foundation

final class MockDataService: ObservableObject {
    @Published var items: [Item] = [] {
        didSet {
            saveItems()
        }
    }
    
    private let storageKey: String
    
    init() {
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            self.storageKey = "shopping_list_items_ui_testing"
            UserDefaults.standard.removeObject(forKey: self.storageKey)
        } else {
            self.storageKey = "shopping_list_items_v1"
        }
        loadItems()
    }
    
    func addItem(title: String, quantity: Int, isCompleted: Bool = false) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        let newItem = Item(title: trimmedTitle, quantity: max(1, quantity), isCompleted: isCompleted)
        items.insert(newItem, at: 0)
    }
    
    func updateItem(id: UUID, title: String, quantity: Int) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].title = trimmedTitle
            items[index].quantity = max(1, quantity)
        }
    }
    
    func toggleCompletion(for item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
        }
    }
    
    func deleteItem(id: UUID) {
        items.removeAll { $0.id == id }
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func resetToMockData() {
        items = Self.defaultMockItems
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            self.items = decoded
        } else {
            self.items = Self.defaultMockItems
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private static var defaultMockItems: [Item] {
        [
            Item(title: "Молоко 3.2%", quantity: 2, isCompleted: false),
            Item(title: "Свежий багет", quantity: 1, isCompleted: false),
            Item(title: "Красные яблоки", quantity: 6, isCompleted: true),
            Item(title: "Зерновой кофе", quantity: 1, isCompleted: false),
            Item(title: "Овсяные хлопья", quantity: 1, isCompleted: false),
            Item(title: "Греческий йогурт", quantity: 4, isCompleted: false),
            Item(title: "Томаты черри", quantity: 2, isCompleted: false),
            Item(title: "Сыр пармезан", quantity: 1, isCompleted: false)
        ]
    }
}
