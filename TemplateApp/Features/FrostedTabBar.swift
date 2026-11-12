import SwiftUI

struct ElasticTabItem: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let action: () -> Void
}

/// Shared floating tab bar used by both the template and its component example.
struct ElasticTabBar: View {
    let items: [ElasticTabItem]
    let selectedID: String
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 2) {
            ForEach(items) { item in
                Button(action: item.action) {
                    Image(systemName: item.symbol)
                        .font(.system(size: 19, weight: .medium))
                        .foregroundStyle(item.id == selectedID ? Theme.Colors.onPrimary : Theme.Colors.foreground.opacity(0.8))
                        .frame(maxWidth: .infinity, minHeight: 68)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.title)
                .accessibilityIdentifier("tab_item_\(item.id)")
                .accessibilityAddTraits(item.id == selectedID ? .isSelected : [])
            }
        }
        .background {
            GeometryReader { geometry in
                let count = CGFloat(items.count)
                let width = (geometry.size.width - max(0, count - 1) * 2) / max(count, 1)
                let index = items.firstIndex { $0.id == selectedID } ?? 0
                indicator(width: width, height: geometry.size.height)
                    .offset(x: CGFloat(index) * (width + 2))
                    .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.76), value: selectedID)
            }.allowsHitTesting(false)
        }
        .padding(7)
        .background(Theme.Colors.adaptive(0xFFFFFF, 0x26282E), in: Capsule())
        .padding(8)
        .background(Theme.Colors.surface, in: Capsule())
        .overlay(Capsule().strokeBorder(Theme.Colors.border.opacity(0.8)))
        .shadow(color: .black.opacity(scheme == .dark ? 0.2 : 0.1), radius: 16, y: 8)
    }

    @ViewBuilder
    private func indicator(width: CGFloat, height: CGFloat) -> some View {
        let capsule = Capsule().fill(Theme.Colors.foreground).frame(width: width, height: height)
        if reduceMotion {
            capsule
        } else {
            capsule.keyframeAnimator(initialValue: 1.0, trigger: selectedID) { content, stretch in
                content.scaleEffect(x: stretch, y: 1 / sqrt(stretch))
            } keyframes: { _ in
                KeyframeTrack(\.self) {
                    LinearKeyframe(1.25, duration: 0.13)
                    SpringKeyframe(1.0, duration: 0.36, spring: .bouncy)
                }
            }
        }
    }
}

struct FrostedTabBar: View {
    @Binding var selectedTab: AppTab
    var onAdd: () -> Void
    var onOpenSettings: () -> Void
    let bottomSafeArea: CGFloat

    var body: some View {
        ElasticTabBar(items: [
            ElasticTabItem(id: AppTab.list.rawValue, title: AppTab.list.title, symbol: AppTab.list.icon, action: { selectedTab = .list }),
            ElasticTabItem(id: "add", title: "Добавить", symbol: "plus", action: onAdd),
            ElasticTabItem(id: "settings", title: "Настройки", symbol: "gearshape", action: onOpenSettings)
        ], selectedID: selectedTab.rawValue)
        .padding(.horizontal, 24)
        .padding(.bottom, Theme.tabBarBottomGap - bottomSafeArea)
    }
}
