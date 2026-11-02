import XCTest

final class EmployeeDirectorySearchAndProfileUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSearchFindsAnEmployeeByFirstName() {
        let app = XCUIApplication()
        app.launch()

        let peopleTab = app.tabBars.buttons["People"]
        XCTAssertTrue(peopleTab.waitForExistence(timeout: 10))
        peopleTab.tap()

        let firstCell = app.tables.firstMatch.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))

        // Read a real employee name from the loaded directory instead of
        // depending on a hard-coded API record.
        let nameLabel = firstCell.staticTexts.firstMatch
        XCTAssertTrue(nameLabel.exists)

        let displayedName = nameLabel.label
        let firstName = displayedName.split(separator: " ").first.map(String.init) ?? displayedName
        XCTAssertFalse(firstName.isEmpty)

        let searchField = app.textFields["Search employees"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText(firstName)

        XCTAssertTrue(
            app.staticTexts[displayedName].waitForExistence(timeout: 15),
            "The employee used for the search should appear in the results."
        )
    }

    @MainActor
    func testClearingSearchRestoresDirectoryResults() {
        let app = XCUIApplication()
        app.launch()

        let peopleTab = app.tabBars.buttons["People"]
        XCTAssertTrue(peopleTab.waitForExistence(timeout: 10))
        peopleTab.tap()

        let firstCell = app.tables.firstMatch.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))

        let displayedName = firstCell.staticTexts.firstMatch.label
        let firstName = displayedName.split(separator: " ").first.map(String.init) ?? displayedName

        let searchField = app.textFields["Search employees"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText(firstName)

        XCTAssertTrue(app.staticTexts[displayedName].waitForExistence(timeout: 15))

        // Clear the entered query using the keyboard, then submit so the
        // controller immediately applies the empty search.
        searchField.tap()
        let deleteSequence = String(
            repeating: XCUIKeyboardKey.delete.rawValue,
            count: firstName.count
        )
        searchField.typeText(deleteSequence)
        searchField.typeText(XCUIKeyboardKey.return.rawValue)

        XCTAssertTrue(
            app.staticTexts[displayedName].waitForExistence(timeout: 15),
            "The directory should show the employee again after clearing search."
        )
    }

    @MainActor
    func testSelectingEmployeeOpensProfileAndBackReturnsToDirectory() {
        let app = XCUIApplication()
        app.launch()

        let peopleTab = app.tabBars.buttons["People"]
        XCTAssertTrue(peopleTab.waitForExistence(timeout: 10))
        peopleTab.tap()

        let firstCell = app.tables.firstMatch.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))

        let employeeName = firstCell.staticTexts.firstMatch.label
        XCTAssertFalse(employeeName.isEmpty)
        firstCell.tap()

        XCTAssertTrue(
            app.navigationBars["Employee Profile"].waitForExistence(timeout: 10),
            "Selecting an employee should open the Employee Profile screen."
        )

        XCTAssertTrue(
            app.staticTexts[employeeName].waitForExistence(timeout: 10),
            "The profile should display the selected employee's name."
        )

        let backButton = app.navigationBars.buttons["People"]
        XCTAssertTrue(backButton.exists)
        backButton.tap()

        XCTAssertTrue(
            app.navigationBars["People"].waitForExistence(timeout: 10),
            "The back action should return to the employee directory."
        )
    }

    @MainActor
    func testOpenedEmployeeAppearsInRecentlyViewed() {
        let app = XCUIApplication()
        app.launch()

        let peopleTab = app.tabBars.buttons["People"]
        XCTAssertTrue(peopleTab.waitForExistence(timeout: 10))
        peopleTab.tap()

        let firstCell = app.tables.firstMatch.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))

        let employeeName = firstCell.staticTexts.firstMatch.label
        XCTAssertFalse(employeeName.isEmpty)
        firstCell.tap()

        XCTAssertTrue(
            app.navigationBars["Employee Profile"].waitForExistence(timeout: 10)
        )

        let backButton = app.navigationBars.buttons["People"]
        XCTAssertTrue(backButton.exists)
        backButton.tap()

        let overviewTab = app.tabBars.buttons["Overview"]
        XCTAssertTrue(overviewTab.waitForExistence(timeout: 10))
        overviewTab.tap()

        // Recently viewed is below the dashboard analytics, so scroll to it.
        let recentEmployee = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", employeeName)
        ).firstMatch

        if !recentEmployee.exists {
            app.swipeUp()
        }

        XCTAssertTrue(
            recentEmployee.waitForExistence(timeout: 10),
            "The employee opened from the directory should appear in Recently viewed."
        )
    }
}
