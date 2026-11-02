import XCTest
@testable import EnterpriseEmployeeDirectory

final class EmployeeDiskCacheTests: XCTestCase {
    func testMissingCacheReturnsNil() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let cache = try EmployeeDiskCache(directory: directory)
        XCTAssertNil(try cache.loadEmployees())
    }

    func testCacheFileIsCreatedAfterSave() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let cache = try EmployeeDiskCache(directory: directory)
        try cache.saveEmployees([])
        XCTAssertNotNil(try cache.loadEmployees())
    }
}
