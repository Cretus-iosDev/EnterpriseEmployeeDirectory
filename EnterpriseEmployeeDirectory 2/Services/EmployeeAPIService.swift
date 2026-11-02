import Foundation

protocol EmployeeServicing {
    func fetchEmployees(skip: Int, limit: Int, search: String?) async throws -> EmployeeResponse
}

enum APIError: LocalizedError {
    case invalidResponse
    case server(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an unexpected response. Please try again."
        case .server(let statusCode):
            return "The server returned an error (\(statusCode)). Please try again."
        }
    }
}

final class EmployeeAPIService: EmployeeServicing {
    private let session: URLSession
    private let baseURL = URL(string: "https://dummyjson.com/users")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchEmployees(skip: Int, limit: Int, search: String? = nil) async throws -> EmployeeResponse {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        if let search, !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            components.path += "/search"
            components.queryItems = [
                URLQueryItem(name: "q", value: search),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "skip", value: String(skip))
            ]
        } else {
            components.queryItems = [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "skip", value: String(skip))
            ]
        }

        guard let url = components.url else { throw APIError.invalidResponse }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.server(statusCode: httpResponse.statusCode)
        }
        return try JSONDecoder().decode(EmployeeResponse.self, from: data)
    }
}
