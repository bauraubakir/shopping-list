import SwiftUI

struct StatsView: View {
    @ObservedObject var mockService: MockDataService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                StarterHero(description: "Раздел аналитики и метрик. Здесь отображается статистика созданных и выполненных элементов списка покупок.")
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .navigationTitle("Статистика")
        .background(Theme.Colors.background.ignoresSafeArea())
    }
}
