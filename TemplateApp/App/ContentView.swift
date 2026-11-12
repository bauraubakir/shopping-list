import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navigation: NavigationCoordinator
    @StateObject private var mockService = MockDataService()
    @State private var selectedTab: AppTab = .list
    @State private var showingAddSheet = false
    @State private var showingSettingsSheet = false
    @AppStorage("appearance") private var appearance = "system"

    private var preferredScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .list:
                        NavigationStack(path: $navigation.path) {
                            ItemListView(
                                mockService: mockService,
                                onAdd: { showingAddSheet = true }
                            )
                            .navigationDestination(for: AppRoute.self) { destination(for: $0) }
                        }
                    case .components:
                        NavigationStack {
                            ComponentCatalogView()
                                .navigationDestination(for: AppRoute.self) { destination(for: $0) }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: Theme.tabBarScrollClearance)
                }

                FrostedTabBar(
                    selectedTab: $selectedTab,
                    onAdd: { showingAddSheet = true },
                    onOpenSettings: { showingSettingsSheet = true },
                    bottomSafeArea: geometry.safeAreaInsets.bottom
                )
            }
        }
        .task {
            if ProcessInfo.processInfo.arguments.contains("--component-catalog") {
                selectedTab = .components
            }
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .background(WindowAppearance(style: appearance.interfaceStyle))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .applyColorScheme(preferredScheme)
        .sheet(isPresented: $showingAddSheet) {
            AddItemSheet(mockService: mockService)
                .applyColorScheme(preferredScheme)
        }
        .sheet(isPresented: $showingSettingsSheet) {
            SettingsView()
                .applyColorScheme(preferredScheme)
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .detail(let item):
            ItemDetailView(item: item, mockService: mockService)
        case .settings:
            SettingsView()
        case .component(let category):
            ComponentExamplesView(category: category)
        }
    }
}

extension View {
    @ViewBuilder
    func applyColorScheme(_ scheme: ColorScheme?) -> some View {
        if let scheme {
            self.preferredColorScheme(scheme)
        } else {
            self
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationCoordinator())
}
