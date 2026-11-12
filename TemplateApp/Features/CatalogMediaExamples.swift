import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Charts

struct CatalogChartsView: View {
    @State private var style = "Столбцы"

    var body: some View {
        CatalogForm {
            Section("Тип графика") {
                Picker("Тип графика", selection: $style) {
                    ForEach(["Столбцы", "Линия", "Область", "Кольцо"], id: \.self) { Text($0) }
                }.pickerStyle(.segmented)
            }
            Section("Демонстрационные данные") {
                Chart(ComponentSamples.chart) { point in
                    switch style {
                    case "Линия":
                        LineMark(x: .value("День", point.day), y: .value("Значение", point.value)).interpolationMethod(.catmullRom)
                        PointMark(x: .value("День", point.day), y: .value("Значение", point.value))
                    case "Область":
                        AreaMark(x: .value("День", point.day), y: .value("Значение", point.value))
                            .foregroundStyle(Theme.Colors.accent.opacity(0.25))
                        LineMark(x: .value("День", point.day), y: .value("Значение", point.value))
                    case "Кольцо":
                        SectorMark(angle: .value("Значение", point.value), innerRadius: .ratio(0.6), angularInset: 2)
                            .foregroundStyle(by: .value("День", point.day))
                    default:
                        BarMark(x: .value("День", point.day), y: .value("Значение", point.value)).cornerRadius(4)
                    }
                }
                .foregroundStyle(Theme.Colors.accent)
                .frame(height: 240)
                ForEach(ComponentSamples.chart) { point in
                    LabeledContent(point.day, value: point.value.formatted())
                }
            }
        }
    }
}

struct CatalogMediaView: View {
    @State private var photo: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var importer = false
    @State private var fileName = "Файл не выбран"
    @State private var error: String?

    var body: some View {
        CatalogForm {
            Section("Фото") {
                PhotosPicker(selection: $photo, matching: .images) {
                    Label("Выбрать фотографию", systemImage: "photo")
                }
                if let image {
                    Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 220)
                        .accessibilityLabel("Выбранная фотография")
                    Button("Убрать фотографию", role: .destructive) { self.image = nil; photo = nil }
                } else {
                    ContentUnavailableView("Фото не выбрано", systemImage: "photo", description: Text("Выбранное фото показывается только в этом примере."))
                }
            }
            Section("Файлы") {
                Button("Выбрать файл", systemImage: "doc") { importer = true }
                Text(fileName).foregroundStyle(.secondary)
                Text("Показывается только название. Файл не копируется в проект и никуда не отправляется.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Системная отправка") {
                ShareLink(item: "Пример из каталога компонентов SwiftUI") {
                    Label("Поделиться текстом", systemImage: "square.and.arrow.up")
                }
            }
            if let error { Section("Ошибка") { Text(error).foregroundStyle(.red) } }
        }
        .fileImporter(isPresented: $importer, allowedContentTypes: [.image, .pdf, .plainText]) { result in
            switch result {
            case .success(let url): fileName = url.lastPathComponent; error = nil
            case .failure: error = "Не удалось открыть файл. Попробуйте ещё раз."
            }
        }
        .task(id: photo) {
            guard let photo else { return }
            image = nil
            do {
                guard let data = try await photo.loadTransferable(type: Data.self), let selected = UIImage(data: data) else {
                    if !Task.isCancelled { error = "Не удалось прочитать фотографию." }
                    return
                }
                if !Task.isCancelled { image = selected; error = nil }
            } catch {
                if !Task.isCancelled { self.error = "Не удалось загрузить фотографию. Попробуйте ещё раз." }
            }
        }
    }
}
