import UIKit

final class DashboardViewController: UIViewController {
    private let viewModel = DashboardViewModel()
    var onBrowseDirectory: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let totalValueLabel = UILabel()
    private let departmentValueLabel = UILabel()
    private let averageAgeValueLabel = UILabel()
    private let genderValueLabel = UILabel()
    private let genderStack = UIStackView()
    private let departmentStack = UIStackView()
    private let peopleStack = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Overview"
        view.backgroundColor = .systemGroupedBackground
        configureNavigation()
        configureLayout()
        bindViewModel()
        viewModel.loadDashboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        renderRecentlyViewed()
    }

    private func configureNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.2"),
            style: .plain,
            target: self,
            action: #selector(browseTapped)
        )
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 22
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 18),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28)
        ])

        let intro = makeIntro()
        contentStack.addArrangedSubview(intro)
        contentStack.addArrangedSubview(makeMetricsSection())
        contentStack.addArrangedSubview(makeDepartmentSection())
        contentStack.addArrangedSubview(makeGenderSection())
        contentStack.addArrangedSubview(makePeopleSection())

        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.isHidden = true
        contentStack.addArrangedSubview(statusLabel)
        loadingIndicator.hidesWhenStopped = true
        contentStack.addArrangedSubview(loadingIndicator)
    }

    private func makeIntro() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 7

        let eyebrow = UILabel()
        eyebrow.text = "YOUR WORKSPACE"
        eyebrow.font = .systemFont(ofSize: 11, weight: .bold)
        eyebrow.textColor = .systemBlue

        let title = UILabel()
        title.text = "Good to see you."
        title.font = .systemFont(ofSize: 30, weight: .bold)
        title.textColor = .label

        let subtitle = UILabel()
        subtitle.text = "A clear view of the people behind your organization."
        subtitle.font = .preferredFont(forTextStyle: .subheadline)
        subtitle.textColor = .secondaryLabel
        subtitle.numberOfLines = 0

        container.addArrangedSubview(eyebrow)
        container.addArrangedSubview(title)
        container.addArrangedSubview(subtitle)
        return container
    }

    private func makeMetricsSection() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually

        let peopleCard = makeMetricCard(
            title: "PEOPLE",
            valueLabel: totalValueLabel,
            symbol: "person.2.fill",
            tint: .systemBlue
        )
        let departmentCard = makeMetricCard(
            title: "DEPARTMENTS",
            valueLabel: departmentValueLabel,
            symbol: "square.grid.2x2.fill",
            tint: .systemIndigo
        )
        row.addArrangedSubview(peopleCard)
        row.addArrangedSubview(departmentCard)

        let secondaryRow = UIStackView()
        secondaryRow.axis = .horizontal
        secondaryRow.spacing = 12
        secondaryRow.distribution = .fillEqually

        let ageCard = makeMetricCard(
            title: "AVERAGE AGE",
            valueLabel: averageAgeValueLabel,
            symbol: "calendar",
            tint: .systemOrange
        )
        let genderCard = makeMetricCard(
            title: "GENDER GROUPS",
            valueLabel: genderValueLabel,
            symbol: "person.3.fill",
            tint: .systemPurple
        )

        secondaryRow.addArrangedSubview(ageCard)
        secondaryRow.addArrangedSubview(genderCard)

        let metrics = UIStackView(arrangedSubviews: [row, secondaryRow])
        metrics.axis = .vertical
        metrics.spacing = 12
        return metrics
    }

    private func makeMetricCard(title: String, valueLabel: UILabel, symbol: String, tint: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.separator.withAlphaComponent(0.18).cgColor

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = tint
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let heading = UILabel()
        heading.text = title
        heading.font = .systemFont(ofSize: 10, weight: .bold)
        heading.textColor = .secondaryLabel

        valueLabel.font = .systemFont(ofSize: 29, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.text = "—"

        let stack = UIStackView(arrangedSubviews: [icon, heading, valueLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 17),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 17),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -17),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22)
        ])
        return card
    }

    private func makeDepartmentSection() -> UIView {
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.spacing = 12
        wrapper.addArrangedSubview(makeSectionHeader("Departments", subtitle: "People across your organization"))

        let card = makeCard()
        departmentStack.axis = .vertical
        departmentStack.spacing = 0
        departmentStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(departmentStack)
        NSLayoutConstraint.activate([
            departmentStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 6),
            departmentStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            departmentStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            departmentStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -6)
        ])
        wrapper.addArrangedSubview(card)
        return wrapper
    }

    private func makeGenderSection() -> UIView {
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.spacing = 12
        wrapper.addArrangedSubview(
            makeSectionHeader("Workforce composition", subtitle: "Employee distribution by gender")
        )

        let card = makeCard()
        genderStack.axis = .vertical
        genderStack.spacing = 0
        genderStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(genderStack)

        NSLayoutConstraint.activate([
            genderStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            genderStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            genderStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            genderStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8)
        ])

        wrapper.addArrangedSubview(card)
        return wrapper
    }

    private func makePeopleSection() -> UIView {
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.spacing = 12
        wrapper.addArrangedSubview(makeSectionHeader("Recently viewed", subtitle: "Pick up where you left off"))

        let card = makeCard()
        peopleStack.axis = .vertical
        peopleStack.spacing = 0
        peopleStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(peopleStack)
        NSLayoutConstraint.activate([
            peopleStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 6),
            peopleStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            peopleStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            peopleStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -6)
        ])
        wrapper.addArrangedSubview(card)

        let button = UIButton(type: .system)
        button.setTitle("Browse all employees", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.addTarget(self, action: #selector(browseTapped), for: .touchUpInside)
        wrapper.addArrangedSubview(button)
        return wrapper
    }

    private func makeSectionHeader(_ title: String, subtitle: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 3
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .label
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        subtitleLabel.textColor = .secondaryLabel
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        return stack
    }

    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.separator.withAlphaComponent(0.18).cgColor
        return card
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            self?.render()
        }
    }

    private func render() {
        switch viewModel.state {
        case .idle:
            break
        case .loading:
            loadingIndicator.startAnimating()
            statusLabel.isHidden = true
        case .loaded:
            loadingIndicator.stopAnimating()
            statusLabel.isHidden = true
            totalValueLabel.text = "\(viewModel.totalEmployees)"
            departmentValueLabel.text = "\(viewModel.departments.count)"
            if let averageAge = viewModel.averageAge {
                averageAgeValueLabel.text = String(format: "%.1f", averageAge)
            } else {
                averageAgeValueLabel.text = "—"
            }
            genderValueLabel.text = "\(viewModel.genderDistribution.count)"
            renderDepartments()
            renderGenderDistribution()
            renderRecentlyViewed()
        case .failed(let message):
            loadingIndicator.stopAnimating()
            statusLabel.text = "We couldn't load the overview.\n\(message)"
            statusLabel.isHidden = false
        }
    }

    private func renderDepartments() {
        departmentStack.arrangedSubviews.forEach {
            departmentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (index, department) in viewModel.departments.prefix(5).enumerated() {
            let name = UILabel()
            name.text = department.name
            name.font = .systemFont(ofSize: 14, weight: .medium)
            name.textColor = .label

            let count = UILabel()
            count.text = "\(department.count)"
            count.font = .systemFont(ofSize: 14, weight: .semibold)
            count.textColor = .secondaryLabel

            let row = UIStackView(arrangedSubviews: [name, UIView(), count])
            row.alignment = .center
            row.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            row.isLayoutMarginsRelativeArrangement = true
            departmentStack.addArrangedSubview(row)

            if index < min(viewModel.departments.count, 5) - 1 {
                let divider = UIView()
                divider.backgroundColor = .separator.withAlphaComponent(0.25)
                divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
                departmentStack.addArrangedSubview(divider)
            }
        }
    }

    private func renderGenderDistribution() {
        genderStack.arrangedSubviews.forEach {
            genderStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let total = viewModel.genderDistribution.reduce(0) { $0 + $1.count }

        guard total > 0 else {
            let emptyLabel = UILabel()
            emptyLabel.text = "Gender information is not available."
            emptyLabel.font = .preferredFont(forTextStyle: .footnote)
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.numberOfLines = 0
            emptyLabel.textAlignment = .center
            genderStack.addArrangedSubview(emptyLabel)
            return
        }

        for (index, item) in viewModel.genderDistribution.enumerated() {
            let nameLabel = UILabel()
            nameLabel.text = item.name
            nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
            nameLabel.textColor = .label

            let countLabel = UILabel()
            let percentage = Int((Double(item.count) / Double(total) * 100).rounded())
            countLabel.text = "\(item.count) · \(percentage)%"
            countLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            countLabel.textColor = .secondaryLabel
            countLabel.textAlignment = .right

            let labels = UIStackView(arrangedSubviews: [nameLabel, UIView(), countLabel])
            labels.axis = .horizontal
            labels.alignment = .center

            let progress = UIProgressView(progressViewStyle: .default)
            progress.progressTintColor = index == 0 ? .systemBlue : .systemPurple
            progress.trackTintColor = .tertiarySystemFill
            progress.setProgress(Float(item.count) / Float(total), animated: false)

            let itemStack = UIStackView(arrangedSubviews: [labels, progress])
            itemStack.axis = .vertical
            itemStack.spacing = 8
            itemStack.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            itemStack.isLayoutMarginsRelativeArrangement = true
            genderStack.addArrangedSubview(itemStack)

            if index < viewModel.genderDistribution.count - 1 {
                let divider = UIView()
                divider.backgroundColor = .separator.withAlphaComponent(0.25)
                divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
                genderStack.addArrangedSubview(divider)
            }
        }
    }

    private func renderRecentlyViewed() {
        peopleStack.arrangedSubviews.forEach {
            peopleStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let recentEmployees = viewModel.recentlyViewedEmployees

        guard !recentEmployees.isEmpty else {
            let emptyLabel = UILabel()
            emptyLabel.text = "Employees you open will appear here."
            emptyLabel.font = .preferredFont(forTextStyle: .footnote)
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.numberOfLines = 0
            emptyLabel.textAlignment = .center
            emptyLabel.layoutMargins = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
            peopleStack.addArrangedSubview(emptyLabel)
            return
        }

        for (index, employee) in recentEmployees.prefix(5).enumerated() {
            let avatar = UIImageView()
            avatar.translatesAutoresizingMaskIntoConstraints = false
            avatar.contentMode = .scaleAspectFill
            avatar.clipsToBounds = true
            avatar.layer.cornerRadius = 22
            avatar.backgroundColor = .tertiarySystemFill
            avatar.image = UIImage(systemName: "person.crop.circle.fill")
            avatar.tintColor = .tertiaryLabel

            ImageLoader.shared.load(from: employee.image) { [weak avatar] image in
                if let image { avatar?.image = image }
            }

            let name = UILabel()
            name.text = employee.fullName
            name.font = .systemFont(ofSize: 14, weight: .semibold)
            name.textColor = .label

            let role = UILabel()
            role.text = employee.role
            role.font = .systemFont(ofSize: 12)
            role.textColor = .secondaryLabel

            let text = UIStackView(arrangedSubviews: [name, role])
            text.axis = .vertical
            text.spacing = 3

            let row = UIStackView(arrangedSubviews: [avatar, text])
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 12
            row.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            row.isLayoutMarginsRelativeArrangement = true
            row.isUserInteractionEnabled = true
            row.tag = employee.id
            row.isAccessibilityElement = true
            row.accessibilityLabel = "\(employee.fullName), \(employee.role). Open profile."
            row.accessibilityTraits = .button
            row.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(recentEmployeeTapped(_:)))
            )

            avatar.widthAnchor.constraint(equalToConstant: 44).isActive = true
            avatar.heightAnchor.constraint(equalToConstant: 44).isActive = true
            peopleStack.addArrangedSubview(row)

            if index < min(recentEmployees.count, 5) - 1 {
                let divider = UIView()
                divider.backgroundColor = .separator.withAlphaComponent(0.25)
                divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
                peopleStack.addArrangedSubview(divider)
            }
        }
    }

    @objc private func recentEmployeeTapped(_ recognizer: UITapGestureRecognizer) {
        guard let employeeID = recognizer.view?.tag,
              let employee = viewModel.employee(withID: employeeID) else { return }

        navigationController?.pushViewController(
            EmployeeDetailViewController(employee: employee),
            animated: true
        )
    }

    @objc private func browseTapped() {
        onBrowseDirectory?()
    }
}
