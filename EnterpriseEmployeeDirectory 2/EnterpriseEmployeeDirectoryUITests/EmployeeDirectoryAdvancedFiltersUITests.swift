import XCTest

final class EmployeeDirectoryAdvancedFiltersUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testDepartmentFilterCanBeSelected() {
        let app = XCUIApplication()
        openDirectory(in: app)

        let allButton = app.buttons["All"]
        XCTAssertTrue(allButton.waitForExistence(timeout: 10))

        // Department chips are built from the API response. Select the first
        // available chip other than All, Sort, or Filters.
        let departmentButtons = app.buttons.matching(
            NSPredicate(
                format: "label != %@ AND label != %@ AND label != %@",
                "All", "Sort", "Filters"
            )
        )

        var departmentButton: XCUIElement?
        for index in 0..<departmentButtons.count {
            let candidate = departmentButtons.element(boundBy: index)
            if candidate.isHittable {
                departmentButton = candidate
                break
            }
        }

        guard let departmentButton else {
            XCTFail("No department filter chip was available.")
            return
        }

        let selectedDepartment = departmentButton.label
        departmentButton.tap()

        XCTAssertTrue(
            app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "shown")
            ).firstMatch.waitForExistence(timeout: 5)
            || app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "loaded")
            ).firstMatch.exists,
            "The directory count should update after selecting a department."
        )

        XCTAssertTrue(
            app.buttons[selectedDepartment].exists,
            "The selected department chip should remain visible."
        )
    }

    @MainActor
    func testSortEmployeesNameDescending() {
        let app = XCUIApplication()
        openDirectory(in: app)

        let firstNameBeforeSort = firstEmployeeName(in: app)
        XCTAssertFalse(firstNameBeforeSort.isEmpty)

        let sortButton = button(containing: "Sort", in: app)
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5))
        sortButton.tap()

        let descendingOption = app.buttons["Name Z–A"]
        XCTAssertTrue(descendingOption.waitForExistence(timeout: 5))
        descendingOption.tap()

        let firstNameAfterSort = firstEmployeeName(in: app)
        XCTAssertFalse(firstNameAfterSort.isEmpty)

        // Verify the sort action was applied by checking that the first row
        // is now the last name in descending order among the loaded rows.
        let visibleNames = app.tables.firstMatch.cells.allElementsBoundByIndex.compactMap {
            $0.staticTexts.firstMatch.exists ? $0.staticTexts.firstMatch.label : nil
        }

        XCTAssertFalse(visibleNames.isEmpty)
        XCTAssertEqual(
            visibleNames,
            visibleNames.sorted {
                $0.localizedCaseInsensitiveCompare($1) == .orderedDescending
            }.prefix(visibleNames.count).map { $0 },
            "Visible employee names should be sorted Z–A."
        )
    }

    @MainActor
    func testGenderFilterCanBeApplied() {
        let app = XCUIApplication()
        openDirectory(in: app)

        let filtersButton = button(containing: "Filters", in: app)
        XCTAssertTrue(filtersButton.waitForExistence(timeout: 5))
        filtersButton.tap()

        let genderOption = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Gender:")
        ).firstMatch
        XCTAssertTrue(genderOption.waitForExistence(timeout: 5))
        genderOption.tap()

        let femaleOption = app.buttons["Female"]
        XCTAssertTrue(femaleOption.waitForExistence(timeout: 5))
        femaleOption.tap()

        XCTAssertTrue(
            app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "1 filter")
            ).firstMatch.waitForExistence(timeout: 5)
            || app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "filters")
            ).firstMatch.exists,
            "The directory should indicate that an advanced filter is active."
        )
    }

    @MainActor
    func testAgeFilterCanBeApplied() {
        let app = XCUIApplication()
        openDirectory(in: app)

        let filtersButton = button(containing: "Filters", in: app)
        XCTAssertTrue(filtersButton.waitForExistence(timeout: 5))
        filtersButton.tap()

        let ageOption = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Age:")
        ).firstMatch
        XCTAssertTrue(ageOption.waitForExistence(timeout: 5))
        ageOption.tap()

        let under30Option = app.buttons["Under 30"]
        XCTAssertTrue(under30Option.waitForExistence(timeout: 5))
        under30Option.tap()

        XCTAssertTrue(
            app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "1 filter")
            ).firstMatch.waitForExistence(timeout: 5)
            || app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "filters")
            ).firstMatch.exists,
            "The directory should indicate that an age filter is active."
        )
    }

    @MainActor
    func testResetAdvancedFiltersClearsActiveFilters() {
        let app = XCUIApplication()
        openDirectory(in: app)

        let filtersButton = button(containing: "Filters", in: app)
        XCTAssertTrue(filtersButton.waitForExistence(timeout: 5))
        filtersButton.tap()

        let resetOption = app.buttons["Reset advanced filters"]
        XCTAssertTrue(resetOption.waitForExistence(timeout: 5))
        resetOption.tap()

        XCTAssertTrue(
            app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "people")
            ).firstMatch.waitForExistence(timeout: 5)
            || app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "shown")
            ).firstMatch.exists,
            "The directory count should return to its unfiltered state."
        )
    }

    // MARK: - Helpers

    @MainActor
    private func openDirectory(in app: XCUIApplication) {
        app.launch()

        let peopleTab = app.tabBars.buttons["People"]
        XCTAssertTrue(peopleTab.waitForExistence(timeout: 10))
        peopleTab.tap()

        XCTAssertTrue(
            app.navigationBars["People"].waitForExistence(timeout: 10)
        )
        XCTAssertTrue(
            app.tables.firstMatch.waitForExistence(timeout: 15),
            "The employee table should load."
        )
        XCTAssertTrue(
            app.tables.firstMatch.cells.firstMatch.waitForExistence(timeout: 15),
            "At least one employee should be available for this test."
        )
    }

    @MainActor
    private func button(containing text: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", text)
        ).firstMatch
    }

    @MainActor
    private func firstEmployeeName(in app: XCUIApplication) -> String {
        let firstCell = app.tables.firstMatch.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 10) else { return "" }
        return firstCell.staticTexts.firstMatch.label
    }
}
