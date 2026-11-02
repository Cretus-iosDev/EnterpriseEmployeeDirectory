import Foundation

protocol EmployeeCaching {
    func loadEmployees() throws -> [Employee]?
    func saveEmployees(_ employees: [Employee]) throws
}

final class EmployeeDiskCache: EmployeeCaching {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        fileManager: FileManager = .default,
        directory: URL? = nil,
        fileName: String = "employee-directory-cache.json"
    ) throws {
        let baseDirectory = directory ?? fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        try fileManager.createDirectory(
            at: baseDirectory,
            withIntermediateDirectories: true
        )
        self.fileURL = baseDirectory.appendingPathComponent(fileName)
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    func loadEmployees() throws -> [Employee]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([Employee].self, from: data)
    }

    func saveEmployees(_ employees: [Employee]) throws {
        let data = try encoder.encode(employees)
        try data.write(to: fileURL, options: [.atomic])
    }
}
