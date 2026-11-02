import UIKit

final class EmployeeDirectoryViewController: UIViewController {

    private let viewModel = EmployeeDirectoryViewModel()
    private var employees: [Employee] = []
    private var selectedDepartment = "All"
    private var searchWorkItem: DispatchWorkItem?

    private let headerStack = UIStackView()
    private let countLabel = UILabel()
    private let searchField = UITextField()
    private let filterStack = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    private var departmentFilters = ["All"]
    private var selectedGender: String?
    private var selectedAgeRange: AgeRange = .all
    private var selectedSort: SortOption = .nameAscending

    private enum SortOption: String {
        case nameAscending = "Name A–Z"
        case nameDescending = "Name Z–A"
        case departmentAscending = "Department A–Z"
        case ageYoungestFirst = "Age: Youngest First"
        case ageOldestFirst = "Age: Oldest First"
    }

    private enum AgeRange: String {
        case all = "Any age"
        case under30 = "Under 30"
        case from30To40 = "30–40"
        case over40 = "Above 40"

        func includes(_ age: Int?) -> Bool {
            guard let age else { return false }
            switch self {
            case .all: return true
            case .under30: return age < 30
            case .from30To40: return (30...40).contains(age)
            case .over40: return age > 40
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "People"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .always

        configureHeader()
        configureTable()
        configureStateViews()
        bindViewModel()
        viewModel.loadInitial()
    }

    deinit {
        searchWorkItem?.cancel()
    }

    // MARK: - Header

    private func configureHeader() {
        headerStack.axis = .vertical
        headerStack.spacing = 15
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let eyebrow = UILabel()
        eyebrow.text = "YOUR WORKSPACE"
        eyebrow.font = .systemFont(ofSize: 11, weight: .bold)
        eyebrow.textColor = .systemBlue

        let titleLabel = UILabel()
        titleLabel.text = "Employee directory"
        titleLabel.font = .systemFont(ofSize: 29, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.adjustsFontForContentSizeCategory = true

        let subtitle = UILabel()
        subtitle.text = "Find the right people across your organization."
        subtitle.font = .preferredFont(forTextStyle: .subheadline)
        subtitle.textColor = .secondaryLabel
        subtitle.numberOfLines = 0

        searchField.placeholder = "Search name, role or email"
        searchField.font = .systemFont(ofSize: 15)
        searchField.textColor = .label
        searchField.backgroundColor = .secondarySystemGroupedBackground
        searchField.layer.cornerRadius = 15
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = UIColor.separator.withAlphaComponent(0.18).cgColor
        searchField.clearButtonMode = .whileEditing
        searchField.returnKeyType = .search
        searchField.delegate = self
        searchField.autocorrectionType = .no
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.addTarget(self, action: #selector(searchTextDidChange), for: .editingChanged)
        searchField.accessibilityLabel = "Search employees"

        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .secondaryLabel
        searchIcon.contentMode = .scaleAspectFit
        searchIcon.translatesAutoresizingMaskIntoConstraints = false

        let searchContainer = UIView()
        searchContainer.addSubview(searchField)
        searchContainer.addSubview(searchIcon)

        NSLayoutConstraint.activate([
            searchContainer.heightAnchor.constraint(equalToConstant: 52),
            searchField.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchField.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            searchField.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor),
            searchIcon.leadingAnchor.constraint(equalTo: searchField.leadingAnchor, constant: 16),
            searchIcon.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 18),
            searchIcon.heightAnchor.constraint(equalToConstant: 18)
        ])

        searchField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 1))
        searchField.leftViewMode = .always

        let filterScroll = UIScrollView()
        filterScroll.showsHorizontalScrollIndicator = false

        filterStack.axis = .horizontal
        filterStack.spacing = 8
        filterStack.translatesAutoresizingMaskIntoConstraints = false
        filterScroll.addSubview(filterStack)

        NSLayoutConstraint.activate([
            filterScroll.heightAnchor.constraint(equalToConstant: 38),
            filterStack.topAnchor.constraint(equalTo: filterScroll.contentLayoutGuide.topAnchor),
            filterStack.bottomAnchor.constraint(equalTo: filterScroll.contentLayoutGuide.bottomAnchor),
            filterStack.leadingAnchor.constraint(equalTo: filterScroll.contentLayoutGuide.leadingAnchor),
            filterStack.trailingAnchor.constraint(equalTo: filterScroll.contentLayoutGuide.trailingAnchor),
            filterStack.heightAnchor.constraint(equalTo: filterScroll.frameLayoutGuide.heightAnchor)
        ])

        rebuildDepartmentFilters()
        updateFilterAppearance()

        countLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        countLabel.textColor = .secondaryLabel
        countLabel.text = "Loading people…"

        headerStack.addArrangedSubview(eyebrow)
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(subtitle)
        headerStack.addArrangedSubview(searchContainer)
        headerStack.addArrangedSubview(filterScroll)
        headerStack.addArrangedSubview(countLabel)
        headerStack.addArrangedSubview(makeDirectoryControls())

        view.addSubview(headerStack)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Sorting and Advanced Filter Controls

    private func makeDirectoryControls() -> UIView {
        let controls = UIStackView()
        controls.axis = .horizontal
        controls.spacing = 10
        controls.distribution = .fillEqually

        let sortButton = UIButton(type: .system)
        sortButton.setTitle("  Sort", for: .normal)
        sortButton.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        sortButton.tintColor = .label
        sortButton.backgroundColor = .secondarySystemGroupedBackground
        sortButton.layer.cornerRadius = 12
        sortButton.layer.borderWidth = 1
        sortButton.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        sortButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        sortButton.addTarget(self, action: #selector(sortTapped), for: .touchUpInside)

        let filterButton = UIButton(type: .system)
        filterButton.setTitle("  Filters", for: .normal)
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        filterButton.tintColor = .label
        filterButton.backgroundColor = .secondarySystemGroupedBackground
        filterButton.layer.cornerRadius = 12
        filterButton.layer.borderWidth = 1
        filterButton.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        filterButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        filterButton.addTarget(self, action: #selector(advancedFiltersTapped), for: .touchUpInside)

        controls.addArrangedSubview(sortButton)
        controls.addArrangedSubview(filterButton)
        return controls
    }

    // MARK: - Table

    private func configureTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 24, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(EmployeeCell.self, forCellReuseIdentifier: EmployeeCell.reuseIdentifier)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - State Views

    private func configureStateViews() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.textColor = .secondaryLabel
        messageLabel.isHidden = true
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36)
        ])

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Try again", for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        retryButton.isHidden = true
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        view.addSubview(retryButton)

        NSLayoutConstraint.activate([
            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }

    private func updateUI() {
        switch viewModel.state {
        case .idle:
            break

        case .loading:
            activityIndicator.startAnimating()
            messageLabel.isHidden = true
            retryButton.isHidden = true
            tableView.isHidden = true
            countLabel.text = "Loading people…"

        case .loaded, .loadingMore:
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            retryButton.isHidden = true

            rebuildDepartmentFiltersIfNeeded()
            employees = filteredEmployees
            updateCountLabel()
            tableView.reloadData()

            let isEmpty = displayedEmployees.isEmpty
            messageLabel.isHidden = !isEmpty
            if isEmpty {
                messageLabel.text = emptyStateMessage
            }

        case .failed(let message):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = "We couldn't load the directory.\n\n\(message)"
            retryButton.isHidden = false
            countLabel.text = "Directory unavailable"
        }

        if case .loadingMore = viewModel.state {
            tableView.tableFooterView = makeFooterSpinner()
        } else {
            tableView.tableFooterView = nil
        }
    }

    private var filteredEmployees: [Employee] {
        guard selectedDepartment != "All" else {
            return viewModel.employees
        }

        let target = selectedDepartment.trimmingCharacters(in: .whitespacesAndNewlines)

        return viewModel.employees.filter { employee in
            let department = employee.department.trimmingCharacters(in: .whitespacesAndNewlines)
            if target.caseInsensitiveCompare("HR") == .orderedSame {
                return department.localizedCaseInsensitiveContains("human") ||
                    department.caseInsensitiveCompare("HR") == .orderedSame
            }
            return department.localizedCaseInsensitiveContains(target)
        }
    }

    private var displayedEmployees: [Employee] {
        let filtered = employees.filter { employee in
            let matchesGender = selectedGender == nil ||
                employee.gender?.caseInsensitiveCompare(selectedGender!) == .orderedSame
            let matchesAge = selectedAgeRange.includes(employee.age)
            return matchesGender && matchesAge
        }

        switch selectedSort {
        case .nameAscending:
            return filtered.sorted {
                $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending
            }
        case .nameDescending:
            return filtered.sorted {
                $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedDescending
            }
        case .departmentAscending:
            return filtered.sorted {
                $0.department.localizedCaseInsensitiveCompare($1.department) == .orderedAscending
            }
        case .ageYoungestFirst:
            return filtered.sorted { ($0.age ?? Int.max) < ($1.age ?? Int.max) }
        case .ageOldestFirst:
            return filtered.sorted { ($0.age ?? Int.min) > ($1.age ?? Int.min) }
        }
    }

    private var activeAdvancedFilterCount: Int {
        (selectedGender == nil ? 0 : 1) + (selectedAgeRange == .all ? 0 : 1)
    }

    private var emptyStateMessage: String {
        if selectedDepartment != "All" {
            return "No employees in \(selectedDepartment) among the currently loaded results."
        }

        if let query = searchField.text,
           !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "No employees match “\(query)”. Try another name or search term."
        }

        return "No employees are available right now."
    }

    private func updateCountLabel() {
        let offlinePrefix = viewModel.isShowingCachedData ? "OFFLINE  ·  " : ""

        let activeFilters = activeAdvancedFilterCount
        let filterSuffix = activeFilters > 0 ? " · \(activeFilters) filter\(activeFilters == 1 ? "" : "s")" : ""

        if selectedDepartment == "All" && activeFilters == 0 {
            countLabel.text = "\(offlinePrefix)\(viewModel.totalCount) people"
        } else {
            countLabel.text = "\(offlinePrefix)\(displayedEmployees.count) shown · \(viewModel.employees.count) loaded\(filterSuffix)"
        }
    }

    // MARK: - Department Filters

    private func rebuildDepartmentFiltersIfNeeded() {
        let apiDepartments = viewModel.departments
        let updatedFilters = ["All"] + apiDepartments

        guard updatedFilters != departmentFilters else { return }

        departmentFilters = updatedFilters

        if selectedDepartment != "All",
           !apiDepartments.contains(where: {
               $0.caseInsensitiveCompare(selectedDepartment) == .orderedSame
           }) {
            selectedDepartment = "All"
        }

        rebuildDepartmentFilters()
        updateFilterAppearance()
    }

    private func rebuildDepartmentFilters() {
        filterStack.arrangedSubviews.forEach { arrangedView in
            filterStack.removeArrangedSubview(arrangedView)
            arrangedView.removeFromSuperview()
        }

        for (index, title) in departmentFilters.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 17, bottom: 8, right: 17)
            button.layer.cornerRadius = 18
            button.tag = index
            button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
            filterStack.addArrangedSubview(button)
        }
    }

    private func updateFilterAppearance() {
        for (index, view) in filterStack.arrangedSubviews.enumerated() {
            guard let button = view as? UIButton,
                  departmentFilters.indices.contains(index) else { continue }

            let selected = departmentFilters[index] == selectedDepartment
            button.backgroundColor = selected ? .systemBlue : .secondarySystemGroupedBackground
            button.setTitleColor(selected ? .white : .secondaryLabel, for: .normal)
            button.layer.borderWidth = selected ? 0 : 1
            button.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
            button.accessibilityTraits = selected ? [.button, .selected] : [.button]
        }
    }

    // MARK: - Search

    @objc private func searchTextDidChange() {
        searchWorkItem?.cancel()

        let query = searchField.text ?? ""
        let workItem = DispatchWorkItem { [weak self] in
            self?.viewModel.search(query)
        }

        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }

    private func makeFooterSpinner() -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 48))
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.center = CGPoint(x: footer.bounds.midX, y: footer.bounds.midY)
        footer.addSubview(spinner)
        return footer
    }

    // MARK: - Actions

    @objc private func filterTapped(_ sender: UIButton) {
        guard departmentFilters.indices.contains(sender.tag) else { return }

        selectedDepartment = departmentFilters[sender.tag]
        updateFilterAppearance()

        employees = filteredEmployees
        updateCountLabel()
        tableView.reloadData()

        let isEmpty = displayedEmployees.isEmpty
        messageLabel.isHidden = !isEmpty
        if isEmpty {
            messageLabel.text = emptyStateMessage
        }
    }

    @objc private func sortTapped() {
        let alert = UIAlertController(title: "Sort employees", message: nil, preferredStyle: .actionSheet)

        let options: [SortOption] = [
            .nameAscending, .nameDescending, .departmentAscending,
            .ageYoungestFirst, .ageOldestFirst
        ]

        for option in options {
            let title = option == selectedSort ? "✓  \(option.rawValue)" : option.rawValue
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.selectedSort = option
                self?.tableView.reloadData()
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        configurePopover(for: alert)
        present(alert, animated: true)
    }

    @objc private func advancedFiltersTapped() {
        let alert = UIAlertController(
            title: "Advanced filters",
            message: "Choose a gender and age range. Filters can be combined.",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(
            title: "Gender: \(selectedGender?.capitalized ?? "Any")",
            style: .default
        ) { [weak self] _ in
            self?.presentGenderFilter()
        })

        alert.addAction(UIAlertAction(
            title: "Age: \(selectedAgeRange.rawValue)",
            style: .default
        ) { [weak self] _ in
            self?.presentAgeFilter()
        })

        alert.addAction(UIAlertAction(title: "Reset advanced filters", style: .destructive) { [weak self] _ in
            self?.selectedGender = nil
            self?.selectedAgeRange = .all
            self?.refreshFilteredResults()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        configurePopover(for: alert)
        present(alert, animated: true)
    }

    private func presentGenderFilter() {
        let alert = UIAlertController(title: "Filter by gender", message: nil, preferredStyle: .actionSheet)
        let options: [(String, String?)] = [
            ("Any gender", nil),
            ("Female", "female"),
            ("Male", "male")
        ]

        for (title, value) in options {
            let actionTitle = selectedGender == value ? "✓  \(title)" : title
            alert.addAction(UIAlertAction(title: actionTitle, style: .default) { [weak self] _ in
                self?.selectedGender = value
                self?.refreshFilteredResults()
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        configurePopover(for: alert)
        present(alert, animated: true)
    }

    private func presentAgeFilter() {
        let alert = UIAlertController(title: "Filter by age", message: nil, preferredStyle: .actionSheet)

        let options: [AgeRange] = [.all, .under30, .from30To40, .over40]
        for option in options {
            let actionTitle = selectedAgeRange == option ? "✓  \(option.rawValue)" : option.rawValue
            alert.addAction(UIAlertAction(title: actionTitle, style: .default) { [weak self] _ in
                self?.selectedAgeRange = option
                self?.refreshFilteredResults()
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        configurePopover(for: alert)
        present(alert, animated: true)
    }

    private func configurePopover(for alert: UIAlertController) {
        guard let popover = alert.popoverPresentationController else { return }
        popover.sourceView = view
        popover.sourceRect = CGRect(
            x: view.bounds.midX,
            y: view.bounds.midY,
            width: 1,
            height: 1
        )
    }

    private func refreshFilteredResults() {
        tableView.reloadData()
        updateCountLabel()

        let isEmpty = displayedEmployees.isEmpty
        messageLabel.isHidden = !isEmpty
        if isEmpty {
            messageLabel.text = "No employees match the selected filters."
        }
    }

    @objc private func retryTapped() {
        viewModel.loadInitial()
    }
}

// MARK: - UITextFieldDelegate

extension EmployeeDirectoryViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchWorkItem?.cancel()
        viewModel.search(textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate

extension EmployeeDirectoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedEmployees.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: EmployeeCell.reuseIdentifier,
            for: indexPath
        ) as! EmployeeCell

        let visibleEmployees = displayedEmployees
        guard visibleEmployees.indices.contains(indexPath.row) else {
            return cell
        }

        cell.configure(with: visibleEmployees[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        // Trigger pagination near the end of the visible, filtered list.
        // Translate the trigger to the end of the underlying ViewModel page.
        guard !displayedEmployees.isEmpty,
              indexPath.row >= displayedEmployees.count - 4,
              case .loaded = viewModel.state else { return }

        viewModel.loadMoreIfNeeded(currentItem: viewModel.employees.count - 1)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let visibleEmployees = displayedEmployees
        guard visibleEmployees.indices.contains(indexPath.row) else { return }

        let employee = visibleEmployees[indexPath.row]

        // Record this profile visit before navigating to the detail screen.
        RecentlyViewedEmployeesStore.shared.record(employeeID: employee.id)

        navigationController?.pushViewController(
            EmployeeDetailViewController(employee: employee),
            animated: true
        )
    }
}
