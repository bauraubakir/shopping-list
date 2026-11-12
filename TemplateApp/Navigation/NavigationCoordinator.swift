import SwiftUI

enum AppRoute: Hashable {
    case detail(Item)
    case settings
    case component(ComponentCategory)
}

final class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func reset() {
        path = NavigationPath()
    }
}
