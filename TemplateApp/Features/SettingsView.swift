import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appearance") private var appearance = "system"
    @AppStorage("notifications_enabled") private var notificationsEnabled = true
    @AppStorage("haptic_feedback") private var hapticFeedback = true
    @State private var detent: PresentationDetent = .fraction(0.52)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header matching Actionly
            HStack(spacing: 12) {
                StarterIcon()
                VStack(alignment: .leading, spacing: 2) {
                    Text("Настройки")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Theme.Colors.foreground)
                    Text("Список покупок")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.Colors.muted)
                }
                Spacer(minLength: 0)
                RNCloseButton(action: { dismiss() }, compact: detent != .large)
                    .accessibilityIdentifier("settings_close_button")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Theme picker card
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Тема", selection: $appearance) {
                            Text("Системная").tag("system")
                            Text("Светлая").tag("light")
                            Text("Тёмная").tag("dark")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(10)
                    .background(Theme.Colors.surface, in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Theme.Colors.border, lineWidth: 1)
                    )
                    
                    // Preferences section card
                    VStack(spacing: 0) {
                        Toggle("Уведомления", isOn: $notificationsEnabled)
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.Colors.foreground)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                        
                        Divider()
                            .padding(.leading, 14)
                        
                        Toggle("Тактильный отклик", isOn: $hapticFeedback)
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.Colors.foreground)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                    }
                    .background(Theme.Colors.surface, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Theme.Colors.border, lineWidth: 1)
                    )
                    
                    // About section card
                    VStack(spacing: 0) {
                        HStack {
                            Text("Размер текста")
                                .font(.system(size: 15))
                                .foregroundStyle(Theme.Colors.foreground)
                            Spacer()
                            Text("Стандартный (L)")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.Colors.muted)
                                .accessibilityIdentifier("settings_content_size_category")
                                .accessibilityValue(UITraitCollection.current.preferredContentSizeCategory.rawValue)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        
                        Divider()
                            .padding(.leading, 14)
                        
                        HStack {
                            Text("Версия")
                                .font(.system(size: 15))
                                .foregroundStyle(Theme.Colors.foreground)
                            Spacer()
                            Text("1.0 (Прототип)")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.Colors.muted)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        
                        Divider()
                            .padding(.leading, 14)
                        
                        HStack {
                            Text("Стек")
                                .font(.system(size: 15))
                                .foregroundStyle(Theme.Colors.foreground)
                            Spacer()
                            Text("SwiftUI • iOS 17+")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.Colors.muted)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                    }
                    .background(Theme.Colors.surface, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Theme.Colors.border, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .presentationDetents([.fraction(0.52), .large], selection: $detent)
        .presentationDragIndicator(.visible)
    }
}
