import UIKit

final class EmployeeCell: UITableViewCell {
    static let reuseIdentifier = "EmployeeCell"

    private let avatarView = UIImageView()
    private let nameLabel = UILabel()
    private let roleLabel = UILabel()
    private let departmentLabel = UILabel()
    private let locationLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    private var representedID: Int?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 18
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.withAlphaComponent(0.18).cgColor
        contentView.layer.masksToBounds = true
        configureViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureViews() {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.backgroundColor = .tertiarySystemFill
        avatarView.layer.cornerRadius = 25
        avatarView.clipsToBounds = true

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = .label
        roleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        roleLabel.textColor = .secondaryLabel
        departmentLabel.font = .systemFont(ofSize: 10, weight: .bold)
        departmentLabel.textColor = .systemBlue
        locationLabel.font = .systemFont(ofSize: 11)
        locationLabel.textColor = .tertiaryLabel
        locationLabel.numberOfLines = 1
        locationLabel.lineBreakMode = .byTruncatingTail
        chevron.tintColor = .tertiaryLabel
        chevron.contentMode = .scaleAspectFit

        let textStack = UIStackView(arrangedSubviews: [nameLabel, roleLabel, departmentLabel, locationLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.translatesAutoresizingMaskIntoConstraints = false
        chevron.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(avatarView)
        contentView.addSubview(textStack)
        contentView.addSubview(chevron)
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            textStack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 10),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 88)
        ])
    }

    func configure(with employee: Employee) {
        representedID = employee.id
        nameLabel.text = employee.fullName
        roleLabel.text = employee.role
        departmentLabel.text = employee.department.uppercased()
        locationLabel.text = "\(employee.officeLocation)  ·  \(employee.email)"
        avatarView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarView.tintColor = .tertiaryLabel
        ImageLoader.shared.load(from: employee.image) { [weak self] image in
            guard let self, self.representedID == employee.id, let image else { return }
            self.avatarView.image = image
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        representedID = nil
        avatarView.image = UIImage(systemName: "person.crop.circle.fill")
    }
}
