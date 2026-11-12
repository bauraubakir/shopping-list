import SwiftUI

struct ItemDetailView: View {
    let item: Item
    @ObservedObject var mockService: MockDataService
    @EnvironmentObject private var navigation: NavigationCoordinator
    @Environment(\.dismiss) private var dismiss
    
    @State private var draftTitle: String = ""
    @State private var draftQuantity: Int = 1
    @State private var hasAttemptedSave = false
    @State private var showDeleteConfirmation = false
    @FocusState private var isTitleFocused: Bool
    
    private var currentItem: Item {
        mockService.items.first(where: { $0.id == item.id }) ?? item
    }
    
    private var trimmedDraftTitle: String {
        draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isValid: Bool {
        !trimmedDraftTitle.isEmpty
    }
    
    private var hasChanges: Bool {
        trimmedDraftTitle != currentItem.title || draftQuantity != currentItem.quantity
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Status card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: currentItem.isCompleted ? "checkmark.seal.fill" : "circle.dashed")
                            .font(.system(size: 22))
                            .foregroundStyle(currentItem.isCompleted ? Theme.Colors.green : .orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currentItem.isCompleted ? "Товар куплен" : "В списке покупок")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Theme.Colors.foreground)
                            
                            Text(currentItem.isCompleted ? "Можно вернуть в активный список" : "Нажмите, чтобы отметить купленным")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.Colors.muted)
                        }
                        
                        Spacer()
                        
                        Button {
                            mockService.toggleCompletion(for: currentItem)
                        } label: {
                            Text(currentItem.isCompleted ? "Вернуть" : "Куплено")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(currentItem.isCompleted ? Theme.Colors.foreground : Theme.Colors.onPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(currentItem.isCompleted ? Theme.Colors.surface : Theme.Colors.green, in: RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    if currentItem.isCompleted {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Theme.Colors.border, lineWidth: 1)
                                    }
                                }
                        }
                        .buttonStyle(RNPressStyle())
                        .accessibilityIdentifier("detail_status_toggle_button")
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(StarterSurface())
                
                // Edit details card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Параметры товара")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.Colors.muted)
                    
                    // Title editor
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Название")
                                .font(.subheadline)
                                .foregroundStyle(Theme.Colors.muted)
                            
                            if hasAttemptedSave && !isValid {
                                Spacer()
                                Text("Не может быть пустым")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        
                        TextField("Название товара", text: $draftTitle)
                            .focused($isTitleFocused)
                            .modifier(StarterInput(focused: isTitleFocused))
                            .accessibilityIdentifier("detail_title_input")
                        
                        if hasAttemptedSave && !isValid {
                            Text("Пожалуйста, укажите непустое название.")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    // Quantity editor
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Количество")
                            .font(.subheadline)
                            .foregroundStyle(Theme.Colors.muted)
                        
                        HStack {
                            Text("\(draftQuantity) шт.")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Theme.Colors.foreground)
                            
                            Spacer()
                            
                            Stepper("Количество", value: $draftQuantity, in: 1...999)
                                .labelsHidden()
                                .accessibilityIdentifier("detail_quantity_stepper")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Theme.Colors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Theme.Colors.border, lineWidth: 1)
                        }
                        
                        // Presets
                        HStack(spacing: 8) {
                            ForEach([1, 2, 3, 5, 10], id: \.self) { count in
                                Button {
                                    draftQuantity = count
                                } label: {
                                    Text("\(count)")
                                        .font(.subheadline.weight(draftQuantity == count ? .bold : .regular))
                                        .foregroundStyle(draftQuantity == count ? Theme.Colors.onPrimary : Theme.Colors.foreground)
                                        .frame(maxWidth: .infinity, minHeight: 34)
                                        .background(draftQuantity == count ? Theme.Colors.foreground : Theme.Colors.surface, in: RoundedRectangle(cornerRadius: 8))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 8)
                                                .strokeBorder(Theme.Colors.border, lineWidth: 1)
                                        }
                                }
                                .buttonStyle(RNPressStyle())
                                .accessibilityIdentifier("detail_preset_\(count)")
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    // Save and Revert buttons
                    HStack(spacing: 12) {
                        Button {
                            revertChanges()
                        } label: {
                            Text("Сбросить")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.Colors.foreground)
                                .frame(maxWidth: .infinity, minHeight: 46)
                                .background(Theme.Colors.surface, in: RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Theme.Colors.border, lineWidth: 1)
                                }
                        }
                        .buttonStyle(RNPressStyle())
                        .disabled(!hasChanges)
                        .opacity(hasChanges ? 1 : 0.5)
                        .accessibilityIdentifier("detail_revert_button")
                        
                        Button {
                            saveChanges()
                        } label: {
                            Text("Сохранить")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.Colors.onPrimary)
                                .frame(maxWidth: .infinity, minHeight: 46)
                                .background(hasChanges && isValid ? Theme.Colors.accent : Theme.Colors.muted.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(RNPressStyle())
                        .disabled(!hasChanges || !isValid)
                        .accessibilityIdentifier("detail_save_button")
                    }
                    .padding(.top, 8)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(StarterSurface())
                
                // Delete button
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Удалить товар из списка")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Theme.Colors.surface, in: RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.red.opacity(0.25), lineWidth: 1)
                    }
                }
                .buttonStyle(RNPressStyle())
                .accessibilityIdentifier("detail_delete_button")
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, Theme.tabBarScrollClearance)
        }
        .navigationTitle(currentItem.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.Colors.background.ignoresSafeArea())
        .onAppear {
            draftTitle = currentItem.title
            draftQuantity = currentItem.quantity
        }
        .confirmationDialog("Удалить этот товар?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Удалить", role: .destructive) {
                mockService.deleteItem(id: currentItem.id)
                dismiss()
                navigation.pop()
            }
            .accessibilityIdentifier("detail_confirm_delete_button")
            Button("Отмена", role: .cancel) {}
        }
    }
    
    private func saveChanges() {
        hasAttemptedSave = true
        guard isValid else { return }
        mockService.updateItem(id: currentItem.id, title: trimmedDraftTitle, quantity: draftQuantity)
        isTitleFocused = false
        dismiss()
        navigation.pop()
    }
    
    private func revertChanges() {
        draftTitle = currentItem.title
        draftQuantity = currentItem.quantity
        hasAttemptedSave = false
        isTitleFocused = false
    }
}
