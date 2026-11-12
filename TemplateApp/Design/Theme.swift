import SwiftUI
import UIKit

enum Theme {
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    enum Colors {
        // Apple & Linear refined design system:
        // Light: soft gray canvas (0xDADDE0), graphite text (0x111827), slate border (0xE5E7EB)
        // Dark: Linear midnight (0x0C0D0E), elevated dark card (0x16171B), crisp text (0xF7F8F8), dark border (0x24262D)
        static let background = adaptive(0xDADDE0, 0x0C0D0E)
        static let surface = adaptive(0xF2F2F2, 0x16171B)
        static let cardBackground = adaptive(0xFFFFFF, 0x16171B)
        static let foreground = adaptive(0x111827, 0xF7F8F8)
        static let onPrimary = adaptive(0xFFFFFF, 0x0C0D0E)
        static let muted = adaptive(0x6B7280, 0x8A8F98)
        static let border = adaptive(0xE5E7EB, 0x24262D)
        static let accent = adaptive(0x5E6AD2, 0x00C860)
        static let onAccent = adaptive(0xFFFFFF, 0x11140A)
        static let green = adaptive(0x10B981, 0x34D399)
        static let textPrimary = foreground
        static let textSecondary = muted
        
        static func adaptive(_ light: UInt32, _ dark: UInt32) -> Color {
            Color(uiColor: UIColor { traits in
                let value = traits.userInterfaceStyle == .dark ? dark : light
                return UIColor(
                    red: CGFloat((value >> 16) & 255) / 255,
                    green: CGFloat((value >> 8) & 255) / 255,
                    blue: CGFloat(value & 255) / 255,
                    alpha: 1
                )
            })
        }
    }
    
    static let tabBarButtonSize: CGFloat = 48
    static let tabBarVerticalPadding: CGFloat = 8
    /// Visible distance from the tab bar shape to the physical bottom edge.
    static let tabBarBottomGap: CGFloat = 24
    static var tabBarScrollClearance: CGFloat {
        tabBarButtonSize + 2 * tabBarVerticalPadding + tabBarBottomGap + Spacing.large
    }
}

struct GlassCard: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var cornerRadius: CGFloat = 48

    func body(content: Content) -> some View {
        content
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).strokeBorder(.white.opacity(scheme == .dark ? 0.12 : 0.85)))
            .shadow(color: .black.opacity(scheme == .dark ? 0.22 : 0.12), radius: 18, y: 8)
    }
}

/// Shared, restrained surface for the starter screens.
struct StarterSurface: ViewModifier {
    var cornerRadius: CGFloat = 22

    func body(content: Content) -> some View {
        content
            .background(Theme.Colors.surface, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Theme.Colors.border.opacity(0.8), lineWidth: 1)
            }
    }
}

/// Shared input surface for text fields and editors across the starter.
struct StarterInput: ViewModifier {
    var focused = false
    var multiline = false

    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundStyle(Theme.Colors.foreground)
            .tint(Theme.Colors.accent)
            .padding(.horizontal, 16)
            .padding(.vertical, multiline ? 14 : 12)
            .frame(minHeight: multiline ? 76 : 52, alignment: multiline ? .topLeading : .leading)
            .background(Theme.Colors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(focused ? Theme.Colors.accent : Theme.Colors.border, lineWidth: focused ? 1.5 : 1)
            }
    }
}

struct StarterIcon: View {
    var body: some View {
        Image(systemName: "cart.fill")
            .font(.title3.weight(.medium))
            .foregroundStyle(Theme.Colors.foreground)
            .frame(width: 48, height: 48)
            .background(Theme.Colors.adaptive(0xFFFFFF, 0x0C0D0E), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .accessibilityHidden(true)
    }
}

struct StarterHero: View {
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StarterIcon()
            Text("Список покупок")
                .font(.title2.weight(.semibold))
                .tracking(-0.5)
                .foregroundStyle(Theme.Colors.foreground)
                .padding(.top, 28)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(Theme.Colors.muted)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(StarterSurface())
    }
}

/// Dynamic window appearance controller matching Actionly and Linear.
struct WindowAppearance: UIViewRepresentable {
    let style: UIUserInterfaceStyle

    func makeUIView(context: Context) -> AppearanceView {
        AppearanceView(style: style)
    }

    func updateUIView(_ view: AppearanceView, context: Context) {
        view.style = style
    }

    final class AppearanceView: UIView {
        var style: UIUserInterfaceStyle {
            didSet { applyStyle() }
        }

        init(style: UIUserInterfaceStyle) {
            self.style = style
            super.init(frame: .zero)
            isUserInteractionEnabled = false
            isAccessibilityElement = false
        }

        required init?(coder: NSCoder) { return nil }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            applyStyle()
        }

        private func applyStyle() {
            guard let window, window.overrideUserInterfaceStyle != style else { return }
            window.overrideUserInterfaceStyle = style
        }
    }
}

extension String {
    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case "light": return .light
        case "dark": return .dark
        default: return .unspecified
        }
    }
}
