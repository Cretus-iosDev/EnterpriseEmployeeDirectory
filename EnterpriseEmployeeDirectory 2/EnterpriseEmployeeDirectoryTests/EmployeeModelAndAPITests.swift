import XCTest
@testable import EnterpriseEmployeeDirectory

final class EmployeeModelTests: XCTestCase {

    func testFullNameCombinesFirstAndLastName() {
        let employee = makeEmployee(firstName: "Aarav", lastName: "Sharma")

        XCTAssertEqual(employee.fullName, "Aarav Sharma")
    }

    func testInitialsAreUppercasedFirstLetters() {
        let employee = makeEmployee(firstName: "aarav", lastName: "sharma")

        XCTAssertEqual(employee.initials, "AS")
    }

    func testRoleDepartmentAndOfficeLocationUseNestedValues() {
        let employee = makeEmployee(
            title: "iOS Engineer",
            department: "Engineering",
            city: "Pune",
            state: "Maharashtra"
        )

        XCTAssertEqual(employee.role, "iOS Engineer")
        XCTAssertEqual(employee.department, "Engineering")
        XCTAssertEqual(employee.officeLocation, "Pune, Maharashtra")
    }

    func testEmployeeCanBeEncodedAndDecoded() throws {
        let original = makeEmployee()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Employee.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    private func makeEmployee(
        firstName: String = "Aarav",
        lastName: String = "Sharma",
        title: String = "iOS Engineer",
        department: String = "Engineering",
        city: String = "Pune",
        state: String = "Maharashtra"
    ) -> Employee {
        Employee(
            id: 101,
            firstName: firstName,
            lastName: lastName,
            maidenName: nil,
            age: 28,
            gender: "male",
            email: "aarav@example.com",
            phone: "+91 9876543210",
            username: "aarav",
            image: "https://example.com/avatar.png",
            company: Employee.Company(
                department: department,
                name: "Example Technologies",
                title: title,
                address: Employee.CompanyAddress(
                    address: "Tech Park",
                    city: city,
                    state: state
                )
            ),
            address: Employee.Address(
                address: "Main Road",
                city: city,
                state: state,
                country: "India"
            )
        )
    }
}

final class EmployeeAPIServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        MockURLProtocol.requestHandler = nil
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testFetchEmployeesBuildsCorrectListRequestAndDecodesResponse() async throws {
        let expectedJSON = """
        {
          "users": [],
          "total": 0,
          "skip": 20,
          "limit": 20
        }
        """

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString,
                           "https://dummyjson.com/users?limit=20&skip=20")
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")

            return (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data(expectedJSON.utf8)
            )
        }

        let service = makeService()
        let response = try await service.fetchEmployees(skip: 20, limit: 20, search: nil)

        XCTAssertTrue(response.users.isEmpty)
        XCTAssertEqual(response.total, 0)
        XCTAssertEqual(response.skip, 20)
        XCTAssertEqual(response.limit, 20)
    }

    func testFetchEmployeesBuildsSearchRequest() async throws {
        let expectedJSON = """
        {
          "users": [],
          "total": 0,
          "skip": 0,
          "limit": 10
        }
        """

        MockURLProtocol.requestHandler = { request in
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)

            XCTAssertEqual(components?.path, "/users/search")
            XCTAssertEqual(
                components?.queryItems?.first(where: { $0.name == "q" })?.value,
                "Aarav"
            )
            XCTAssertEqual(
                components?.queryItems?.first(where: { $0.name == "limit" })?.value,
                "10"
            )
            XCTAssertEqual(
                components?.queryItems?.first(where: { $0.name == "skip" })?.value,
                "0"
            )

            return (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data(expectedJSON.utf8)
            )
        }

        let service = makeService()
        let response = try await service.fetchEmployees(
            skip: 0,
            limit: 10,
            search: "Aarav"
        )

        XCTAssertEqual(response.limit, 10)
    }

    func testWhitespaceOnlySearchUsesNormalEmployeesEndpoint() async throws {
        let expectedJSON = """
        {
          "users": [],
          "total": 0,
          "skip": 0,
          "limit": 20
        }
        """

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/users")
            XCTAssertFalse(request.url?.path.contains("/search") ?? true)

            return (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data(expectedJSON.utf8)
            )
        }

        let service = makeService()
        _ = try await service.fetchEmployees(
            skip: 0,
            limit: 20,
            search: "   "
        )
    }

    func testNonSuccessStatusCodeThrowsServerError() async {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 500,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data()
            )
        }

        let service = makeService()

        do {
            _ = try await service.fetchEmployees(skip: 0, limit: 20, search: nil)
            XCTFail("Expected APIError.server to be thrown.")
        } catch let error as APIError {
            if case .server(let statusCode) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Expected server error, received \(error).")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testInvalidJSONThrowsDecodingError() async {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data("not-json".utf8)
            )
        }

        let service = makeService()

        do {
            _ = try await service.fetchEmployees(skip: 0, limit: 20, search: nil)
            XCTFail("Expected JSON decoding to fail.")
        } catch is DecodingError {
            // Expected.
        } catch {
            XCTFail("Expected DecodingError, received \(error).")
        }
    }

    private func makeService() -> EmployeeAPIService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return EmployeeAPIService(session: URLSession(configuration: configuration))
    }
}

private final class MockURLProtocol: URLProtocol {

    typealias RequestHandler = (URLRequest) throws -> (HTTPURLResponse, Data)

    nonisolated(unsafe) static var requestHandler: RequestHandler?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(
                self,
                didFailWithError: URLError(.badServerResponse)
            )
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
