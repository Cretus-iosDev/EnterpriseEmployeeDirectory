import Foundation

/// Persists recently opened employee profile IDs on this device.
final class RecentlyViewedEmployeesStore {
    static let shared = RecentlyViewedEmployeesStore()

    private let defaults: UserDefaults
    private let key = "recentlyViewedEmployeeIDs"
    private let maximumItems = 10

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// IDs ordered from most recently viewed to least recently viewed.
    var employeeIDs: [Int] {
        defaults.array(forKey: key) as? [Int] ?? []
    }

    func record(employeeID: Int) {
        var ids = employeeIDs
        ids.removeAll { $0 == employeeID }
        ids.insert(employeeID, at: 0)

        if ids.count > maximumItems {
            ids = Array(ids.prefix(maximumItems))
        }

        defaults.set(ids, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
