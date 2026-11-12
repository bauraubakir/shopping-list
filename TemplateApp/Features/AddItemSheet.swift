import SwiftUI

struct AddItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var mockService: MockDataService
    
    @State private var title = ""
    @State private var quantity: Int = 1
    @State private var hasAttemptedSave = false
    @FocusState private var isFocused: Bool
    
    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isValid: Bool {
        !trimmedTitle.isEmpty
    }
    
    var body: some View {
        ActionlyModalSheet(
            title: "Новый товар",
            subtitle: "Добавление товара в список покупок",
            showsFooter: true,
            onClose: {
                isFocused = false
                dismiss()
            }
        ) {
            VStack(alignment: .leading, spacing: 18) {
                // Name field
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Название")
                            .font(.subheadline)
                            .foregroundStyle(Theme.Colors.muted)
                        
                        if hasAttemptedSave && !isValid {
                            Spacer()
                            Text("Обязательное поле")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    TextField("Например, Молоко или Яблоки...", text: $title)
                        .focused($isFocused)
                        .modifier(StarterInput(focused: isFocused))
                        .submitLabel(.done)
                        .accessibilityIdentifier("add_item_title_input")
                        .onSubmit {
                            save()
                        }
                    
                    if hasAttemptedSave && !isValid {
                        Text("Название не может быть пустым или состоять только из пробелов.")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 4)
                            .accessibilityIdentifier("add_item_error_message")
                    }
                }
                
                // Quantity field with Stepper
                VStack(alignment: .leading, spacing: 8) {
                    Text("Количество")
                        .font(.subheadline)
                        .foregroundStyle(Theme.Colors.muted)
                    
                    HStack {
                        Text("\(quantity) шт.")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Theme.Colors.foreground)
                        
                        Spacer()
                        
                        Stepper("Количество", value: $quantity, in: 1...999)
                            .labelsHidden()
                            .accessibilityIdentifier("add_item_quantity_stepper")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Theme.Colors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Theme.Colors.border, lineWidth: 1)
                    }
                }
                
                // Quick presets
                VStack(alignment: .leading, spacing: 8) {
                    Text("Быстрый выбор количества")
                        .font(.caption)
                        .foregroundStyle(Theme.Colors.muted)
                    
                    HStack(spacing: 8) {
                        ForEach([1, 2, 3, 5, 10], id: \.self) { count in
                            Button {
                                quantity = count
                            } label: {
                                Text("\(count)")
                                    .font(.subheadline.weight(quantity == count ? .bold : .regular))
                                    .foregroundStyle(quantity == count ? Theme.Colors.onPrimary : Theme.Colors.foreground)
                                    .frame(maxWidth: .infinity, minHeight: 36)
                                    .background(quantity == count ? Theme.Colors.foreground : Theme.Colors.surface, in: RoundedRectangle(cornerRadius: 10))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Theme.Colors.border, lineWidth: 1)
                                    }
                            }
                            .buttonStyle(RNPressStyle())
                            .accessibilityIdentifier("add_item_preset_\(count)")
                        }
                    }
                }
            }
        } footer: {
            HStack(spacing: 12) {
                Button {
                    isFocused = false
                    dismiss()
                } label: {
                    Text("Отмена")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .foregroundStyle(Theme.Colors.foreground)
                        .background(Theme.Colors.surface, in: RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Theme.Colors.border, lineWidth: 1)
                        }
                }
                .buttonStyle(RNPressStyle())
                .accessibilityIdentifier("add_item_cancel_button")
                
                ActionlyPrimaryButton(title: "Добавить", isEnabled: true, accessibilityIdentifier: "add_item_save_button") {
                    save()
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    private func save() {
        hasAttemptedSave = true
        guard isValid else { return }
        mockService.addItem(title: trimmedTitle, quantity: quantity, isCompleted: false)
        isFocused = false
        dismiss()
    }
}
