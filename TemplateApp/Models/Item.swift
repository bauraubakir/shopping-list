import Foundation

struct Item: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var quantity: Int
    var isCompleted: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, quantity: Int = 1, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.quantity = max(1, quantity)
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
