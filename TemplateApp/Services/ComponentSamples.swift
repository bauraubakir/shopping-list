import Foundation

struct ScheduleExample: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var time: String
    var highlighted: Bool
}

final class ScheduleExamples: ObservableObject {
    @Published var events: [ScheduleExample]

    init() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
        let later = Calendar.current.date(byAdding: .day, value: 5, to: today) ?? today
        events = [
            ScheduleExample(title: "Обсуждение проекта", date: tomorrow, time: "09:15 – 10:15", highlighted: true),
            ScheduleExample(title: "Встреча с командой", date: tomorrow, time: "18:30 – 20:00", highlighted: true),
            ScheduleExample(title: "Встреча за кофе", date: later, time: "14:30 – 15:30", highlighted: false)
        ]
    }
}

final class ComponentSamples: ObservableObject {
    @Published var rows: [CatalogRow] = []

    init() { reset() }

    func reset() {
        rows = ["Молоко", "Хлеб", "Яблоки", "Кофе"].map { CatalogRow(title: $0) }
    }

    func setCompleted(_ completed: Bool, for id: UUID) {
        guard let index = rows.firstIndex(where: { $0.id == id }) else { return }
        rows[index].completed = completed
    }

    static let tree = [
        CatalogNode(title: "Покупки", children: [
            CatalogNode(title: "Продукты", children: [CatalogNode(title: "Фрукты"), CatalogNode(title: "Овощи")]),
            CatalogNode(title: "Для дома")
        ])
    ]

    static let chart = [
        CatalogChartPoint(day: "Пн", value: 3), CatalogChartPoint(day: "Вт", value: 5),
        CatalogChartPoint(day: "Ср", value: 4), CatalogChartPoint(day: "Чт", value: 8),
        CatalogChartPoint(day: "Пт", value: 6), CatalogChartPoint(day: "Сб", value: 9),
        CatalogChartPoint(day: "Вс", value: 7)
    ]
}
