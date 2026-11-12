import SwiftUI

struct CatalogInputView: View {
    private enum Field: Hashable { case name, email, password, amount, note, editor }
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var amount: Double? = nil
    @State private var note = "Многострочное поле для заметок."
    @FocusState private var focused: Field?

    var body: some View {
        CatalogForm {
            Section("Текстовые поля") {
                TextField("Имя", text: $name).focused($focused, equals: .name).textContentType(.givenName).modifier(StarterInput(focused: focused == .name))
                TextField("Электронная почта", text: $email)
                    .keyboardType(.emailAddress).textInputAutocapitalization(.never)
                    .autocorrectionDisabled().textContentType(.emailAddress).focused($focused, equals: .email).modifier(StarterInput(focused: focused == .email))
                SecureField("Пароль", text: $password).textContentType(.newPassword).focused($focused, equals: .password).modifier(StarterInput(focused: focused == .password))
                TextField("Сумма", value: $amount, format: .number).keyboardType(.decimalPad).focused($focused, equals: .amount).modifier(StarterInput(focused: focused == .amount))
                TextField("Многострочное поле", text: $note, axis: .vertical).lineLimit(2...5).focused($focused, equals: .note).modifier(StarterInput(focused: focused == .note, multiline: true))
            }
            .listRowSeparator(.hidden)
            Section("Редактор") {
                TextEditor(text: $note).scrollContentBackground(.hidden).frame(minHeight: 140).accessibilityLabel("Редактор заметки").focused($focused, equals: .editor).modifier(StarterInput(focused: focused == .editor, multiline: true))
                LabeledContent("Символов", value: "\(note.count)")
            }
            Section("Валидация и состояние") {
                LabeledContent("Имя", value: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Не заполнено" : name)
                Text("Заполните имя, чтобы активировать кнопку.").font(.caption).foregroundStyle(.secondary)
                Button("Готово") { focused = nil }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Скрыть клавиатуру") { focused = nil }
            }
        }
    }
}

struct CatalogSelectionView: View {
    @State private var enabled = true
    @State private var favorite = false
    @State private var option = "Личный"
    @State private var segment = "День"
    @State private var wheel = "Средний"
    @State private var volume = 0.5
    @State private var count = 2
    @State private var color = Color.indigo

    var body: some View {
        CatalogForm {
            Section("Переключатели") {
                Toggle("Уведомления", isOn: $enabled)
                Toggle(isOn: $favorite) { Label("Избранное", systemImage: "star") }.toggleStyle(.button)
            }
            Section("Меню выбора") {
                Picker("Список", selection: $option) {
                    ForEach(["Личный", "Семейный", "Рабочий"], id: \.self) { Text($0) }
                }
                Picker("Период", selection: $segment) {
                    ForEach(["День", "Неделя", "Месяц"], id: \.self) { Text($0) }
                }.pickerStyle(.segmented)
                Picker("Размер", selection: $wheel) {
                    ForEach(["Маленький", "Средний", "Большой"], id: \.self) { Text($0) }
                }.pickerStyle(.wheel).frame(height: 130)
                LabeledContent("Выбрано", value: "\(option) · \(segment) · \(wheel)")
            }
            Section("Значения") {
                Slider(value: $volume, in: 0...1, step: 0.1) {
                    Text("Громкость")
                } minimumValueLabel: {
                    Image(systemName: "speaker")
                } maximumValueLabel: {
                    Image(systemName: "speaker.wave.3")
                }
                LabeledContent("Громкость", value: volume.formatted(.percent.precision(.fractionLength(0))))
                Stepper("Количество: \(count)", value: $count, in: 1...20)
                ColorPicker("Цвет акцента", selection: $color, supportsOpacity: true)
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small).fill(color).frame(height: 32).accessibilityLabel("Выбранный цвет")
            }
        }
    }
}

struct CatalogDatesView: View {
    @StateObject private var schedule = ScheduleExamples()
    @State private var showingNewEvent = false
    @State private var date = Date()
    @State private var selectedTime = 40
    @State private var multipleDates: Set<DateComponents> = []
    @State private var confirmed = false
    private let locale = Locale(identifier: "ru_RU")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                Text("Дата и время").font(.headline).foregroundStyle(Theme.Colors.foreground)
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        ReferenceCalendar(selected: { Calendar.current.isDate($0, inSameDayAs: date) }, compact: true) { date = $0; confirmed = false }
                        Rectangle().fill(ReferencePalette.foreground.opacity(0.12)).frame(width: 1)
                        ReferenceTimeSlots(selection: $selectedTime, onChange: { confirmed = false }).frame(width: 100)
                    }.fixedSize(horizontal: false, vertical: true)
                    Divider().overlay(ReferencePalette.foreground.opacity(0.12))
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(referenceDate(date, format: "EEEE, d MMMM")), \(timeLabel(selectedTime))")
                            .font(.subheadline.weight(.medium)).foregroundStyle(ReferencePalette.foreground)
                        Button(confirmed ? "Выбрано" : "Продолжить") { confirmed = true }
                            .buttonStyle(ReferenceActionStyle(selected: confirmed))
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(16)
                }.calendarSurface()
                Text("Интервал").font(.headline).foregroundStyle(Theme.Colors.foreground)
                DateRangeExample()
                Text("События по дням").font(.headline).foregroundStyle(Theme.Colors.foreground)
                ScheduleExampleView(schedule: schedule, onAdd: { showingNewEvent = true })
                Text("Несколько дат").font(.headline).foregroundStyle(Theme.Colors.foreground)
                VStack(alignment: .leading, spacing: 12) {
                    ReferenceCalendar(selected: { multipleDates.contains(dayComponents($0)) }) { day in
                        let value = dayComponents(day)
                        if multipleDates.contains(value) { multipleDates.remove(value) } else { multipleDates.insert(value) }
                    }
                    Text("Выбрано дней: \(multipleDates.count)").font(.caption).foregroundStyle(ReferencePalette.foreground.opacity(0.7)).padding(.horizontal, 16)
                    Button("Очистить") { multipleDates.removeAll() }.buttonStyle(ReferenceActionStyle()).disabled(multipleDates.isEmpty).padding([.horizontal, .bottom], 16)
                }.calendarSurface()
            }.padding(Theme.Spacing.medium)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.bottom, Theme.tabBarScrollClearance / 2, for: .scrollContent)
        .background(Theme.Colors.background)
        .sheet(isPresented: $showingNewEvent) {
            ScheduleExampleForm(schedule: schedule)
        }
    }
}

struct CatalogDateRangeView: View {
    var body: some View {
        ScrollView {
            DateRangeExample().padding(Theme.Spacing.medium)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.bottom, Theme.tabBarScrollClearance / 2, for: .scrollContent)
        .background(Theme.Colors.background)
    }
}

private struct DateRangeExample: View {
    @State private var rangeStart = Calendar.current.startOfDay(for: Date())
    @State private var rangeEnd = Calendar.current.date(byAdding: .day, value: 3, to: Calendar.current.startOfDay(for: Date())) ?? Date()
    @State private var editingEnd = false

    var body: some View {
        VStack(spacing: 0) {
            ReferenceCalendar(selected: { day in
                Calendar.current.isDate(day, inSameDayAs: editingEnd ? rangeEnd : rangeStart)
            }, interval: Calendar.current.startOfDay(for: rangeStart)...Calendar.current.startOfDay(for: rangeEnd)) { day in
                if editingEnd {
                    if day < rangeStart { rangeEnd = rangeStart; rangeStart = day }
                    else { rangeEnd = day }
                    editingEnd = false
                } else {
                    rangeStart = day
                    rangeEnd = day
                    editingEnd = true
                }
            }
        }.calendarSurface(cornerRadius: 24)
    }
}

struct CatalogScheduleView: View {
    @StateObject private var schedule = ScheduleExamples()
    @State private var showingNewEvent = false
    var body: some View {
        ScrollView {
            ScheduleExampleView(schedule: schedule, onAdd: { showingNewEvent = true })
                .padding(Theme.Spacing.medium)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.bottom, Theme.tabBarScrollClearance / 2, for: .scrollContent)
        .background(Theme.Colors.background)
        .sheet(isPresented: $showingNewEvent) { ScheduleExampleForm(schedule: schedule) }
    }
}

struct CatalogWeekView: View {
    @State private var selected = Date()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                ReferenceWeekStrip(selected: $selected)
            }.padding(Theme.Spacing.medium)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.bottom, Theme.tabBarScrollClearance / 2, for: .scrollContent)
        .background(Theme.Colors.background)
    }
}

private struct ScheduleExampleView: View {
    @ObservedObject var schedule: ScheduleExamples
    var onAdd: () -> Void

    private var days: [Date] {
        let calendar = Calendar.current
        return Set(([Date()] + schedule.events.map(\.date)).map { calendar.startOfDay(for: $0) }).sorted()
    }

    private var months: [Date] {
        let calendar = Calendar.current
        return Set(days.compactMap { calendar.dateInterval(of: .month, for: $0)?.start }).sorted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(months, id: \.self) { month in
                HStack {
                    Text(referenceDate(month, format: "LLLL yyyy")).font(.title2.bold())
                    Spacer()
                    if month == months.first {
                        Button(action: onAdd) {
                            Image(systemName: "plus").font(.headline).frame(width: 40, height: 40)
                                .background(ReferencePalette.scheduleControl, in: RoundedRectangle(cornerRadius: 12))
                        }.accessibilityLabel("Добавить событие")
                    }
                }
                ForEach(days.filter { Calendar.current.isDate($0, equalTo: month, toGranularity: .month) }, id: \.self) { day in
                    let events = schedule.events.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 2) {
                            Text(referenceDate(day, format: "EEE")).font(.caption2)
                            Text(referenceDate(day, format: "d")).font(.headline)
                        }.foregroundStyle(ReferencePalette.foreground.opacity(0.65)).frame(width: 30)
                        VStack(spacing: 10) {
                            if events.isEmpty {
                                Text("На сегодня событий нет")
                                    .font(.caption).foregroundStyle(ReferencePalette.foreground.opacity(0.65))
                                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                    .padding(.horizontal, 12).background(ReferencePalette.scheduleControl, in: RoundedRectangle(cornerRadius: 11))
                            }
                            ForEach(events) { event in
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(event.title).font(.subheadline.weight(.medium))
                                    Text(event.time).font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(event.highlighted ? Theme.Colors.onAccent : ReferencePalette.foreground)
                                .frame(maxWidth: .infinity, alignment: .leading).padding(12)
                                .background(event.highlighted ? Theme.Colors.accent : ReferencePalette.scheduleControl, in: RoundedRectangle(cornerRadius: 11))
                            }
                        }
                    }
                }
            }
        }
        .foregroundStyle(ReferencePalette.foreground)
        .padding(18).referenceSurface()
    }

}

private struct ScheduleExampleForm: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var schedule: ScheduleExamples
    @State private var title = ""
    @State private var date = Date()
    @State private var showingCalendar = false
    @State private var detent: PresentationDetent = .medium

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название события", text: $title)
                DisclosureGroup(isExpanded: $showingCalendar) {
                    ReferenceCalendar(selected: { Calendar.current.isDate($0, inSameDayAs: date) }, initialMonth: date) { day in
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
                        date = calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0,
                                             second: components.second ?? 0, of: day) ?? day
                        showingCalendar = false
                    }.calendarSurface()
                } label: {
                    LabeledContent("Дата", value: referenceDate(date, format: "d MMMM yyyy"))
                }
                DatePicker("Время", selection: $date, displayedComponents: .hourAndMinute)
            }
            .navigationTitle("Новое событие")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        schedule.events.append(ScheduleExample(title: title.trimmingCharacters(in: .whitespacesAndNewlines), date: date,
                            time: date.formatted(.dateTime.hour().minute().locale(Locale(identifier: "ru_RU"))), highlighted: true))
                        dismiss()
                    }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large], selection: $detent)
        .onChange(of: showingCalendar) { _, expanded in
            withAnimation { detent = expanded ? .large : .medium }
        }
    }
}

private func dayComponents(_ date: Date) -> DateComponents {
    Calendar.current.dateComponents([.era, .year, .month, .day], from: date)
}

private func referenceDate(_ date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = format
    let formatted = formatter.string(from: date)
    formatter.dateFormat = "MMMM"
    let month = formatter.string(from: date)
    let result = formatted.range(of: month, options: .caseInsensitive).map { range in
        formatted.replacingCharacters(in: range, with: month.prefix(1).uppercased() + month.dropFirst())
    } ?? formatted
    return result.prefix(1).uppercased() + result.dropFirst()
}

private func mondayOfWeek(containing date: Date) -> Date {
    var calendar = Calendar.current
    calendar.firstWeekday = 2
    calendar.minimumDaysInFirstWeek = 4
    return calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
}

private func timeLabel(_ index: Int) -> String {
    String(format: "%02d:%02d", index / 4, (index % 4) * 15)
}

private enum ReferencePalette {
    static let surface = Theme.Colors.adaptive(0xF2F2F2, 0x141414)
    static let calendarSurface = Theme.Colors.adaptive(0xF2F2F2, 0x1C1C1E)
    static let foreground = Theme.Colors.adaptive(0x18181B, 0xF5F5F5)
    static let selected = Theme.Colors.adaptive(0x26242B, 0xFFFFFF)
    static let onSelected = Theme.Colors.adaptive(0xFFFFFF, 0x171717)
    static let control = Theme.Colors.adaptive(0xF1F2F4, 0x242424)
    static let scheduleControl = Theme.Colors.adaptive(0xFFFFFF, 0x242424)
    static let button = Theme.Colors.adaptive(0xF4F5F6, 0x000000)
}

private extension View {
    func calendarSurface(cornerRadius: CGFloat = 14) -> some View {
        background(ReferencePalette.calendarSurface, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    func referenceSurface(cornerRadius: CGFloat = 14) -> some View {
        self.background(ReferencePalette.surface, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

private struct ReferenceActionStyle: ButtonStyle {
    var selected = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.subheadline.weight(.semibold))
            .foregroundStyle(selected ? ReferencePalette.onSelected : ReferencePalette.foreground)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(selected ? ReferencePalette.selected : ReferencePalette.button, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(ReferencePalette.foreground.opacity(0.15)))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

private struct ReferenceCalendar: View {
    let selected: (Date) -> Bool
    var interval: ClosedRange<Date>? = nil
    var initialMonth: Date? = nil
    var compact = false
    let onSelect: (Date) -> Void
    @State private var month = Date()
    private var calendar: Calendar {
        var value = Calendar.current
        value.locale = Locale(identifier: "ru_RU")
        value.firstWeekday = 2
        return value
    }
    private var monthStart: Date { calendar.dateInterval(of: .month, for: month)?.start ?? month }
    private var leading: Int { (calendar.component(.weekday, from: monthStart) - calendar.firstWeekday + 7) % 7 }
    private var count: Int { calendar.range(of: .day, in: .month, for: month)?.count ?? 0 }
    private var gridCount: Int { ((leading + count + 6) / 7) * 7 }
    private var weekdays: [String] {
        let labels = calendar.shortStandaloneWeekdaySymbols
        return (0..<7).map { labels[(calendar.firstWeekday - 1 + $0) % 7] }
    }
    var body: some View {
        VStack(spacing: compact ? 14 : 22) {
            HStack {
                Button { shift(-1) } label: { monthArrow("chevron.left") }.accessibilityLabel("Предыдущий месяц")
                Spacer(minLength: 0)
                Text(referenceDate(monthStart, format: "LLLL yyyy").capitalized)
                    .font((compact ? Font.subheadline : .title3).weight(.semibold)).lineLimit(1).minimumScaleFactor(0.75)
                Spacer(minLength: 0)
                Button { shift(1) } label: { monthArrow("chevron.right") }.accessibilityLabel("Следующий месяц")
            }
            .foregroundStyle(ReferencePalette.foreground)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: compact ? 8 : 14) {
                ForEach(weekdays.indices, id: \.self) { index in
                    Text(weekdays[index]).font((compact ? Font.caption2 : .subheadline).weight(.medium)).foregroundStyle(ReferencePalette.foreground.opacity(0.5)).frame(maxWidth: .infinity, minHeight: compact ? 28 : 34)
                }
                ForEach(0..<gridCount, id: \.self) { index in
                    if let value = calendar.date(byAdding: .day, value: index - leading, to: monthStart) {
                        let day = calendar.component(.day, from: value)
                        let inMonth = calendar.isDate(value, equalTo: monthStart, toGranularity: .month)
                        let dayStart = calendar.startOfDay(for: value)
                        let inRange = interval?.contains(dayStart) ?? false
                        let isStart = interval.map { calendar.isDate(dayStart, inSameDayAs: $0.lowerBound) } ?? false
                        let isEnd = interval.map { calendar.isDate(dayStart, inSameDayAs: $0.upperBound) } ?? false
                        let endpoint = isStart || isEnd
                        Button {
                            if !inMonth { month = value }
                            onSelect(value)
                        } label: {
                            Text("\(day)").font(Font.subheadline.weight(.medium)).frame(maxWidth: .infinity, minHeight: compact ? 34 : 50)
                                .foregroundStyle(inRange && !endpoint ? ReferencePalette.onSelected : ReferencePalette.foreground.opacity(inMonth || inRange || selected(value) ? 1 : 0.35))
                                .background {
                                    if inRange {
                                        GeometryReader { geometry in
                                            let size = min(geometry.size.width, compact ? 34 : 50)
                                            ZStack {
                                                HStack(spacing: 0) {
                                                    (isStart ? Color.clear : ReferencePalette.selected)
                                                    (isEnd ? Color.clear : ReferencePalette.selected)
                                                }.frame(height: size)
                                                if endpoint {
                                                    Circle().fill(ReferencePalette.selected).frame(width: size, height: size)
                                                    Circle().fill(ReferencePalette.calendarSurface).frame(width: size - (compact ? 8 : 10), height: size - (compact ? 8 : 10))
                                                }
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                    } else if selected(value) {
                                        GeometryReader { geometry in
                                            let size = min(geometry.size.width, compact ? 34 : 50)
                                            ZStack {
                                                Circle().fill(ReferencePalette.selected).frame(width: size, height: size)
                                                Circle().fill(ReferencePalette.calendarSurface).frame(width: size - (compact ? 8 : 10), height: size - (compact ? 8 : 10))
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(referenceDate(value, format: "d MMMM yyyy"))
                        .accessibilityAddTraits(selected(value) || endpoint ? .isSelected : [])
                    }
                }
            }
        }
        .padding(.horizontal, compact ? 12 : 18)
        .padding(.vertical, compact ? 12 : 20)
        .onAppear { if let initialMonth { month = initialMonth } }
    }
    private func monthArrow(_ symbol: String) -> some View {
        Image(systemName: symbol).font(.subheadline.weight(.semibold))
            .frame(width: compact ? 32 : 44, height: compact ? 32 : 44)
            .background(ReferencePalette.foreground.opacity(0.30), in: Circle())
            .frame(width: compact ? 40 : 48, height: compact ? 40 : 48)
    }
    private func shift(_ amount: Int) { if let next = calendar.date(byAdding: .month, value: amount, to: monthStart) { month = next } }
}

private struct ReferenceTimeSlots: View {
    @Binding var selection: Int
    let onChange: () -> Void
    @State private var firstVisible = 0
    private let count = 5

    var body: some View {
        VStack(spacing: 0) {
            Button { firstVisible = max(0, firstVisible - count) } label: {
                Image(systemName: "chevron.up").frame(maxWidth: .infinity, minHeight: 28)
            }.accessibilityLabel("Ранее").disabled(firstVisible == 0)
            Spacer(minLength: 4)
            ForEach(firstVisible..<min(firstVisible + count, 96), id: \.self) { index in
                Button { selection = index; onChange() } label: {
                    Text(timeLabel(index)).font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .foregroundStyle(selection == index ? ReferencePalette.onSelected : ReferencePalette.foreground)
                        .background(selection == index ? ReferencePalette.selected : ReferencePalette.button, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(ReferencePalette.foreground.opacity(0.15)))
                }.buttonStyle(.plain)
                    .accessibilityAddTraits(selection == index ? .isSelected : [])
                Spacer(minLength: 4)
            }
            Button { firstVisible = min(96 - count, firstVisible + count) } label: {
                Image(systemName: "chevron.down").frame(maxWidth: .infinity, minHeight: 28)
            }.accessibilityLabel("Позже").disabled(firstVisible >= 96 - count)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(ReferencePalette.foreground.opacity(0.65))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxHeight: .infinity)
        .onAppear { firstVisible = min(max(0, selection - 2), 96 - count) }
    }
}

struct CatalogReminderView: View {
    @State private var selected = Calendar.current.startOfDay(for: Date())
    @State private var category = "События"
    @State private var search = ""
    @State private var details = false
    @State private var address = "45 Greenfield Road, CA"
    @State private var editingAddress = false
    private let locale = Locale(identifier: "ru_RU")
    private let categories = ["Обсуждения", "События", "Отпуск"]
    private var matches: Bool {
        category == "События" && (search.isEmpty || "Мастер-класс по прототипированию".localizedCaseInsensitiveContains(search))
    }
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 18) {
                Label("Напоминания", systemImage: "calendar.badge.clock").font(.headline).foregroundStyle(ReferencePalette.foreground)
                HStack {
                    Button { shiftMonth(-1) } label: { Image(systemName: "chevron.left") }.accessibilityLabel("Предыдущий месяц")
                    Spacer()
                    Text(referenceDate(selected, format: "LLLL yyyy").capitalized).foregroundStyle(ReferencePalette.foreground.opacity(0.8))
                    Spacer()
                    Button { shiftMonth(1) } label: { Image(systemName: "chevron.right") }.accessibilityLabel("Следующий месяц")
                }.buttonStyle(.plain).foregroundStyle(ReferencePalette.foreground.opacity(0.7)).padding(12).background(ReferencePalette.control, in: RoundedRectangle(cornerRadius: 12))
                HStack(spacing: 2) {
                    Button { shiftDay(-7) } label: { Image(systemName: "chevron.left").frame(width: 26, height: 44) }.accessibilityLabel("Предыдущая неделя")
                    ForEach(0..<7, id: \.self) { offset in
                        let day = Calendar.current.date(byAdding: .day, value: offset, to: mondayOfWeek(containing: selected)) ?? selected
                        let isSelected = Calendar.current.isDate(day, inSameDayAs: selected)
                        Button { selected = day } label: {
                            VStack(spacing: 4) {
                                Text(day.formatted(.dateTime.weekday(.abbreviated).locale(locale))).font(.caption).foregroundStyle(ReferencePalette.foreground.opacity(isSelected ? 0.85 : 0.5))
                                Text(day.formatted(.dateTime.day().locale(locale))).font(.headline).foregroundStyle(ReferencePalette.foreground)
                            }.frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(isSelected ? Theme.Colors.adaptive(0xFFFFFF, 0x090909) : .clear, in: RoundedRectangle(cornerRadius: 13))
                        }.buttonStyle(.plain)
                    }
                    Button { shiftDay(7) } label: { Image(systemName: "chevron.right").frame(width: 26, height: 44) }.accessibilityLabel("Следующая неделя")
                }.buttonStyle(.plain).foregroundStyle(ReferencePalette.foreground.opacity(0.7)).padding(8).background(ReferencePalette.control, in: RoundedRectangle(cornerRadius: 14))
                Picker("Категория", selection: $category) { ForEach(categories, id: \.self) { Text($0) } }.pickerStyle(.segmented).padding(.top, 10)
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(ReferencePalette.foreground.opacity(0.5))
                    TextField("Поиск событий", text: $search).foregroundStyle(ReferencePalette.foreground).tint(ReferencePalette.foreground)
                }.padding(14).overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(ReferencePalette.foreground.opacity(0.12)))
                if matches {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Мастер-класс по прототипированию").font(.headline).foregroundStyle(ReferencePalette.foreground)
                            Text("10:30 — 12:00").font(.subheadline).foregroundStyle(ReferencePalette.foreground.opacity(0.55))
                        }
                        HStack { Text("Организатор: Сара"); Spacer(); Label("12/16", systemImage: "person.2") }.font(.caption).foregroundStyle(ReferencePalette.foreground.opacity(0.55))
                        HStack {
                            Image(systemName: "mappin.circle.fill").foregroundStyle(ReferencePalette.foreground)
                            Text(address).font(.subheadline).foregroundStyle(ReferencePalette.foreground).lineLimit(2)
                            Spacer(minLength: 4)
                            Button { editingAddress = true } label: { Image(systemName: "pencil").foregroundStyle(ReferencePalette.foreground) }.accessibilityLabel("Изменить адрес")
                        }.padding(12).background(ReferencePalette.control, in: RoundedRectangle(cornerRadius: 10))
                        Button("Подробнее") { details = true }.font(.subheadline.weight(.semibold)).foregroundStyle(ReferencePalette.foreground)
                            .frame(maxWidth: .infinity).padding(12).background(ReferencePalette.control, in: RoundedRectangle(cornerRadius: 10))
                    }.padding(16).overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(ReferencePalette.foreground.opacity(0.1)))
                } else {
                    Text("Событий не найдено").font(.subheadline).foregroundStyle(ReferencePalette.foreground.opacity(0.6)).frame(maxWidth: .infinity).padding(.vertical, 40)
                }
            }.padding(18).background(ReferencePalette.surface, in: RoundedRectangle(cornerRadius: 22)).padding(16)
            VStack(alignment: .leading, spacing: 12) {
                Text("Выбор недели").font(.headline).foregroundStyle(Theme.Colors.foreground)
                ReferenceWeekStrip(selected: $selected)
            }.padding(.horizontal, 16)
            }

        }
        .scrollIndicators(.hidden).contentMargins(.bottom, Theme.tabBarScrollClearance / 2, for: .scrollContent)
        .background(Theme.Colors.background)
        .sheet(isPresented: $details) {
            NavigationStack {
                Form { LabeledContent("Событие", value: "Мастер-класс по прототипированию"); LabeledContent("Время", value: "10:30 — 12:00"); LabeledContent("Адрес", value: address) }
                    .navigationTitle("Подробнее").navigationBarTitleDisplayMode(.inline)
                    .toolbar { Button("Готово") { details = false } }
            }.presentationDetents([.medium, .large])
        }
        .alert("Адрес", isPresented: $editingAddress) {
            TextField("Адрес", text: $address)
            Button("Готово") {}
        }
    }
    private func shiftDay(_ count: Int) { selected = Calendar.current.date(byAdding: .day, value: count, to: selected) ?? selected }
    private func shiftMonth(_ count: Int) { selected = Calendar.current.date(byAdding: .month, value: count, to: selected) ?? selected }
}

private struct ReferenceWeekStrip: View {
    @Binding var selected: Date
    @Environment(\.colorScheme) private var scheme
    private let locale = Locale(identifier: "ru_RU")
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<7, id: \.self) { offset in
                let day = Calendar.current.date(byAdding: .day, value: offset, to: mondayOfWeek(containing: selected)) ?? selected
                let weekend = Calendar.current.isDateInWeekend(day)
                let isSelected = Calendar.current.isDate(day, inSameDayAs: selected)
                Button { selected = day } label: {
                    VStack(spacing: 6) {
                        Text(day.formatted(.dateTime.weekday(.abbreviated).locale(locale)).uppercased()).font(.caption2.weight(.semibold))
                            .foregroundStyle(isSelected ? Color.white : weekend ? Color.red : Theme.Colors.muted)
                        Text(day.formatted(.dateTime.day().locale(locale))).font(.subheadline.weight(.semibold))
                            .foregroundStyle(isSelected ? Color.white : Theme.Colors.foreground)
                    }.frame(maxWidth: .infinity, minHeight: 66)
                        .background(isSelected ? (scheme == .dark ? Color(white: 0.22) : Theme.Colors.accent) : .clear, in: RoundedRectangle(cornerRadius: 17))
                }.buttonStyle(.plain)
                    .accessibilityLabel(referenceDate(day, format: "EEEE, d MMMM yyyy"))
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(8)
        .background(ReferencePalette.calendarSurface, in: RoundedRectangle(cornerRadius: 25))
        .simultaneousGesture(DragGesture(minimumDistance: 30).onEnded { gesture in
            guard abs(gesture.translation.width) > abs(gesture.translation.height) else { return }
            shiftWeek(gesture.translation.width < 0 ? 1 : -1)
        })
        .accessibilityAction(named: Text("Предыдущая неделя")) { shiftWeek(-1) }
        .accessibilityAction(named: Text("Следующая неделя")) { shiftWeek(1) }
    }

    private func shiftWeek(_ direction: Int) {
        selected = Calendar.current.date(byAdding: .day, value: direction * 7, to: selected) ?? selected
    }
}
