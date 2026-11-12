import SwiftUI

struct CatalogActionsView: View {
    @State private var result = "Выберите действие"
    @State private var priority = "Обычный"

    var body: some View {
        CatalogForm {
            Section("Стили кнопок") {
                Button("Основное действие", systemImage: "plus") { result = "Основное действие выполнено" }.buttonStyle(.borderedProminent)
                Button("Второстепенное действие") { result = "Второстепенное действие выполнено" }.buttonStyle(.bordered)
                Button("Текстовая кнопка") { result = "Текстовое действие выполнено" }.buttonStyle(.borderless)
                Button("Удалить пример", role: .destructive) { result = "Удалён только демонстрационный пример" }
                Button("Недоступно") {}.disabled(true)
                Button { result = "Нажата кнопка с символом" } label: { Image(systemName: "heart") }
                    .accessibilityLabel("Нравится").buttonStyle(.bordered)
            }
            Section("Меню") {
                Menu("Действия", systemImage: "ellipsis.circle") {
                    Button("Дублировать", systemImage: "doc.on.doc") { result = "Создана копия примера" }
                    Picker("Приоритет", selection: $priority) {
                        ForEach(["Низкий", "Обычный", "Высокий"], id: \.self) { Text($0) }
                    }
                    Divider()
                    Button("Удалить", role: .destructive) { result = "Выбрано удаление из меню" }
                }
                Label("Удерживайте эту строку", systemImage: "hand.point.up.left")
                    .contextMenu {
                        Button("В избранное", systemImage: "star") { result = "Добавлено в избранное" }
                        Button("Скрыть", systemImage: "eye.slash") { result = "Пример скрыт в демонстрации" }
                    }
                LabeledContent("Приоритет", value: priority)
            }
            Section("Результат") {
                Text(result).accessibilityIdentifier("catalog.action-result")
            }
        }
    }
}

struct CatalogFeedbackView: View {
    @State private var progress = 0.4
    @State private var showingRefresh = false

    var body: some View {
        CatalogForm {
            Section("Загрузка") {
                ProgressView("Загрузка…").frame(maxWidth: .infinity, alignment: .leading)
                ProgressView(value: progress) { Text("Подготовка") } currentValueLabel: {
                    Text(progress, format: .percent.precision(.fractionLength(0)))
                }
                Slider(value: $progress, in: 0...1, step: 0.1) { Text("Прогресс") }
            }
            Section("Шкалы") {
                Gauge(value: progress) { Text("Заполнено") }.gaugeStyle(.linearCapacity)
                HStack {
                    Spacer()
                    Gauge(value: progress) { Image(systemName: "bolt") } currentValueLabel: {
                        Text(progress, format: .percent.precision(.fractionLength(0)))
                    }.gaugeStyle(.accessoryCircularCapacity)
                    Spacer()
                }.padding(.vertical, Theme.Spacing.small)
            }
            Section("Пустое состояние") {
                ContentUnavailableView("Пока ничего нет", systemImage: "tray", description: Text("Здесь появятся новые записи."))
            }
            Section("Ошибка и успех") {
                Label("Нет подключения. Попробуйте ещё раз.", systemImage: "wifi.slash").foregroundStyle(.red)
                Label("Изменения сохранены", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                Button("Повторить") { progress = 0 }
            }
        }
    }
}

struct CatalogPresentationView: View {
    private enum Window: String, Identifiable { case sheet, fullScreen; var id: String { rawValue } }
    @State private var window: Window?
    @State private var alert = false
    @State private var confirmation = false
    @State private var popover = false
    @State private var result = "Действие ещё не выбрано"

    var body: some View {
        CatalogForm {
            Section("Презентации") {
                Button("Модальный лист") { window = .sheet }
                    .accessibilityIdentifier("catalog.show-sheet")
                Button("Полный экран") { window = .fullScreen }
                Button("Всплывающая подсказка") { popover = true }
                    .popover(isPresented: $popover) {
                        Text("Небольшая подсказка рядом с действием.")
                            .padding(Theme.Spacing.large)
                            .presentationCompactAdaptation(.popover)
                    }
            }
            Section("Подтверждения") {
                Button("Уведомление") { alert = true }.accessibilityIdentifier("catalog.show-alert")
                Button("Выбор действия") { confirmation = true }
                Text(result).foregroundStyle(.secondary).accessibilityIdentifier("catalog.dialog-result")
            }
        }
        .sheet(isPresented: Binding(get: { window == .sheet }, set: { if !$0 { window = nil } })) {
            CatalogSampleSheet(title: "Модальный лист") { window = nil }
        }
        .fullScreenCover(isPresented: Binding(get: { window == .fullScreen }, set: { if !$0 { window = nil } })) {
            CatalogSampleSheet(title: "Полный экран") { window = nil }
        }
        .alert("Сохранить изменения?", isPresented: $alert) {
            Button("Сохранить") { result = "Изменения сохранены" }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Это демонстрационное уведомление. Данные никуда не отправляются.")
        }
        .confirmationDialog("Что сделать с примером?", isPresented: $confirmation, titleVisibility: .visible) {
            Button("Дублировать") { result = "Создана копия" }
            Button("Удалить", role: .destructive) { result = "Пример удалён" }
            Button("Отмена", role: .cancel) {}
        }
    }
}

private struct CatalogSampleSheet: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        ActionlyModalSheet(title: title, subtitle: "Нативная презентация", detents: [.medium, .large], onClose: onClose) {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                Label("Готово к переиспользованию", systemImage: "checkmark.circle")
                Text("Тот же компонент листа, который используется в форме добавления. Потяните модальный лист вверх, чтобы развернуть его.")
                    .foregroundStyle(.secondary)
            }
        } footer: {
            ActionlyPrimaryButton(title: "Готово", action: onClose)
        }
    }
}
