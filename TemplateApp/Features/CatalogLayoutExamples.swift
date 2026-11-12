import SwiftUI

struct CatalogLayoutView: View {
    @State private var expanded = false
    @State private var page = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                GroupBox("Адаптивная сетка") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: Theme.Spacing.small) {
                        ForEach(1...6, id: \.self) { value in
                            Label("\(value)", systemImage: "square")
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(Theme.Colors.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
                        }
                    }.padding(.top, Theme.Spacing.small)
                }
                GroupBox("Табличное выравнивание") {
                    Grid(alignment: .leading, horizontalSpacing: Theme.Spacing.large, verticalSpacing: Theme.Spacing.small) {
                        GridRow { Text("Товар").bold(); Text("Кол-во").bold(); Text("Цена").bold() }
                        Divider().gridCellColumns(3)
                        GridRow { Text("Яблоки"); Text("2 кг"); Text("1 200 ₸") }
                        GridRow { Text("Кофе"); Text("1 шт"); Text("2 400 ₸") }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                GroupBox("Раскрывающийся блок") {
                    DisclosureGroup("Подробнее", isExpanded: $expanded) {
                        Text("Содержимое раскрывается и сворачивается стандартным действием.")
                            .foregroundStyle(.secondary).padding(.top, Theme.Spacing.small)
                    }
                }
                GroupBox("Горизонтальные карточки") {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: Theme.Spacing.medium) {
                            ForEach(1...5, id: \.self) { value in
                                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                                    Image(systemName: "rectangle.stack").font(.title2)
                                    Text("Карточка \(value)").font(.headline)
                                    Text("Локальный пример").font(.caption).foregroundStyle(.secondary)
                                }
                                .padding(Theme.Spacing.medium).frame(width: 180, alignment: .leading)
                                .modifier(StarterSurface())
                            }
                        }
                    }.scrollIndicators(.hidden)
                }
                GroupBox("Постраничная прокрутка") {
                    TabView(selection: $page) {
                        ForEach(0..<3) { index in
                            VStack(spacing: Theme.Spacing.small) {
                                Image(systemName: ["sparkles", "square.stack", "checkmark.circle"][index]).font(.largeTitle)
                                Text("Страница \(index + 1)")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Theme.Colors.accent.opacity(0.16)).tag(index)
                        }
                    }.tabViewStyle(.page).frame(height: 170)
                    Text("\(page + 1) из 3").font(.caption).foregroundStyle(.secondary)
                }
                GroupBox("Адаптация содержимого") {
                    ViewThatFits(in: .horizontal) {
                        Label("Полное название действия", systemImage: "checkmark.circle")
                        Label("Готово", systemImage: "checkmark.circle")
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }.padding(Theme.Spacing.medium)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.bottom, Theme.tabBarScrollClearance / 2, for: .scrollContent)
    }
}

struct CatalogContentView: View {
    var body: some View {
        CatalogForm {
            Section("Типографика") {
                Text("Крупный заголовок").font(.largeTitle.bold())
                Text("Заголовок раздела").font(.title2.weight(.semibold))
                Text("Основной текст автоматически поддерживает системный размер шрифта.").font(.body)
                Text("Подпись и дополнительная информация").font(.caption).foregroundStyle(.secondary)
                Text("1 234 567").font(.title.monospacedDigit())
                Text("**Жирный**, *курсив* и [ссылка](https://developer.apple.com/swiftui/).")
                Text("Этот текст можно выделить и скопировать.").textSelection(.enabled)
            }
            Section("Символы и подписи") {
                Label("Избранное", systemImage: "star.fill").foregroundStyle(.orange)
                Label("Уведомления", systemImage: "bell.badge")
                HStack(spacing: Theme.Spacing.large) {
                    Image(systemName: "heart.fill").symbolRenderingMode(.multicolor)
                    Image(systemName: "person.crop.circle.fill").symbolRenderingMode(.hierarchical)
                    Image(systemName: "wifi").symbolRenderingMode(.palette).foregroundStyle(.blue, .cyan)
                }.font(.largeTitle).padding(.vertical, Theme.Spacing.small)
            }
            Section("Материалы и формы") {
                ZStack {
                    LinearGradient(colors: [.indigo, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Text("Нативный материал").padding().background(.regularMaterial, in: Capsule())
                }.frame(height: 120).clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.large))
                HStack {
                    Circle().fill(Theme.Colors.accent)
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium).fill(Theme.Colors.green)
                    Capsule().strokeBorder(Theme.Colors.accent, lineWidth: 2)
                }.frame(height: 48).accessibilityLabel("Круг, скруглённый прямоугольник и капсула")
                Divider()
                LabeledContent("Статус", value: "Готово")
            }
        }
    }
}


private enum DemoTab: String, CaseIterable, Identifiable {
    case home, documents, ideas, more
    var id: String { rawValue }
    var title: String {
        switch self { case .home: "Главная"; case .documents: "Документы"; case .ideas: "Идеи"; case .more: "Ещё" }
    }
    var symbol: String {
        switch self { case .home: "house.fill"; case .documents: "doc.text"; case .ideas: "lightbulb"; case .more: "ellipsis" }
    }
}

struct CatalogTabBarsView: View {
    @State private var selected: DemoTab = .home
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                ElasticTabBar(items: DemoTab.allCases.map { tab in
                    ElasticTabItem(id: tab.rawValue, title: tab.title, symbol: tab.symbol, action: { selected = tab })
                }, selectedID: selected.rawValue)
            }.padding(Theme.Spacing.medium)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.bottom, Theme.tabBarScrollClearance / 2, for: .scrollContent)
        .background(Theme.Colors.background)
    }
}


struct CatalogAuthenticationView: View {
    @State private var showEmail = false
    @State private var provider = ""
    @State private var showingDemo = false
    @State private var result = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(Theme.Colors.onPrimary)
                    .frame(width: 72, height: 72)
                    .background(Theme.Colors.adaptive(0x0B0C0C, 0xF7F8F8), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .accessibilityHidden(true)
                Text("Добро пожаловать").font(.system(size: 23, weight: .bold)).foregroundStyle(Theme.Colors.foreground).padding(.top, 22)
                Text("Войдите, чтобы продолжить работу с приложением.")
                    .font(.body).foregroundStyle(Theme.Colors.foreground).fixedSize(horizontal: false, vertical: true).padding(.top, 8)
                VStack(spacing: 10) {
                    Button { provider = "Apple"; showingDemo = true } label: {
                        AuthProviderLabel(title: "Продолжить с Apple", icon: .apple)
                    }.buttonStyle(AuthExampleButton(primary: true))
                    Button { provider = "Google"; showingDemo = true } label: {
                        AuthProviderLabel(title: "Продолжить с Google", icon: .google)
                    }.buttonStyle(AuthExampleButton())
                    Button { showEmail = true } label: {
                        AuthProviderLabel(title: "Войти по почте", icon: .email)
                    }.buttonStyle(AuthExampleButton())
                }.padding(.top, 42)
                if !result.isEmpty { Text(result).font(.caption).foregroundStyle(Theme.Colors.muted).padding(.top, 14) }
            }
            .padding(.horizontal, 24).padding(.top, 26).padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(GlassCard())
            .padding(16)
        }
        .scrollIndicators(.hidden).contentMargins(.bottom, Theme.tabBarScrollClearance / 2, for: .scrollContent)
        .background(Theme.Colors.background)
        .alert("Демонстрация", isPresented: $showingDemo) {
            Button("Понятно", role: .cancel) {}
        } message: {
            Text("Вход через \(provider) показан как пример интерфейса.")
        }
        .sheet(isPresented: $showEmail) {
            AuthEmailExample { result = "Демонстрация завершена"; showEmail = false }
        }
    }
}

private struct AuthProviderLabel: View {
    enum Icon { case apple, google, email }
    let title: String
    let icon: Icon

    var body: some View {
        HStack(spacing: 8) {
            Group {
                switch icon {
                case .apple: Image(systemName: "apple.logo")
                case .google: GoogleProviderMark()
                case .email: Image(systemName: "at")
                }
            }
            .font(.system(size: 18, weight: .semibold))
            .frame(width: 20, height: 20)
            .accessibilityHidden(true)
            Text(title)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
    }
}

private struct GoogleProviderMark: View {
    var body: some View {
        Canvas { context, size in
            let scale = min(size.width, size.height) / 24
            context.scaleBy(x: scale, y: scale)
            func draw(_ color: Color, _ build: (inout Path) -> Void) {
                var path = Path()
                build(&path)
                context.fill(path, with: .color(color))
            }
            draw(Color(red: 66/255, green: 133/255, blue: 244/255)) { p in
                p.move(to: CGPoint(x: 22.56, y: 12.25))
                p.addCurve(to: CGPoint(x: 22.36, y: 10), control1: CGPoint(x: 22.56, y: 11.47), control2: CGPoint(x: 22.49, y: 10.72))
                p.addLine(to: CGPoint(x: 12, y: 10)); p.addLine(to: CGPoint(x: 12, y: 14.26)); p.addLine(to: CGPoint(x: 17.92, y: 14.26))
                p.addCurve(to: CGPoint(x: 15.71, y: 17.57), control1: CGPoint(x: 17.66, y: 15.63), control2: CGPoint(x: 16.88, y: 16.79))
                p.addLine(to: CGPoint(x: 15.71, y: 20.34)); p.addLine(to: CGPoint(x: 19.28, y: 20.34))
                p.addCurve(to: CGPoint(x: 22.56, y: 12.25), control1: CGPoint(x: 21.36, y: 18.42), control2: CGPoint(x: 22.56, y: 15.60)); p.closeSubpath()
            }
            draw(Color(red: 52/255, green: 168/255, blue: 83/255)) { p in
                p.move(to: CGPoint(x: 12, y: 23))
                p.addCurve(to: CGPoint(x: 19.28, y: 20.34), control1: CGPoint(x: 14.97, y: 23), control2: CGPoint(x: 17.46, y: 22.02))
                p.addLine(to: CGPoint(x: 15.71, y: 17.57))
                p.addCurve(to: CGPoint(x: 12, y: 18.64), control1: CGPoint(x: 14.73, y: 18.23), control2: CGPoint(x: 13.48, y: 18.64))
                p.addCurve(to: CGPoint(x: 5.75, y: 14.1), control1: CGPoint(x: 9.13, y: 18.64), control2: CGPoint(x: 6.7, y: 16.7))
                p.addLine(to: CGPoint(x: 2.07, y: 16.94))
                p.addCurve(to: CGPoint(x: 12, y: 23), control1: CGPoint(x: 3.91, y: 20.56), control2: CGPoint(x: 7.67, y: 23)); p.closeSubpath()
            }
            draw(Color(red: 251/255, green: 188/255, blue: 5/255)) { p in
                p.move(to: CGPoint(x: 5.75, y: 14.1))
                p.addCurve(to: CGPoint(x: 5.75, y: 9.9), control1: CGPoint(x: 5.5, y: 13.44), control2: CGPoint(x: 5.5, y: 10.56))
                p.addLine(to: CGPoint(x: 2.07, y: 7.06))
                p.addCurve(to: CGPoint(x: 2.07, y: 16.94), control1: CGPoint(x: 0.64, y: 9.91), control2: CGPoint(x: 0.64, y: 14.09)); p.closeSubpath()
            }
            draw(Color(red: 234/255, green: 67/255, blue: 53/255)) { p in
                p.move(to: CGPoint(x: 12, y: 5.36))
                p.addCurve(to: CGPoint(x: 16.24, y: 7.01), control1: CGPoint(x: 13.62, y: 5.36), control2: CGPoint(x: 15.06, y: 5.92))
                p.addLine(to: CGPoint(x: 19.42, y: 3.83))
                p.addCurve(to: CGPoint(x: 12, y: 1), control1: CGPoint(x: 17.49, y: 2.03), control2: CGPoint(x: 14.97, y: 1))
                p.addCurve(to: CGPoint(x: 2.07, y: 7.06), control1: CGPoint(x: 7.67, y: 1), control2: CGPoint(x: 3.91, y: 3.44))
                p.addLine(to: CGPoint(x: 5.75, y: 9.9))
                p.addCurve(to: CGPoint(x: 12, y: 5.36), control1: CGPoint(x: 6.7, y: 7.3), control2: CGPoint(x: 9.13, y: 5.36)); p.closeSubpath()
            }
        }
    }
}

private struct AuthExampleButton: ButtonStyle {
    var primary = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 18, weight: .medium))
            .foregroundStyle(primary ? Theme.Colors.onPrimary : Theme.Colors.foreground)
            .background {
                Capsule()
                    .fill(primary ? Theme.Colors.adaptive(0x0B0C0C, 0xF7F8F8) : Theme.Colors.cardBackground)
            }
            .overlay(Capsule().strokeBorder(Theme.Colors.border.opacity(primary ? 0 : 0.65)))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

private struct AuthEmailExample: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    let onComplete: () -> Void
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Электронная почта", text: $email).keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never).autocorrectionDisabled().modifier(StarterInput())
                    SecureField("Пароль", text: $password).modifier(StarterInput())
                } footer: {
                    Text("Демонстрация: данные не отправляются и не сохраняются.")
                }
                Button("Продолжить", action: onComplete).disabled(!email.contains("@") || password.isEmpty)
            }
            .navigationTitle("Вход по почте").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } } }
        }.presentationDetents([.medium, .large])
    }
}
