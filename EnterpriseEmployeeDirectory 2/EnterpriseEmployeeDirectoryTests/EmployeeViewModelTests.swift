import XCTest
@testable import EnterpriseEmployeeDirectory

// MARK: - Dashboard ViewModel Tests

@MainActor
final class DashboardViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        RecentlyViewedEmployeesStore.shared.clear()
    }

    override func tearDown() {
        RecentlyViewedEmployeesStore.shared.clear()
        super.tearDown()
    }

    func testLoadDashboardCalculatesEmployeeAndDepartmentMetrics() async {
        let employees = [
            makeEmployee(id: 1, department: "Engineering", gender: "male", age: 30),
            makeEmployee(id: 2, department: "Engineering", gender: "female", age: 40),
            makeEmployee(id: 3, department: "Human Resources", gender: "female", age: 20),
            makeEmployee(id: 4, department: " ", gender: nil, age: nil)
        ]
        let viewModel = DashboardViewModel(
            service: MockEmployeeService(employees: employees)
        )

        viewModel.loadDashboard()
        await waitUntil { if case .loaded = viewModel.state { return true }; return false }

        XCTAssertEqual(viewModel.totalEmployees, 4)
        XCTAssertEqual(viewModel.employees.count, 4)
        XCTAssertEqual(viewModel.departments.map(\.name), ["Engineering", "Human Resources"])
        XCTAssertEqual(viewModel.departments.map(\.count), [2, 1])
    }

    func testLoadDashboardCalculatesGenderDistributionAndAverageAge() async {
        let employees = [
            makeEmployee(id: 1, gender: "male", age: 30),
            makeEmployee(id: 2, gender: "female", age: 40),
            makeEmployee(id: 3, gender: "female", age: 20),
            makeEmployee(id: 4, gender: nil, age: nil),
            makeEmployee(id: 5, gender: "male", age: 0)
        ]
        let viewModel = DashboardViewModel(
            service: MockEmployeeService(employees: employees)
        )

        viewModel.loadDashboard()
        await waitUntil { if case .loaded = viewModel.state { return true }; return false }

        XCTAssertEqual(viewModel.genderDistribution.map(\.name), ["Female", "Male", "Unknown"])
        XCTAssertEqual(viewModel.genderDistribution.map(\.count), [2, 2, 1])
        XCTAssertEqual(viewModel.employeesWithAgeCount, 3)
        XCTAssertEqual(viewModel.averageAge, 30.0)
    }

    func testAverageAgeIsNilWhenNoValidAgesExist() async {
        let employees = [
            makeEmployee(id: 1, age: nil),
            makeEmployee(id: 2, age: 0),
            makeEmployee(id: 3, age: -5)
        ]
        let viewModel = DashboardViewModel(
            service: MockEmployeeService(employees: employees)
        )

        viewModel.loadDashboard()
        await waitUntil { if case .loaded = viewModel.state { return true }; return false }

        XCTAssertNil(viewModel.averageAge)
        XCTAssertEqual(viewModel.employeesWithAgeCount, 0)
    }

    func testEmployeeLookupReturnsMatchingEmployee() async {
        let employees = [
            makeEmployee(id: 11),
            makeEmployee(id: 22)
        ]
        let viewModel = DashboardViewModel(
            service: MockEmployeeService(employees: employees)
        )

        viewModel.loadDashboard()
        await waitUntil { if case .loaded = viewModel.state { return true }; return false }

        XCTAssertEqual(viewModel.employee(withID: 22)?.id, 22)
        XCTAssertNil(viewModel.employee(withID: 999))
    }

    func testRecentlyViewedEmployeesFollowSavedHistoryOrder() async {
        let employees = [
            makeEmployee(id: 11),
            makeEmployee(id: 22),
            makeEmployee(id: 33)
        ]
        let viewModel = DashboardViewModel(
            service: MockEmployeeService(employees: employees)
        )

        RecentlyViewedEmployeesStore.shared.record(employeeID: 11)
        RecentlyViewedEmployeesStore.shared.record(employeeID: 33)
        RecentlyViewedEmployeesStore.shared.record(employeeID: 22)

        viewModel.loadDashboard()
        await waitUntil { if case .loaded = viewModel.state { return true }; return false }

        XCTAssertEqual(
            viewModel.recentlyViewedEmployees.map(\.id),
            [22, 33, 11]
        )
    }

    func testRecentlyViewedEmployeesIgnoreIDsNotInDashboardResults() async {
        let viewModel = DashboardViewModel(
            service: MockEmployeeService(employees: [makeEmployee(id: 11)])
        )

        RecentlyViewedEmployeesStore.shared.record(employeeID: 11)
        RecentlyViewedEmployeesStore.shared.record(employeeID: 999)

        viewModel.loadDashboard()
        await waitUntil { if case .loaded = viewModel.state { return true }; return false }

        XCTAssertEqual(viewModel.recentlyViewedEmployees.map(\.id), [11])
    }

    func testDashboardFailureSetsFailedState() async {
        let viewModel = DashboardViewModel(
            service: MockEmployeeService(error: MockServiceError.expected)
        )

        viewModel.loadDashboard()
        await waitUntil {
            if case .failed = viewModel.state { return true }
            return false
        }

        if case .failed(let message) = viewModel.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected dashboard state to be failed.")
        }
    }
}

// MARK: - Directory ViewModel Tests

@MainActor
final class EmployeeDirectoryViewModelTests: XCTestCase {

    func testLoadInitialLoadsFirstPageAndDepartments() async {
        let employees = makeEmployees(count: 25)
        let service = MockEmployeeService(employees: employees)
        let viewModel = EmployeeDirectoryViewModel(
            service: service,
            cache: nil
        )

        viewModel.loadInitial()

        await waitUntil {
            if case .loaded = viewModel.state {
                return viewModel.employees.count == 20 && !viewModel.departments.isEmpty
            }
            return false
        }

        XCTAssertEqual(viewModel.employees.count, 20)
        XCTAssertEqual(viewModel.totalCount, 25)
        XCTAssertTrue(viewModel.hasMore)
        XCTAssertEqual(viewModel.departments, ["Engineering", "Human Resources"])
    }

    func testSearchTrimsWhitespaceAndLoadsMatchingEmployees() async {
        let employees = [
            makeEmployee(id: 1, firstName: "Aarav", department: "Engineering"),
            makeEmployee(id: 2, firstName: "Mira", department: "Design")
        ]
        let viewModel = EmployeeDirectoryViewModel(
            service: MockEmployeeService(employees: employees),
            cache: nil
        )

        viewModel.search("  Aarav  ")

        await waitUntil {
            if case .loaded = viewModel.state {
                return viewModel.employees.count == 1
            }
            return false
        }

        XCTAssertTrue(viewModel.isSearching)
        XCTAssertEqual(viewModel.employees.map(\.firstName), ["Aarav"])
    }

    func testEmptySearchClearsSearchMode() async {
        let employees = [
            makeEmployee(id: 1, firstName: "Aarav"),
            makeEmployee(id: 2, firstName: "Mira")
        ]
        let viewModel = EmployeeDirectoryViewModel(
            service: MockEmployeeService(employees: employees),
            cache: nil
        )

        viewModel.search("Aarav")
        await waitUntil {
            if case .loaded = viewModel.state { return viewModel.employees.count == 1 }
            return false
        }

        viewModel.search("   ")
        await waitUntil {
            if case .loaded = viewModel.state { return viewModel.employees.count == 2 }
            return false
        }

        XCTAssertFalse(viewModel.isSearching)
        XCTAssertEqual(viewModel.employees.count, 2)
    }

    func testPaginationLoadsNextPage() async {
        let employees = makeEmployees(count: 45)
        let viewModel = EmployeeDirectoryViewModel(
            service: MockEmployeeService(employees: employees),
            cache: nil
        )

        viewModel.loadInitial()
        await waitUntil {
            if case .loaded = viewModel.state { return viewModel.employees.count == 20 }
            return false
        }

        viewModel.loadMoreIfNeeded(currentItem: 16)
        await waitUntil {
            if case .loaded = viewModel.state { return viewModel.employees.count == 40 }
            return false
        }

        XCTAssertEqual(viewModel.employees.count, 40)
        XCTAssertEqual(viewModel.totalCount, 45)
        XCTAssertTrue(viewModel.hasMore)
    }

    func testPaginationDoesNotAppendDuplicateEmployeeIDs() async {
        let firstPage = makeEmployees(count: 20)
        let secondPage = Array(firstPage.suffix(5)) + (21...35).map {
            makeEmployee(id: $0)
        }
        let service = MockEmployeeService(
            employees: firstPage + secondPage,
            pageOverrides: [20: secondPage]
        )
        let viewModel = EmployeeDirectoryViewModel(service: service, cache: nil)

        viewModel.loadInitial()
        await waitUntil {
            if case .loaded = viewModel.state { return viewModel.employees.count == 20 }
            return false
        }

        viewModel.loadMoreIfNeeded(currentItem: 16)
        await waitUntil {
            if case .loaded = viewModel.state { return viewModel.employees.count == 35 }
            return false
        }

        let ids = viewModel.employees.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
        XCTAssertEqual(viewModel.employees.count, 35)
    }

    func testLoadInitialFallsBackToCacheWhenServiceFails() async {
        let cachedEmployees = [
            makeEmployee(id: 700),
            makeEmployee(id: 701)
        ]
        let cache = MockEmployeeCache(employees: cachedEmployees)
        let viewModel = EmployeeDirectoryViewModel(
            service: MockEmployeeService(error: MockServiceError.expected),
            cache: cache
        )

        viewModel.loadInitial()
        await waitUntil {
            if case .loaded = viewModel.state { return viewModel.isShowingCachedData }
            return false
        }

        XCTAssertEqual(viewModel.employees.map(\.id), [700, 701])
        XCTAssertEqual(viewModel.totalCount, 2)
        XCTAssertTrue(viewModel.isShowingCachedData)
    }

    func testLoadInitialSetsFailedStateWhenServiceAndCacheAreUnavailable() async {
        let viewModel = EmployeeDirectoryViewModel(
            service: MockEmployeeService(error: MockServiceError.expected),
            cache: nil
        )

        viewModel.loadInitial()
        await waitUntil {
            if case .failed = viewModel.state { return true }
            return false
        }

        if case .failed(let message) = viewModel.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected directory state to be failed.")
        }
    }

    func testSuccessfulUnfilteredLoadSavesEmployeesToCache() async {
        let cache = MockEmployeeCache()
        let viewModel = EmployeeDirectoryViewModel(
            service: MockEmployeeService(employees: makeEmployees(count: 20)),
            cache: cache
        )

        viewModel.loadInitial()
        await waitUntil {
            if case .loaded = viewModel.state { return viewModel.employees.count == 20 }
            return false
        }

        XCTAssertEqual(cache.savedEmployees?.count, 20)
    }

    func testSearchResultsAreNotSavedToUnfilteredCache() async {
        let cache = MockEmployeeCache()
        let employees = [
            makeEmployee(id: 1, firstName: "Aarav"),
            makeEmployee(id: 2, firstName: "Mira")
        ]
        let viewModel = EmployeeDirectoryViewModel(
            service: MockEmployeeService(employees: employees),
            cache: cache
        )

        viewModel.search("Aarav")
        await waitUntil {
            if case .loaded = viewModel.state { return viewModel.employees.count == 1 }
            return false
        }

        XCTAssertNil(cache.savedEmployees)
    }
}

// MARK: - Test Doubles

private enum MockServiceError: Error {
    case expected
}

private actor MockEmployeeService: EmployeeServicing {

    private let employees: [Employee]
    private let error: (any Error)?
    private let pageOverrides: [Int: [Employee]]

    init(
        employees: [Employee] = [],
        error: (any Error)? = nil,
        pageOverrides: [Int: [Employee]] = [:]
    ) {
        self.employees = employees
        self.error = error
        self.pageOverrides = pageOverrides
    }

    func fetchEmployees(
        skip: Int,
        limit: Int,
        search: String? = nil
    ) async throws -> EmployeeResponse {
        if let error {
            throw error
        }

        let matchingEmployees: [Employee]
        if let search, !search.isEmpty {
            matchingEmployees = employees.filter {
                $0.fullName.localizedCaseInsensitiveContains(search)
            }
        } else {
            matchingEmployees = employees
        }

        let page: [Employee]
        if let override = pageOverrides[skip] {
            page = Array(override.prefix(limit))
        } else if skip >= matchingEmployees.count {
            page = []
        } else {
            page = Array(matchingEmployees.dropFirst(skip).prefix(limit))
        }

        return EmployeeResponse(
            users: page,
            total: matchingEmployees.count,
            skip: skip,
            limit: limit
        )
    }
}

private final class MockEmployeeCache: EmployeeCaching {

    private(set) var savedEmployees: [Employee]?
    private let cachedEmployees: [Employee]?

    init(employees: [Employee]? = nil) {
        self.cachedEmployees = employees
    }

    func loadEmployees() throws -> [Employee]? {
        cachedEmployees
    }

    func saveEmployees(_ employees: [Employee]) throws {
        savedEmployees = employees
    }
}

// MARK: - Fixtures and Async Helpers

@MainActor
private func waitUntil(
    timeoutIterations: Int = 200,
    condition: () -> Bool
) async {
    for _ in 0..<timeoutIterations {
        if condition() {
            return
        }
        try? await Task.sleep(nanoseconds: 10_000_000)
    }
    XCTFail("Timed out waiting for the ViewModel to finish its asynchronous work.")
}

private func makeEmployees(count: Int) -> [Employee] {
    (1...count).map { id in
        makeEmployee(
            id: id,
            firstName: "Employee\(id)",
            department: id.isMultiple(of: 2) ? "Engineering" : "Human Resources"
        )
    }
}

private func makeEmployee(
    id: Int,
    firstName: String = "Alex",
    lastName: String = "Morgan",
    department: String = "Engineering",
    gender: String? = "female",
    age: Int? = 30
) -> Employee {
    Employee(
        id: id,
        firstName: firstName,
        lastName: lastName,
        maidenName: nil,
        age: age,
        gender: gender,
        email: "employee\(id)@example.com",
        phone: "+1 555 010 \(id)",
        username: "employee\(id)",
        image: "https://example.com/\(id).png",
        company: Employee.Company(
            department: department,
            name: "Example Company",
            title: "Software Engineer",
            address: Employee.CompanyAddress(
                address: "1 Example Street",
                city: "Pune",
                state: "Maharashtra"
            )
        ),
        address: Employee.Address(
            address: "1 Example Street",
            city: "Pune",
            state: "Maharashtra",
            country: "India"
        )
    )
}
