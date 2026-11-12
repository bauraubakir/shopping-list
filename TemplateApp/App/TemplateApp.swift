import SwiftUI

@main
struct TemplateApp: App {
    @StateObject private var navigation = NavigationCoordinator()
    @AppStorage("appearance") private var appearance = "system"
    
    private var preferredScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigation)
                .preferredColorScheme(preferredScheme)
        }
    }
}
