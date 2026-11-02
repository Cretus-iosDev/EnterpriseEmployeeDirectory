import Foundation

@MainActor
final class DashboardViewModel {

    struct DepartmentSummary {
        let name: String
        let count: Int
    }

    struct GenderSummary {
        let name: String
        let count: Int
    }

    enum State {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private let service: EmployeeServicing

    private(set) var employees: [Employee] = []
    private(set) var totalEmployees = 0
    private(set) var departments: [DepartmentSummary] = []
    private(set) var genderDistribution: [GenderSummary] = []
    private(set) var averageAge: Double?
    private(set) var employeesWithAgeCount = 0
    private(set) var state: State = .idle

    var onChange: (() -> Void)?

    /// Resolves saved profile history against the employee records already loaded by the dashboard.
    var recentlyViewedEmployees: [Employee] {
        let employeesByID = Dictionary(uniqueKeysWithValues: employees.map { ($0.id, $0) })
        return RecentlyViewedEmployeesStore.shared.employeeIDs.compactMap { employeesByID[$0] }
    }

    func employee(withID id: Int) -> Employee? {
        employees.first { $0.id == id }
    }

    init(service: EmployeeServicing = EmployeeAPIService()) {
        self.service = service
    }

    func loadDashboard() {
        if case .loading = state { return }

        state = .loading
        onChange?()

        Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await service.fetchEmployees(
                    skip: 0,
                    limit: 1000,
                    search: nil
                )

                guard !Task.isCancelled else { return }

                employees = response.users
                totalEmployees = response.total

                let groupedDepartments = Dictionary(
                    grouping: response.users,
                    by: { $0.department.trimmingCharacters(in: .whitespacesAndNewlines) }
                )

                departments = groupedDepartments
                    .filter { !$0.key.isEmpty }
                    .map { DepartmentSummary(name: $0.key, count: $0.value.count) }
                    .sorted {
                        if $0.count == $1.count {
                            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                        }
                        return $0.count > $1.count
                    }

                let groupedGender = Dictionary(
                    grouping: response.users,
                    by: { ($0.gender ?? "Unknown").capitalized }
                )

                genderDistribution = groupedGender
                    .map { GenderSummary(name: $0.key, count: $0.value.count) }
                    .sorted {
                        if $0.count == $1.count {
                            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                        }
                        return $0.count > $1.count
                    }

                let knownAges = response.users.compactMap(\.age).filter { $0 > 0 }
                employeesWithAgeCount = knownAges.count
                averageAge = knownAges.isEmpty
                    ? nil
                    : Double(knownAges.reduce(0, +)) / Double(knownAges.count)

                state = .loaded
            } catch is CancellationError {
                return
            } catch {
                state = .failed(error.localizedDescription)
            }

            onChange?()
        }
    }
}
