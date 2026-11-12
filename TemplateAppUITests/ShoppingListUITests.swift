import XCTest

final class ShoppingListUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "-AppleLanguages", "(ru)",
            "-AppleLocale", "ru_RU",
            "-AppleInterfaceStyle", "Light",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"
        ]
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testShoppingListFlow() throws {
        app.launch()
        
        // Dynamic Type size category verification
        let contentSizeElement = app.otherElements["app_content_size_category"]
        XCTAssertTrue(contentSizeElement.waitForExistence(timeout: 3), "App content size category element must exist")
        XCTAssertEqual(contentSizeElement.value as? String, "UICTContentSizeCategoryL", "Active dynamic type size category must be standard UICTContentSizeCategoryL")
        
        // 1. Initial list state
        let listScrollView = app.scrollViews["shopping_list_scroll_view"]
        XCTAssertTrue(listScrollView.waitForExistence(timeout: 5), "Scroll view should be present")
        
        let initialItem = app.buttons["item_row_Молоко 3.2%"]
        XCTAssertTrue(initialItem.waitForExistence(timeout: 3), "Initial items should load")
        
        takeScreenshot(named: "shopping_list_top")
        
        // 2. Check scrolling, reachability and action of last row above bottom floating bar
        listScrollView.swipeUp()
        
        let lastItem = app.buttons["item_row_Сыр пармезан"]
        XCTAssertTrue(lastItem.waitForExistence(timeout: 3), "Last item should be reachable after scroll")
        XCTAssertTrue(lastItem.isHittable, "Last item must be hittable and not covered by floating tab bar")
        
        let lastItemToggle = app.buttons["item_toggle_Сыр пармезан"]
        XCTAssertTrue(lastItemToggle.isHittable, "Last item toggle button must be hittable")
        lastItemToggle.tap()
        
        let parmesanCompletedBadge = app.staticTexts["item_badge_completed_Сыр пармезан"]
        XCTAssertTrue(parmesanCompletedBadge.waitForExistence(timeout: 2), "Last item action must execute successfully in scrolled bottom position")
        
        takeScreenshot(named: "shopping_list_bottom")
        
        listScrollView.swipeDown()
        
        // 3. Add item with quantity
        let addTabBarButton = app.buttons["tab_item_add"]
        XCTAssertTrue(addTabBarButton.isHittable)
        addTabBarButton.tap()
        
        let titleInput = app.textFields["add_item_title_input"]
        XCTAssertTrue(titleInput.waitForExistence(timeout: 3), "Add item sheet should be presented")
        
        titleInput.tap()
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: 5), "On-screen keyboard must be visible when title field is focused")
        
        takeScreenshot(named: "shopping_list_add_keyboard")
        
        // Verify accessibility of form elements when keyboard is visible
        XCTAssertTrue(titleInput.isHittable, "Title input must remain accessible with keyboard visible")
        let cancelButton = app.buttons["add_item_cancel_button"]
        XCTAssertTrue(cancelButton.exists, "Cancel button should exist with keyboard visible")
        let saveButton = app.buttons["add_item_save_button"]
        XCTAssertTrue(saveButton.exists, "Save button should exist with keyboard visible")
        
        titleInput.typeText("Апельсины")
        
        let preset3 = app.buttons["add_item_preset_3"]
        XCTAssertTrue(preset3.waitForExistence(timeout: 2))
        preset3.tap()
        
        XCTAssertTrue(saveButton.isHittable)
        saveButton.tap()
        
        // 4. Appearance of row
        let addedItemRow = app.buttons["item_row_Апельсины"]
        XCTAssertTrue(addedItemRow.waitForExistence(timeout: 3), "Added item should appear at the top of the list")
        XCTAssertTrue(app.staticTexts["Кол-во: 3 шт."].exists, "Quantity 3 should be displayed")
        
        // 5. Checkmark toggle and toggle back
        let toggleButton = app.buttons["item_toggle_Апельсины"]
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 2))
        toggleButton.tap()
        
        let completedBadge = app.staticTexts["item_badge_completed_Апельсины"]
        XCTAssertTrue(completedBadge.waitForExistence(timeout: 3), "Completed badge should appear for Апельсины")
        XCTAssertEqual(toggleButton.label, "Отметить некупленным: Апельсины")
        
        toggleButton.tap()
        
        let notCompletedPredicate = NSPredicate(format: "exists == false")
        expectation(for: notCompletedPredicate, evaluatedWith: completedBadge, handler: nil)
        waitForExpectations(timeout: 3)
        XCTAssertEqual(toggleButton.label, "Отметить купленным: Апельсины")
        
        // 6. Open detail card
        addedItemRow.tap()
        
        let detailTitleInput = app.textFields["detail_title_input"]
        XCTAssertTrue(detailTitleInput.waitForExistence(timeout: 3), "Detail card should be opened")
        XCTAssertEqual(detailTitleInput.value as? String, "Апельсины")
        
        takeScreenshot(named: "shopping_list_card")
        
        // 7. Reset draft
        detailTitleInput.tap()
        detailTitleInput.typeText(" черновик")
        
        let revertButton = app.buttons["detail_revert_button"]
        XCTAssertTrue(revertButton.isEnabled, "Revert button should be enabled after edits")
        revertButton.tap()
        
        XCTAssertEqual(detailTitleInput.value as? String, "Апельсины", "Title should revert to saved value")
        
        // 8. Save title and quantity
        detailTitleInput.tap()
        if let currentText = detailTitleInput.value as? String, !currentText.isEmpty {
            let deleteKeys = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentText.count + 5)
            detailTitleInput.typeText(deleteKeys)
        }
        detailTitleInput.typeText("Спелые апельсины")
        
        let detailPreset5 = app.buttons["detail_preset_5"]
        detailPreset5.tap()
        
        let detailSaveButton = app.buttons["detail_save_button"]
        XCTAssertTrue(detailSaveButton.isEnabled)
        detailSaveButton.tap()
        
        // Verify in list
        let updatedRow = app.buttons["item_row_Спелые апельсины"]
        XCTAssertTrue(updatedRow.waitForExistence(timeout: 3), "Updated item title should appear in list")
        XCTAssertTrue(app.staticTexts["Кол-во: 5 шт."].exists, "Updated quantity should appear in list")
        
        // 9. Delete items and transition to empty state
        let allTitles = [
            "Спелые апельсины",
            "Молоко 3.2%",
            "Свежий багет",
            "Красные яблоки",
            "Зерновой кофе",
            "Овсяные хлопья",
            "Греческий йогурт",
            "Томаты черри",
            "Сыр пармезан"
        ]
        for title in allTitles {
            let deleteBtn = app.buttons["item_delete_\(title)"]
            if deleteBtn.waitForExistence(timeout: 2) {
                deleteBtn.tap()
            }
        }
        
        let emptyTitle = app.staticTexts["empty_state_title"]
        XCTAssertTrue(emptyTitle.waitForExistence(timeout: 3), "Empty state title should appear")
        XCTAssertEqual(emptyTitle.label, "Список пуст")
        
        takeScreenshot(named: "shopping_list_empty")
        
        // 10. Working add button from empty state
        let emptyAddButton = app.buttons["empty_state_add_button"]
        XCTAssertTrue(emptyAddButton.waitForExistence(timeout: 2))
        XCTAssertTrue(emptyAddButton.isHittable)
        emptyAddButton.tap()
        
        let newTitleInput = app.textFields["add_item_title_input"]
        XCTAssertTrue(newTitleInput.waitForExistence(timeout: 3))
        newTitleInput.tap()
        newTitleInput.typeText("Свежий хлеб")
        
        let newSaveButton = app.buttons["add_item_save_button"]
        newSaveButton.tap()
        
        let freshBreadRow = app.buttons["item_row_Свежий хлеб"]
        XCTAssertTrue(freshBreadRow.waitForExistence(timeout: 3), "New item added from empty state should appear in list")
        XCTAssertFalse(emptyTitle.exists, "Empty state should disappear")
    }
    
    func testEmptyAndWhitespaceValidation() throws {
        app.launch()
        
        // Dynamic Type size category verification
        let contentSizeElement = app.otherElements["app_content_size_category"]
        XCTAssertTrue(contentSizeElement.waitForExistence(timeout: 3), "App content size category element must exist")
        XCTAssertEqual(contentSizeElement.value as? String, "UICTContentSizeCategoryL", "Active dynamic type size category must be standard UICTContentSizeCategoryL")
        
        let addTabBarButton = app.buttons["tab_item_add"]
        XCTAssertTrue(addTabBarButton.waitForExistence(timeout: 5))
        addTabBarButton.tap()
        
        let titleInput = app.textFields["add_item_title_input"]
        XCTAssertTrue(titleInput.waitForExistence(timeout: 3))
        
        let saveButton = app.buttons["add_item_save_button"]
        XCTAssertTrue(saveButton.isHittable)
        
        // 1. Attempt to save empty title
        saveButton.tap()
        
        let errorMessage = app.staticTexts["add_item_error_message"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 2), "Error explanation must be visible for empty title")
        XCTAssertEqual(errorMessage.label, "Название не может быть пустым или состоять только из пробелов.")
        XCTAssertTrue(titleInput.exists, "Add sheet must remain open when validation fails")
        
        takeScreenshot(named: "shopping_list_input_error")
        
        // 2. Attempt to save whitespace title
        titleInput.tap()
        titleInput.typeText("     ")
        saveButton.tap()
        
        XCTAssertTrue(errorMessage.exists, "Error message must remain for whitespace-only title")
        XCTAssertTrue(titleInput.exists, "Sheet must remain open for whitespace-only title")
        
        // 3. Successful correction of input
        titleInput.tap()
        let deleteKeys = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 10)
        titleInput.typeText(deleteKeys)
        titleInput.typeText("Спелое манго")
        saveButton.tap()
        
        let mangoRow = app.buttons["item_row_Спелое манго"]
        XCTAssertTrue(mangoRow.waitForExistence(timeout: 3), "Valid title must be successfully added after correction")
        
        XCTAssertFalse(app.buttons["item_row_"].exists, "No blank row should be created")
        XCTAssertFalse(app.buttons["item_row_     "].exists, "No whitespace row should be created")
    }
    
    func testNavigationControls() throws {
        app.launch()
        
        // 1. Dynamic Type size category verification (UICTContentSizeCategoryL)
        let contentSizeElement = app.otherElements["app_content_size_category"]
        XCTAssertTrue(contentSizeElement.waitForExistence(timeout: 3), "App content size category element must exist")
        XCTAssertEqual(contentSizeElement.value as? String, "UICTContentSizeCategoryL", "Active dynamic type size category must be standard UICTContentSizeCategoryL")
        
        // 2. Absence of top toolbar buttons (add and settings removed from header)
        XCTAssertFalse(app.buttons["list_add_button_toolbar"].exists, "Top toolbar add button must not exist")
        XCTAssertFalse(app.buttons["list_settings_button_toolbar"].exists, "Top toolbar settings button must not exist")
        
        // 3. Verification of bottom tab bar items
        XCTAssertTrue(app.buttons["tab_item_list"].exists, "List button must exist in bottom bar")
        let addTabBarButton = app.buttons["tab_item_add"]
        XCTAssertTrue(addTabBarButton.exists, "Add button (+) must exist in bottom bar")
        let settingsTabBarButton = app.buttons["tab_item_settings"]
        XCTAssertTrue(settingsTabBarButton.exists, "Settings button must exist in bottom bar")
        XCTAssertFalse(app.buttons["tab_item_components"].exists, "Components button must not exist in bottom bar")
        
        takeScreenshot(named: "shopping_list_navigation_controls")
        
        // 4. Verify scrolling, reachability and real action of last row above bottom floating bar
        let listScrollView = app.scrollViews["shopping_list_scroll_view"]
        XCTAssertTrue(listScrollView.waitForExistence(timeout: 5), "Scroll view should be present")
        listScrollView.swipeUp()
        
        let lastItem = app.buttons["item_row_Сыр пармезан"]
        XCTAssertTrue(lastItem.waitForExistence(timeout: 3), "Last item should be reachable after scroll")
        XCTAssertTrue(lastItem.isHittable, "Last item must be hittable and not covered by floating tab bar")
        
        let lastItemToggle = app.buttons["item_toggle_Сыр пармезан"]
        XCTAssertTrue(lastItemToggle.isHittable, "Last item toggle button must be hittable")
        lastItemToggle.tap()
        
        let parmesanCompletedBadge = app.staticTexts["item_badge_completed_Сыр пармезан"]
        XCTAssertTrue(parmesanCompletedBadge.waitForExistence(timeout: 2), "Last item action must execute successfully in scrolled bottom position")
        
        takeScreenshot(named: "shopping_list_last_row_above_tabbar")
        
        listScrollView.swipeDown()
        
        // 5. Test "+" button: opens add sheet, adding item with row verification
        XCTAssertTrue(addTabBarButton.isHittable, "Add button (+) must be hittable")
        addTabBarButton.tap()
        
        let titleInput = app.textFields["add_item_title_input"]
        XCTAssertTrue(titleInput.waitForExistence(timeout: 3), "Add item sheet should be presented by + button")
        titleInput.tap()
        titleInput.typeText("Черника")
        
        let saveButton = app.buttons["add_item_save_button"]
        XCTAssertTrue(saveButton.isHittable, "Save button in add sheet must be hittable")
        saveButton.tap()
        
        let addedItemRow = app.buttons["item_row_Черника"]
        XCTAssertTrue(addedItemRow.waitForExistence(timeout: 3), "Added item 'Черника' should appear in the list")
        
        // 6. Test Settings button: opens Settings sheet, closes, and returns to list
        XCTAssertTrue(settingsTabBarButton.isHittable, "Settings button in bottom bar must be hittable")
        settingsTabBarButton.tap()
        
        let settingsHeader = app.staticTexts["Настройки"]
        XCTAssertTrue(settingsHeader.waitForExistence(timeout: 3), "Settings sheet must open")
        
        takeScreenshot(named: "shopping_list_settings_opened")
        
        let closeButton = app.buttons["settings_close_button"].exists ? app.buttons["settings_close_button"] : app.buttons["Закрыть"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 2), "Settings close button must exist")
        closeButton.tap()
        
        // Verify return to list
        let settingsDismissPredicate = NSPredicate(format: "exists == false")
        expectation(for: settingsDismissPredicate, evaluatedWith: settingsHeader, handler: nil)
        waitForExpectations(timeout: 3)
        
        XCTAssertTrue(addedItemRow.exists, "User must return to the shopping list after closing settings sheet")
        takeScreenshot(named: "shopping_list_returned_after_settings")
    }
    
    private func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
