import Foundation

@MainActor
final class EmployeeDirectoryViewModel {

    enum State {
        case idle
        case loading
        case loaded
        case loadingMore
        case failed(String)
    }

    private let service: EmployeeServicing
    private let cache: EmployeeCaching?
    private let pageSize = 20

    private var skip = 0
    private var total = 0
    private var currentSearch: String?
    private var requestTask: Task<Void, Never>?
    private var departmentsTask: Task<Void, Never>?
    private var hasLoadedDepartments = false

    // Every initial/search request gets a new generation.
    // Responses from older generations are ignored.
    private var requestGeneration = 0

    private(set) var departments: [String] = []
    private(set) var employees: [Employee] = []
    private(set) var state: State = .idle
    private(set) var isShowingCachedData = false

    var onChange: (() -> Void)?

    var totalCount: Int { total }
    var hasMore: Bool { employees.count < total }
    var isSearching: Bool { currentSearch != nil }

    init(
        service: EmployeeServicing = EmployeeAPIService(),
        cache: EmployeeCaching? = try? EmployeeDiskCache()
    ) {
        self.service = service
        self.cache = cache
    }

    // MARK: - Initial Loading / Search

    func loadInitial() {
        requestTask?.cancel()
        requestGeneration += 1
        let generation = requestGeneration

        skip = 0
        total = 0
        employees = []
        isShowingCachedData = false
        state = .loading
        onChange?()

        loadDepartmentsIfNeeded()

        requestTask = Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await service.fetchEmployees(
                    skip: 0,
                    limit: pageSize,
                    search: currentSearch
                )

                guard !Task.isCancelled,
                      generation == requestGeneration else { return }

                employees = response.users
                total = response.total
                skip = response.users.count
                isShowingCachedData = false

                // Cache only the unfiltered directory pages.
                if currentSearch == nil {
                    try? cache?.saveEmployees(employees)
                }

                state = .loaded
                onChange?()

            } catch is CancellationError {
                return
            } catch {
                // An old request must never replace the state of a newer request.
                guard !Task.isCancelled,
                      generation == requestGeneration else { return }

                if currentSearch == nil,
                   let cachedEmployees = try? cache?.loadEmployees(),
                   !cachedEmployees.isEmpty {
                    employees = cachedEmployees
                    total = cachedEmployees.count
                    skip = cachedEmployees.count
                    isShowingCachedData = true
                    state = .loaded
                } else {
                    state = .failed(error.localizedDescription)
                }

                onChange?()
            }
        }
    }

    func search(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let newSearch = trimmedQuery.isEmpty ? nil : trimmedQuery

        guard newSearch != currentSearch else { return }

        currentSearch = newSearch
        loadInitial()
    }

    // MARK: - Departments

    /// Loads department names independently from paginated directory results.
    private func loadDepartmentsIfNeeded() {
        guard !hasLoadedDepartments, departmentsTask == nil else { return }

        departmentsTask = Task { [weak self] in
            guard let self else { return }
            defer { departmentsTask = nil }

            do {
                let response = try await service.fetchEmployees(
                    skip: 0,
                    limit: 1000,
                    search: nil
                )

                guard !Task.isCancelled else { return }

                let names = response.users
                    .map {
                        $0.department.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .filter { !$0.isEmpty }

                departments = Array(Set(names)).sorted {
                    $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
                }

                hasLoadedDepartments = true
                onChange?()

            } catch is CancellationError {
                return
            } catch {
                // Directory results remain usable if department loading fails.
            }
        }
    }

    // MARK: - Pagination

    /// `currentItem` is the index in the unfiltered ViewModel employee array.
    func loadMoreIfNeeded(currentItem item: Int) {
        guard hasMore,
              item >= employees.count - 4,
              case .loaded = state else { return }

        let generation = requestGeneration
        state = .loadingMore
        onChange?()

        requestTask = Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await service.fetchEmployees(
                    skip: skip,
                    limit: pageSize,
                    search: currentSearch
                )

                guard !Task.isCancelled,
                      generation == requestGeneration else { return }

                let existingIDs = Set(employees.map(\.id))
                let newEmployees = response.users.filter { !existingIDs.contains($0.id) }

                employees.append(contentsOf: newEmployees)
                total = response.total
                skip += response.users.count

                if currentSearch == nil {
                    try? cache?.saveEmployees(employees)
                }

                state = .loaded
                onChange?()

            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled,
                      generation == requestGeneration else { return }

                // Keep the already loaded rows available; a later scroll can retry.
                state = .loaded
                onChange?()
            }
        }
    }
}
