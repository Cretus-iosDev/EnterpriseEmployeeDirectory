import Foundation

struct EmployeeResponse: Codable {
    let users: [Employee]
    let total: Int
    let skip: Int
    let limit: Int
}

struct Employee: Codable, Identifiable, Hashable {
    let id: Int
    let firstName: String
    let lastName: String
    let maidenName: String?
    let age: Int?
    let gender: String?
    let email: String
    let phone: String
    let username: String?
    let image: String
    let company: Company
    let address: Address

    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String {
        let first = firstName.first.map(String.init) ?? ""
        let last = lastName.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }
    var role: String { company.title }
    var department: String { company.department }
    var officeLocation: String { "\(address.city), \(address.state)" }

    struct Company: Codable, Hashable {
        let department: String
        let name: String
        let title: String
        let address: CompanyAddress?
    }

    struct CompanyAddress: Codable, Hashable {
        let address: String?
        let city: String?
        let state: String?
    }

    struct Address: Codable, Hashable {
        let address: String
        let city: String
        let state: String
        let country: String?
    }
}
