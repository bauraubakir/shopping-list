import SwiftUI

enum ComponentCategory: String, CaseIterable, Identifiable {
    case lists, input, selection, dates, reminders, schedule, week, dateRange, tabbars, authentication, actions, feedback, presentation, layout, content, charts, media

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lists: "Списки"
        case .input: "Ввод текста"
        case .selection: "Выбор и переключатели"
        case .dates: "Дата и время"
        case .reminders: "Напоминания"
        case .schedule: "События по дням"
        case .week: "Выбор недели"
        case .dateRange: "Промежуток дат"
        case .tabbars: "Таббары"
        case .authentication: "Авторизация"
        case .actions: "Кнопки и меню"
        case .feedback: "Состояния и индикаторы"
        case .presentation: "Окна и уведомления"
        case .layout: "Сетки и контейнеры"
        case .content: "Текст и оформление"
        case .charts: "Графики"
        case .media: "Фото и файлы"
        }
    }

    var detail: String {
        switch self {
        case .lists: "Секции, свайпы, удаление, перестановка, поиск"
        case .input: "Текст, пароль, число, многострочный редактор"
        case .selection: "Picker, Toggle, Slider, Stepper, ColorPicker"
        case .dates: "Календарь, часы, колёсики, несколько дат"
        case .reminders: "Дни, категории, поиск и карточка события"
        case .schedule: "Список событий и добавление"
        case .week: "Горизонтальный выбор дня"
        case .dateRange: "Выбор диапазона дат"
        case .tabbars: "Плавающая панель вкладок"
        case .authentication: "Apple, Google и вход по почте"
        case .actions: "Стили кнопок, меню, контекстное меню"
        case .feedback: "Загрузка, прогресс, шкалы, пустое состояние"
        case .presentation: "Sheet, alert, диалог, popover, полный экран"
        case .layout: "Grid, карточки, прокрутка, страницы, раскрытие"
        case .content: "Типографика, символы, материалы, выделение текста"
        case .charts: "Столбцы, линия, область и кольцевая диаграмма"
        case .media: "Выбор фото и файлов, системная отправка"
        }
    }

    var symbol: String {
        switch self {
        case .lists: "list.bullet"
        case .input: "text.cursor"
        case .selection: "slider.horizontal.3"
        case .dates: "calendar"
        case .reminders: "calendar.badge.clock"
        case .schedule: "calendar.badge.plus"
        case .week: "calendar.day.timeline.left"
        case .dateRange: "calendar.badge.clock"
        case .tabbars: "rectangle.bottomthird.inset.filled"
        case .authentication: "person.crop.circle.badge.checkmark"
        case .actions: "hand.tap"
        case .feedback: "gauge.with.dots.needle.50percent"
        case .presentation: "rectangle.bottomthird.inset.filled"
        case .layout: "square.grid.2x2"
        case .content: "textformat"
        case .charts: "chart.bar.xaxis"
        case .media: "photo.on.rectangle"
        }
    }
}

struct CatalogRow: Identifiable {
    let id = UUID()
    var title: String
    var completed = false
}

struct CatalogNode: Identifiable {
    let title: String
    var children: [CatalogNode]?
    var id: String { title }
}

struct CatalogChartPoint: Identifiable {
    let day: String
    let value: Double
    var id: String { day }
}
