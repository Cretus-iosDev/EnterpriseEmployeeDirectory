# Enterprise Employee Directory

A native iOS application for browsing, searching, filtering, and managing employee directory information. Built with **UIKit, Swift, and MVVM architecture**, with an emphasis on clean code organization, reusable components, networking, local persistence, and a polished user experience.

## Overview

Enterprise Employee Directory provides an organization-level view of its workforce and an interactive employee directory.

The application includes an analytics dashboard, searchable employee listings, advanced filtering and sorting, detailed employee profiles, recently viewed employees, and local caching.

## Features

### Overview Dashboard
- Workforce overview and employee statistics
- Department distribution
- Workforce composition by gender
- Average employee age
- Recently viewed employees
- Navigation to the employee directory

### Employee Directory
- Employee listing with reusable UIKit table view cells
- Search by employee name, role, or email
- Department-based filtering
- Sorting by name, department, and age
- Advanced gender and age filters
- Reset advanced filters
- Paginated employee loading

### Employee Profile
- Employee name, role, and department
- Contact information
- Company and work information
- Office location
- Employee ID, age, and gender
- Email, phone, and username actions

### Recently Viewed
- Stores recently viewed employee IDs
- Displays recently viewed employees on the dashboard
- Maintains newest-first ordering
- Prevents duplicate entries
- Persists data using UserDefaults

### Networking and Persistence
- API integration using URLSession
- JSON decoding using Codable
- Pagination support
- Local employee data caching
- Cached-data fallback when a network request fails
- Loading, empty, and error states

## Technology Stack

| Area | Technology |
|---|---|
| Language | Swift |
| UI Framework | UIKit |
| Architecture | MVVM |
| Networking | URLSession |
| Concurrency | Swift async/await |
| Data Parsing | Codable |
| Local Persistence | UserDefaults |
| Disk Caching | JSON file storage |
| Testing | XCTest |
| Development | Xcode |

## Architecture

The project follows Model-View-ViewModel architecture.

- **Model:** Represents employee data and API response structures.
- **View:** UIKit view controllers and reusable UI components.
- **ViewModel:** Handles presentation state, filtering, sorting, and business logic.
- **Service:** Handles remote API communication.
- **Cache:** Handles local employee data persistence.



## API

Employee data is retrieved from the DummyJSON Users API.

Base endpoint:

`https://dummyjson.com/users`

The application uses the users endpoint for employee listing and the search endpoint for remote search.

## Screenshots

| Screen | Screenshot |

1. <img width="386" height="763" alt="Screenshot 2026-11-02 at 1 30 55 PM" src="https://github.com/user-attachments/assets/c963f4e3-a40e-4529-869f-4d0d23c9ab4d" />
2. <img width="393" height="761" alt="Screenshot 2026-11-02 at 1 31 17 PM" src="https://github.com/user-attachments/assets/e0f84533-6073-42e3-9513-db26251dcaf0" />
3. <img width="384" height="773" alt="Screenshot 2026-11-02 at 1 31 47 PM" src="https://github.com/user-attachments/assets/c50993a6-05ee-415a-aad1-a0bdf425d28e" />
4. <img width="384" height="809" alt="Screenshot 2026-11-02 at 1 32 23 PM" src="https://github.com/user-attachments/assets/c65d16f1-5427-4037-9ff4-165e327497a4" />
5. <img width="220" height="221" alt="Screenshot 2026-11-02 at 1 32 45 PM" src="https://github.com/user-attachments/assets/39929d9b-ada7-43af-be5e-bee11291e8aa" />
6. <img width="236" height="263" alt="Screenshot 2026-11-02 at 1 33 02 PM" src="https://github.com/user-attachments/assets/8969bd6e-efe1-48ae-8f69-9af67c6c7362" />
7. <img width="219" height="311" alt="Screenshot 2026-11-02 at 1 33 26 PM" src="https://github.com/user-attachments/assets/b7b89d3d-7d2f-4402-be38-3b6f3db974d6" />
8. <img width="392" height="779" alt="Screenshot 2026-11-02 at 1 33 41 PM" src="https://github.com/user-attachments/assets/7f8bdc60-5769-4468-9a7e-314c1c8d2cd3" />





## Testing

The project includes XCTest coverage for:

- Employee model and API decoding
- API service behavior using a mock URL protocol
- Directory and dashboard ViewModels
- Recently viewed employee persistence
- Main navigation and dashboard UI
- Search and employee profile navigation
- Directory sorting and advanced filters

Additional validation of pagination, network failure scenarios, and device appearance can be documented as it is completed.


## Getting Started

1. Clone the repository.
2. Open `EnterpriseEmployeeDirectory.xcodeproj` in Xcode.
3. Select an iOS simulator or device.
4. Build and run the application.

No API key is required for the configured DummyJSON endpoint.

## Future Improvements

- Expand automated pagination and network failure tests
- Improve accessibility and Dynamic Type support
- Add more robust offline synchronization
- Add further UI and performance validation

## Author

**Rutik-Maraskolhe-iOS-Developer**

Built as a portfolio project to demonstrate native iOS development, UIKit, MVVM, networking, persistence, and automated testing.
