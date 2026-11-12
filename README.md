# Список покупок

Прототип приложения для iOS: составьте список перед походом в магазин и отмечайте товары по мере покупки. Результат принят владельцем 2026/11/12.

## Что можно сделать

- Добавить товар с названием и количеством через «+» на нижней панели.
- Отметить товар купленным и вернуть его в список покупок.
- Открыть карточку товара, изменить данные или удалить позицию.
- Добавить первую позицию из пустого списка. Пустое название и одни пробелы не сохраняются.
- Открыть настройки с нижней панели и выбрать тему оформления.

## Данные и границы

При первом запуске доступны демонстрационные товары. Изменения сохраняются на устройстве после закрытия приложения. Регистрация, совместный доступ, синхронизация, сервер и платежи в этот прототип не входят.

## Как попробовать

На Mac откройте `TemplateApp.xcodeproj` в Xcode, выберите схему `TemplateApp`, доступный симулятор iPhone и нажмите Run. Команда ранее показывала прототип на iPhone Air. Готовый установочный файл для физического iPhone не подготовлен.

Начните с кнопки «+»: добавьте товар, укажите количество и отметьте его купленным. Нажмите на название товара, чтобы открыть редактирование.

## Документы

- [Бриф](docs/brief.md) — задача пользователя, возможности и границы.
- [План](docs/plan.md) — этапы работы и полученные результаты.
- [Проверка](docs/review.md) — что проверила команда и как завершена приёмка.
- [Исследование](docs/prototype-research.md) — наблюдения, повлиявшие на интерфейс.

<details>
<summary>Для разработчика</summary>

Приложение использует SwiftUI и исходный шаблон `templates/ios-swiftui`. Минимальная версия системы — iOS 17. Данные сохраняются в UserDefaults. UI-тесты используют отдельный ключ хранения и не сбрасывают демонстрационный список обычного запуска.

Нужны Xcode и установленный симулятор. Команды выполняются из папки проекта. Имя назначения замените на доступное в вашей установке.

### Сборка

```sh
xcodebuild build \
  -project TemplateApp.xcodeproj \
  -scheme TemplateApp \
  -derivedDataPath build \
  -destination 'platform=iOS Simulator,name=iPhone Air' \
  CODE_SIGNING_ALLOWED=NO
```

### Целевые проверки

```sh
# Нижняя панель, добавление и открытие настроек
xcodebuild test \
  -project TemplateApp.xcodeproj \
  -scheme TemplateApp \
  -derivedDataPath build \
  -destination 'platform=iOS Simulator,name=iPhone Air' \
  -only-testing:TemplateAppUITests/ShoppingListUITests/testNavigationControls \
  CODE_SIGNING_ALLOWED=NO

# Основной сценарий и проверка пустого ввода
xcodebuild test \
  -project TemplateApp.xcodeproj \
  -scheme TemplateApp \
  -derivedDataPath build \
  -destination 'platform=iOS Simulator,name=iPhone Air' \
  -only-testing:TemplateAppUITests/ShoppingListUITests/testShoppingListFlow \
  -only-testing:TemplateAppUITests/ShoppingListUITests/testEmptyAndWhitespaceValidation \
  CODE_SIGNING_ALLOWED=NO
```

### Установка на уже запущенный симулятор

```sh
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/TemplateApp.app
xcrun simctl launch booted com.example.TemplateApp
```

Исходники каталога компонентов сохранены. Аргумент запуска `--component-catalog` открывает каталог отдельно от обычного сценария покупок.

</details>
