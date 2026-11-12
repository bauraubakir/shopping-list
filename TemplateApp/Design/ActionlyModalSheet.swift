import SwiftUI

/// Button press style from Actionly with gentle tactile feedback.
struct RNPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
    }
}

/// Circular close button ('xmark') 1-to-1 from Actionly.
struct RNCloseButton: View {
    var action: () -> Void
    var compact = false
    var size: CGFloat = 36
    var iconSize: CGFloat = 20
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(uiColor: scheme == .dark ? (compact ? UIColor(red: 0xC7/255, green: 0xC7/255, blue: 0xCC/255, alpha: 1) : UIColor(red: 0x8E/255, green: 0x8E/255, blue: 0x93/255, alpha: 1)) : UIColor(red: 0x63/255, green: 0x63/255, blue: 0x66/255, alpha: 1)))
                .frame(width: size, height: size)
                .background(Color(uiColor: scheme == .dark ? (compact ? UIColor(red: 0x54/255, green: 0x54/255, blue: 0x56/255, alpha: 1) : UIColor(red: 0x3A/255, green: 0x3A/255, blue: 0x3C/255, alpha: 1)) : UIColor(red: 0xF2/255, green: 0xF2/255, blue: 0xF7/255, alpha: 1)), in: Circle())
                .contentShape(Rectangle().inset(by: -max(0, (44 - size) / 2)))
        }
        .buttonStyle(RNPressStyle())
        .accessibilityLabel("Закрыть")
    }
}

/// Modal presentation modifier matching Actionly sheet behavior.
struct RNModalPresentation: ViewModifier {
    var showsDragIndicator = false
    func body(content: Content) -> some View {
        content
            .presentationCornerRadius(nil)
            .presentationDragIndicator(showsDragIndicator ? .visible : .hidden)
    }
}

/// Content-fit modal sheet layout 1-to-1 from Actionly (RNTaskSheet).
struct ActionlyModalSheet<Content: View, Footer: View>: View {
    let title: String
    var subtitle: String? = nil
    var showsFooter: Bool = true
    var detents: Set<PresentationDetent>? = nil
    let onClose: () -> Void
    @ViewBuilder var content: () -> Content
    @ViewBuilder var footer: () -> Footer
    
    @State private var headerHeight: CGFloat = 68
    @State private var contentHeight: CGFloat = 160
    @State private var footerHeight: CGFloat = 70
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and circular close button
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                RNCloseButton(action: onClose, compact: true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { headerHeight = $0 }
            
            // Content area
            ScrollView {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { contentHeight = $0 }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
            
            // Footer with primary action button
            if showsFooter {
                footer()
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { footerHeight = $0 }
            }
        }
        .presentationDetents(detents ?? [.height(max(200, headerHeight + contentHeight + (showsFooter ? footerHeight : 0)))])
        .presentationContentInteraction(.scrolls)
        .modifier(RNModalPresentation(showsDragIndicator: detents != nil))
    }
}

/// Primary action button with Actionly surface styling.
struct ActionlyPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var accessibilityIdentifier: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
                .foregroundStyle(Theme.Colors.onPrimary)
                .background(Theme.Colors.foreground, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(RNPressStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
        .accessibilityIdentifier(accessibilityIdentifier ?? title)
    }
}
