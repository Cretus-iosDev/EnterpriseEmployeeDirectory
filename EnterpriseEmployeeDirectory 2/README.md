# Enterprise Employee Directory

A native iOS employee directory portfolio app built with **Swift, UIKit, MVVM, URLSession, Codable and async/await**.

## Features

- Employee directory powered by a REST API
- Remote employee search with a short debounce
- Department quick filters (All, Engineering, Sales and HR)
- Employee profile screen with contact and work information
- Pagination / load-more as the user scrolls
- Employee avatar loading with an in-memory `NSCache`
- Loading, empty, retry and API error states
- Programmatic UIKit layout; no third-party dependencies

## API

The starter app uses the public [DummyJSON Users API](https://dummyjson.com/docs/users):

- `GET https://dummyjson.com/users?limit=20&skip=0`
- `GET https://dummyjson.com/users/search?q=...&limit=20&skip=0`

This is demo data, not a real employee directory. Replace `EmployeeAPIService`'s base URL and adapt the Codable models before connecting a company backend.

## Run in Xcode

1. Download and unzip the project.
2. Open `EnterpriseEmployeeDirectory.xcodeproj` in Xcode 15 or later.
3. Select the `EnterpriseEmployeeDirectory` scheme.
4. Choose an iPhone simulator or connected iPhone.
5. Press **Run**.

The app target uses a custom Info.plist with `CFBundleExecutable` set to `$(EXECUTABLE_NAME)`, so the installed app bundle can locate its compiled executable. No API key or package installation is required. The app requires network access to load demo employee data and profile images.

## Architecture

```text
App/
  AppDelegate.swift
  SceneDelegate.swift
Models/
  Employee.swift
Services/
  EmployeeAPIService.swift
  ImageLoader.swift
ViewModels/
  EmployeeDirectoryViewModel.swift
Views/
  EmployeeDirectoryViewController.swift
  EmployeeCell.swift
  EmployeeDetailViewController.swift
Resources/
  Info.plist
```

### Data flow

`EmployeeDirectoryViewController` observes `EmployeeDirectoryViewModel`. The view model requests data through the `EmployeeServicing` protocol. `EmployeeAPIService` performs URLSession requests, decodes JSON into `EmployeeResponse`, and returns typed employee models. The view controller renders the state and pushes a profile screen when a row is selected.

## Notes for a portfolio / interview

Be ready to explain the MVVM separation, URLSession request lifecycle, Codable model mapping, async/await error handling, debounced search, pagination, image caching, and how you would replace the demo API with an authenticated enterprise service. This project is a working starter implementation; run it in Xcode and test it on a simulator/device before publishing it as completed work.


## Offline caching

The app now stores the full employee directory as JSON in the app's Application Support directory using atomic writes. If the initial directory request fails, the last saved directory is shown and the count label is prefixed with `Offline`. Successful unfiltered page loads update the cache. Search responses are not saved over the full directory cache.

## Unit tests

`Tests/EmployeeDiskCacheTests.swift` contains XCTest coverage for the disk cache's empty and save/read paths. To run it, add an iOS Unit Testing Bundle target named `EnterpriseEmployeeDirectoryTests` in Xcode, add `Tests/EmployeeDiskCacheTests.swift` to that target, and set the app target as the test target's host (`TEST_HOST` / `BUNDLE_LOADER`). The tests import the app module with `@testable import EnterpriseEmployeeDirectory`.
