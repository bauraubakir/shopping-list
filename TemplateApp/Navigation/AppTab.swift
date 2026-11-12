import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case list = "list"
    case components = "components"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .list: return "Список"
        case .components: return "Компоненты"
        }
    }
    
    var icon: String {
        switch self {
        case .list: return "cart"
        case .components: return "square.stack.3d.up"
        }
    }
}
