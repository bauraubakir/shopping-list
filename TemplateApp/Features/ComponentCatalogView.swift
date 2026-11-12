import SwiftUI

struct ComponentCatalogView: View {
    private let categories: [ComponentCategory] = [.authentication, .tabbars, .schedule, .week, .dateRange]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("UI KIT")
                        .font(.caption2.weight(.semibold))
                        .tracking(1.1)
                        .foregroundStyle(Theme.Colors.accent)
                    Text("Детали создают впечатление")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Theme.Colors.foreground)
                    Text("Нативные элементы для ваших идей. Выберите раздел, чтобы попробовать их в действии.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.Colors.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                Text("Нативные компоненты")
                    .font(.subheadline)
                    .foregroundStyle(Theme.Colors.muted)
                    .padding(.horizontal, 20)
                    .padding(.bottom, -16)

                VStack(spacing: 10) {
                    ForEach(categories) { category in
                        NavigationLink(value: AppRoute.component(category)) {
                            HStack(alignment: .center, spacing: 14) {
                                Image(systemName: category.symbol)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundStyle(Theme.Colors.accent)
                                    .frame(width: 42, height: 42)
                                    .background(Theme.Colors.accent.opacity(0.10), in: Capsule())
                                    .accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.Colors.foreground)
                                    Text(category.detail).font(.caption).foregroundStyle(Theme.Colors.muted).lineLimit(1)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "arrow.up.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Theme.Colors.muted.opacity(0.6))
                            }
                            .padding(.leading, 13)
                            .padding(.trailing, 28)
                            .frame(minHeight: 68)
                            .background(Theme.Colors.cardBackground, in: Capsule())
                            .overlay(Capsule().strokeBorder(Theme.Colors.border.opacity(0.65)))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("catalog.\(category.rawValue)")
                    }
                }
                .padding(24)
                .modifier(GlassCard())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .padding(.bottom, Theme.tabBarScrollClearance / 2)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.bottom, Theme.tabBarScrollClearance / 2, for: .scrollContent)
        .background(Theme.Colors.background)
        .navigationTitle("Компоненты")
        .tint(Theme.Colors.accent)
    }
}

struct ComponentExamplesView: View {
    let category: ComponentCategory

    var body: some View {
        Group {
            switch category {
            case .lists: CatalogListsView()
            case .input: CatalogInputView()
            case .selection: CatalogSelectionView()
            case .dates: CatalogDatesView()
            case .reminders: CatalogReminderView()
            case .schedule: CatalogScheduleView()
            case .week: CatalogWeekView()
            case .dateRange: CatalogDateRangeView()
            case .tabbars: CatalogTabBarsView()
            case .authentication: CatalogAuthenticationView()
            case .actions: CatalogActionsView()
            case .feedback: CatalogFeedbackView()
            case .presentation: CatalogPresentationView()
            case .layout: CatalogLayoutView()
            case .content: CatalogContentView()
            case .charts: CatalogChartsView()
            case .media: CatalogMediaView()
            }
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.Colors.accent)
        .environment(\.locale, Locale(identifier: "ru_RU"))
    }
}

/// Shared form container for the catalogue, rather than a separate layout for each example.
struct CatalogForm<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        Form(content: content)
            .scrollIndicators(.hidden)
            .contentMargins(.bottom, Theme.tabBarScrollClearance / 2, for: .scrollContent)
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.background)
            .listRowBackground(Theme.Colors.surface)
            .font(.subheadline)
            .scrollDismissesKeyboard(.interactively)
    }
}
