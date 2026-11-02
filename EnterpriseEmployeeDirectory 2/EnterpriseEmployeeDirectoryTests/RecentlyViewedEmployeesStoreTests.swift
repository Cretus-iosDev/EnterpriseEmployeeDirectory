import XCTest
@testable import EnterpriseEmployeeDirectory

final class RecentlyViewedEmployeesStoreTests: XCTestCase {

    private var store: RecentlyViewedEmployeesStore {
        RecentlyViewedEmployeesStore.shared
    }

    override func setUp() {
        super.setUp()
        store.clear()
    }

    override func tearDown() {
        store.clear()
        super.tearDown()
    }

    func testRecordAddsEmployeeToHistory() {
        store.record(employeeID: 101)

        XCTAssertEqual(store.employeeIDs, [101])
    }

    func testNewestEmployeeAppearsFirst() {
        store.record(employeeID: 101)
        store.record(employeeID: 202)
        store.record(employeeID: 303)

        XCTAssertEqual(store.employeeIDs, [303, 202, 101])
    }

    func testRecordingExistingEmployeeMovesItToFrontWithoutDuplicate() {
        store.record(employeeID: 101)
        store.record(employeeID: 202)
        store.record(employeeID: 303)

        store.record(employeeID: 202)

        XCTAssertEqual(store.employeeIDs, [202, 303, 101])
        XCTAssertEqual(store.employeeIDs.filter { $0 == 202 }.count, 1)
    }

    func testHistoryKeepsOnlyLatestTenEmployees() {
        for employeeID in 1...12 {
            store.record(employeeID: employeeID)
        }

        XCTAssertEqual(store.employeeIDs.count, 10)
        XCTAssertEqual(store.employeeIDs, [12, 11, 10, 9, 8, 7, 6, 5, 4, 3])
    }

    func testClearRemovesAllHistory() {
        store.record(employeeID: 101)
        store.record(employeeID: 202)

        store.clear()

        XCTAssertTrue(store.employeeIDs.isEmpty)
    }

    func testHistoryPersistsAcrossStoreReads() {
        store.record(employeeID: 707)
        store.record(employeeID: 808)

        // A second read from the same persistent UserDefaults store
        // should return the saved ordering.
        XCTAssertEqual(RecentlyViewedEmployeesStore.shared.employeeIDs, [808, 707])
    }
}
