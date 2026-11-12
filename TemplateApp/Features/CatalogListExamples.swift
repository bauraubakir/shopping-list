import SwiftUI

struct CatalogListsView: View {
    @StateObject private var samples = ComponentSamples()
    @State private var search = ""
    @State private var style = "Секции"

    private var visibleIDs: [UUID] {
        samples.rows.filter { search.isEmpty || $0.title.localizedCaseInsensitiveContains(search) }.map(\.id)
    }

    var body: some View {
        Group {
            if style == "Простой" { rows.listStyle(.plain) }
            else { rows.listStyle(.insetGrouped) }
        }
        .scrollIndicators(.hidden)
        .contentMargins(.bottom, Theme.tabBarScrollClearance / 2, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .background(Theme.Colors.background)
        .listRowBackground(Theme.Colors.surface)
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Найти позицию")
        .refreshable { samples.reset() }
        .toolbar { EditButton().accessibilityLabel("Изменить список") }
    }

    private var rows: some View {
        List {
            Section {
                Picker("Стиль списка", selection: $style) {
                    Text("Секции").tag("Секции")
                    Text("Простой").tag("Простой")
                }.pickerStyle(.segmented)
            }
            Section {
                ForEach(samples.rows.filter { visibleIDs.contains($0.id) }) { row in
                        Toggle(isOn: Binding(
                            get: { samples.rows.first { $0.id == row.id }?.completed ?? false },
                            set: { samples.setCompleted($0, for: row.id) }
                        )) {
                            Text(row.title).strikethrough(row.completed)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Удалить", role: .destructive) { samples.rows.removeAll { $0.id == row.id } }
                        }
                        .swipeActions(edge: .leading) {
                            Button(row.completed ? "Вернуть" : "Готово") { samples.setCompleted(!row.completed, for: row.id) }.tint(.green)
                        }
                        .contextMenu {
                            Button("Отметить покупку", systemImage: "checkmark") { samples.setCompleted(!row.completed, for: row.id) }
                        }
                }
                .onDelete { offsets in
                    let removed = Set(offsets.map { visibleIDs[$0] })
                    samples.rows.removeAll { removed.contains($0.id) }
                }
                .onMove { source, destination in samples.rows.move(fromOffsets: source, toOffset: destination) }
                .moveDisabled(!search.isEmpty)
                Button("Добавить позицию", systemImage: "plus") {
                    samples.rows.append(CatalogRow(title: "Новая позиция"))
                }
            } header: {
                Text("Покупки")
            } footer: {
                Text("Свайпните строку. Через «Изменить» можно удалять и переставлять позиции. Потяните список вниз, чтобы восстановить примеры.")
            }
            if visibleIDs.isEmpty {
                ContentUnavailableView("Нет позиций", systemImage: "tray", description: Text("Добавьте позицию или измените поиск."))
            }
            Section("Дерево") {
                OutlineGroup(ComponentSamples.tree, children: \.children) { node in
                    Label(node.title, systemImage: node.children == nil ? "doc" : "folder")
                }
            }
            Section {
                Button("Восстановить список") { samples.reset() }
            }
        }
    }
}
