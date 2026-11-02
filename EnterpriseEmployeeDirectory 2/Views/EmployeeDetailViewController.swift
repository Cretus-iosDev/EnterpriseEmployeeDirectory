import UIKit

final class EmployeeDetailViewController: UIViewController {

    private let employee: Employee

    // MARK: - Initialisation

    init(employee: Employee) {
        self.employee = employee
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLayout()
    }

    // MARK: - View Configuration

    private func configureView() {
        title = "Employee Profile"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never
    }

    private func configureLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        contentStack.addArrangedSubview(makeProfileHeader())

        contentStack.addArrangedSubview(makeInfoCard(
            title: "CONTACT INFORMATION",
            rows: [
                InfoRow(
                    symbol: "envelope",
                    title: "Work email",
                    value: employee.email,
                    actionTitle: "Send email",
                    actionSymbol: "arrow.up.right",
                    action: { [weak self] in self?.openEmail() }
                ),
                InfoRow(
                    symbol: "phone",
                    title: "Phone",
                    value: employee.phone,
                    actionTitle: "Call phone number",
                    actionSymbol: "phone.arrow.up.right",
                    action: { [weak self] in self?.callPhoneNumber() }
                ),
                InfoRow(
                    symbol: "person",
                    title: "Username",
                    value: employee.username ?? "Not available",
                    actionTitle: "Copy username",
                    actionSymbol: "doc.on.doc",
                    action: { [weak self] in self?.copyUsername() }
                )
            ]
        ))

        contentStack.addArrangedSubview(makeInfoCard(
            title: "WORK INFORMATION",
            rows: [
                InfoRow(symbol: "building.2", title: "Company", value: employee.company.name),
                InfoRow(symbol: "briefcase", title: "Job title", value: employee.role),
                InfoRow(symbol: "person.2", title: "Department", value: employee.department),
                InfoRow(symbol: "mappin.and.ellipse", title: "Office location", value: employee.officeLocation)
            ]
        ))

        contentStack.addArrangedSubview(makeInfoCard(
            title: "EMPLOYEE DETAILS",
            rows: [
                InfoRow(symbol: "number", title: "Employee ID", value: String(employee.id)),
                InfoRow(symbol: "calendar", title: "Age", value: employee.age.map(String.init) ?? "Not available"),
                InfoRow(symbol: "person.crop.circle", title: "Gender", value: employee.gender?.capitalized ?? "Not available")
            ]
        ))
    }

    // MARK: - Profile Header

    private func makeProfileHeader() -> UIView {
        let card = makeCard()

        let avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = 48
        avatar.backgroundColor = .tertiarySystemFill
        avatar.image = UIImage(systemName: "person.crop.circle.fill")
        avatar.tintColor = .secondaryLabel
        avatar.accessibilityLabel = "\(employee.fullName) profile photo"

        ImageLoader.shared.load(from: employee.image) { [weak avatar] image in
            guard let image else { return }
            DispatchQueue.main.async {
                avatar?.image = image
            }
        }

        let nameLabel = UILabel()
        nameLabel.text = employee.fullName
        nameLabel.font = .preferredFont(forTextStyle: .title2).withWeight(.bold)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        nameLabel.adjustsFontForContentSizeCategory = true

        let roleLabel = UILabel()
        roleLabel.text = employee.role
        roleLabel.font = .preferredFont(forTextStyle: .subheadline)
        roleLabel.textColor = .secondaryLabel
        roleLabel.textAlignment = .center
        roleLabel.numberOfLines = 0
        roleLabel.adjustsFontForContentSizeCategory = true

        let departmentLabel = UILabel()
        departmentLabel.text = employee.department.uppercased()
        departmentLabel.font = .preferredFont(forTextStyle: .caption1).withWeight(.bold)
        departmentLabel.textColor = .systemBlue
        departmentLabel.textAlignment = .center
        departmentLabel.numberOfLines = 0
        departmentLabel.adjustsFontForContentSizeCategory = true

        let profileStack = UIStackView(arrangedSubviews: [
            avatar,
            nameLabel,
            roleLabel,
            departmentLabel
        ])
        profileStack.axis = .vertical
        profileStack.alignment = .center
        profileStack.spacing = 8
        profileStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(profileStack)

        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 96),
            avatar.heightAnchor.constraint(equalToConstant: 96),
            profileStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 26),
            profileStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            profileStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            profileStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -26)
        ])

        return card
    }

    // MARK: - Information Cards

    private func makeInfoCard(title: String, rows: [InfoRow]) -> UIView {
        let card = makeCard()

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        let heading = UILabel()
        heading.text = title
        heading.font = .preferredFont(forTextStyle: .caption1).withWeight(.bold)
        heading.textColor = .secondaryLabel
        heading.adjustsFontForContentSizeCategory = true
        stack.addArrangedSubview(heading)

        for (index, rowData) in rows.enumerated() {
            stack.addArrangedSubview(makeInfoRow(rowData))

            if index < rows.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .separator
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
                stack.addArrangedSubview(separator)
            }
        }

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])

        return card
    }

    private func makeInfoRow(_ info: InfoRow) -> UIView {
        let iconView = UIImageView(image: UIImage(systemName: info.symbol))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .systemBlue
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        let titleLabel = UILabel()
        titleLabel.text = info.title
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .secondaryLabel
        titleLabel.adjustsFontForContentSizeCategory = true

        let valueLabel = UILabel()
        valueLabel.text = info.value
        valueLabel.font = .preferredFont(forTextStyle: .subheadline).withWeight(.medium)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.adjustsFontForContentSizeCategory = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        textStack.axis = .vertical
        textStack.spacing = 3

        let rowStack = UIStackView(arrangedSubviews: [iconView, textStack])
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 14

        if let action = info.action, let actionSymbol = info.actionSymbol {
            let actionButton = UIButton(type: .system)
            actionButton.setImage(UIImage(systemName: actionSymbol), for: .normal)
            actionButton.tintColor = .systemBlue
            actionButton.accessibilityLabel = info.actionTitle
            actionButton.accessibilityHint = info.actionTitle
            actionButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            rowStack.addArrangedSubview(actionButton)
        }

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20)
        ])

        return rowStack
    }

    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 20
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.separator.withAlphaComponent(0.18).cgColor
        return card
    }

    // MARK: - Contact Actions

    private func openEmail() {
        guard let url = URL(string: "mailto:\(employee.email)") else { return }
        UIApplication.shared.open(url)
    }

    private func callPhoneNumber() {
        let allowedCharacters = CharacterSet(charactersIn: "+0123456789")
        let phone = employee.phone
            .components(separatedBy: allowedCharacters.inverted)
            .joined()

        guard !phone.isEmpty,
              let url = URL(string: "tel:\(phone)") else { return }

        UIApplication.shared.open(url)
    }

    private func copyUsername() {
        guard let username = employee.username, !username.isEmpty else { return }
        UIPasteboard.general.string = username

        let alert = UIAlertController(
            title: "Username copied",
            message: "The username has been copied to your clipboard.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Done", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Supporting Types

private struct InfoRow {
    let symbol: String
    let title: String
    let value: String
    var actionTitle: String? = nil
    var actionSymbol: String? = nil
    var action: (() -> Void)? = nil
}

private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
