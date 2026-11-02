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

See the architecture diagram in the project documentation.

## API

Employee data is retrieved from the DummyJSON Users API.

Base endpoint:

`https://dummyjson.com/users`

The application uses the users endpoint for employee listing and the search endpoint for remote search.

## Screenshots

Add application screenshots to the `Screenshots/` directory.

| Screen | Screenshot |
|---|---|
| Overview Dashboard | `Screenshots/overview.png` |
| Employee Directory | `Screenshots/directory.png` |
| Search Results | `Screenshots/search.png` |
| Employee Profile | `Screenshots/employee-profile.png` |
| Department Filters | `Screenshots/department-filters.png` |
| Advanced Filters | `Screenshots/advanced-filters.png` |

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

**iOS Developer**

Built as a portfolio project to demonstrate native iOS development, UIKit, MVVM, networking, persistence, and automated testing.
