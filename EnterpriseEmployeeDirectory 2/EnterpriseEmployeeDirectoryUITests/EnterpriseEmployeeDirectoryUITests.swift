import XCTest

final class EnterpriseEmployeeDirectoryUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchesAndShowsOverview() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.navigationBars["Overview"].waitForExistence(timeout: 10),
            "The Overview screen should appear after launch."
        )
        XCTAssertTrue(
            app.staticTexts["Good to see you."].exists,
            "The dashboard greeting should be visible."
        )
    }

    @MainActor
    func testDashboardShowsAnalyticsSections() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Good to see you."].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Departments"].exists)
        XCTAssertTrue(app.staticTexts["Workforce composition"].exists)
        XCTAssertTrue(app.staticTexts["Recently viewed"].exists)
    }

    @MainActor
    func testPeopleTabOpensEmployeeDirectory() {
        let app = XCUIApplication()
        app.launch()

        let peopleTab = app.tabBars.buttons["People"]
        XCTAssertTrue(peopleTab.waitForExistence(timeout: 10))
        peopleTab.tap()

        XCTAssertTrue(app.navigationBars["People"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Employee directory"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.textFields["Search employees"].exists)
    }

    @MainActor
    func testBrowseAllEmployeesOpensDirectory() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Good to see you."].waitForExistence(timeout: 10))

        let browseButton = app.buttons["Browse all employees"]
        if browseButton.exists && !browseButton.isHittable {
            app.swipeUp()
        }

        XCTAssertTrue(browseButton.waitForExistence(timeout: 5))
        browseButton.tap()

        XCTAssertTrue(app.navigationBars["People"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
