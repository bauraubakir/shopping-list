import SwiftUI

struct ItemListView: View {
    @EnvironmentObject private var navigation: NavigationCoordinator
    @ObservedObject var mockService: MockDataService
    var onAdd: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Runtime dynamic type size confirmation indicator
                Color.clear
                    .frame(width: 0, height: 0)
                    .accessibilityElement()
                    .accessibilityIdentifier("app_content_size_category")
                    .accessibilityLabel("Стандартный размер текста")
                    .accessibilityValue(UITraitCollection.current.preferredContentSizeCategory.rawValue)

                StarterHero(description: "Добавляйте товары с нужным количеством, отмечайте покупки и переходите в карточку для изменения.")
                
                if mockService.items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.Colors.muted)
                            .padding(.top, 24)
                        
                        Text("Список пуст")
                            .font(.headline)
                            .foregroundStyle(Theme.Colors.foreground)
                            .accessibilityIdentifier("empty_state_title")
                        
                        Text("У вас пока нет добавленных товаров. Нажмите кнопку ниже или «+» на нижней панели.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.Colors.muted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Button {
                            onAdd()
                        } label: {
                            Label("Добавить товар", systemImage: "plus")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.Colors.onPrimary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Theme.Colors.foreground, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(RNPressStyle())
                        .accessibilityIdentifier("empty_state_add_button")
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .modifier(StarterSurface(cornerRadius: 20))
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(mockService.items) { item in
                            HStack(spacing: 12) {
                                // Toggle completion button
                                Button {
                                    mockService.toggleCompletion(for: item)
                                } label: {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24))
                                        .foregroundStyle(item.isCompleted ? Theme.Colors.green : Theme.Colors.muted)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(item.isCompleted ? "Отметить некупленным: \(item.title)" : "Отметить купленным: \(item.title)")
                                .accessibilityIdentifier("item_toggle_\(item.title)")
                                
                                // Tapping row content opens detail
                                NavigationLink(value: AppRoute.detail(item)) {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.title)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(Theme.Colors.foreground)
                                                .strikethrough(item.isCompleted, color: Theme.Colors.muted)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                            
                                            HStack(spacing: 6) {
                                                Text("Кол-во: \(item.quantity) шт.")
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundStyle(Theme.Colors.muted)
                                                
                                                if item.isCompleted {
                                                    Text("• Куплено")
                                                        .font(.system(size: 13, weight: .medium))
                                                        .foregroundStyle(Theme.Colors.green)
                                                        .accessibilityIdentifier("item_badge_completed_\(item.title)")
                                                }
                                            }
                                        }
                                        
                                        Spacer(minLength: 8)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(Theme.Colors.muted.opacity(0.7))
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Карточка товара \(item.title), количество: \(item.quantity)")
                                .accessibilityIdentifier("item_row_\(item.title)")
                                
                                // Delete button directly accessible
                                Button(role: .destructive) {
                                    mockService.deleteItem(id: item.id)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color.red.opacity(0.8))
                                        .padding(8)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Удалить \(item.title)")
                                .accessibilityIdentifier("item_delete_\(item.title)")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .modifier(StarterSurface(cornerRadius: 18))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, Theme.tabBarScrollClearance)
        }
        .accessibilityIdentifier("shopping_list_scroll_view")
        .navigationTitle("Список покупок")
        .background(Theme.Colors.background.ignoresSafeArea())
    }
}
