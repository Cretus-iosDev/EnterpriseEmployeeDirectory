import UIKit

/// Animated launch screen for Enterprise Employee Directory.
/// Built entirely with UIKit; no external assets or dependencies required.
final class SplashViewController: UIViewController {

    // MARK: - Configuration

    /// Change this if your app uses a different display name.
    private let appName = "Enterprise Directory"
    private let tagline = "PEOPLE. CONNECTED."

    /// Called after the splash animation completes.
    var onFinish: (() -> Void)?

    // MARK: - UI

    private let backgroundGradient = CAGradientLayer()
    private let glowView = UIView()
    private let logoContainer = UIView()
    private let logoView = DirectoryLogoView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enterprise Directory"
        label.font = .systemFont(ofSize: 29, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.text = "PEOPLE. CONNECTED."
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.62)
        label.textAlignment = .center
        label.attributedText = NSAttributedString(
            string: "PEOPLE. CONNECTED.",
            attributes: [.kern: 3.0]
        )
        return label
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.text = "Find the right people. Get work moving."
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.68)
        label.textAlignment = .center
        return label
    }()

    private let progressTrack = UIView()
    private let progressFill = UIView()
    private var didFinish = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startEntranceAnimation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
        backgroundGradient.cornerRadius = 0
        glowView.layer.cornerRadius = glowView.bounds.width / 2
        progressTrack.layer.cornerRadius = 2
        progressFill.layer.cornerRadius = 2
    }

    // MARK: - Setup

    private func setupBackground() {
        view.backgroundColor = UIColor(red: 0.035, green: 0.075, blue: 0.16, alpha: 1)

        backgroundGradient.colors = [
            UIColor(red: 0.035, green: 0.075, blue: 0.16, alpha: 1).cgColor,
            UIColor(red: 0.055, green: 0.15, blue: 0.27, alpha: 1).cgColor,
            UIColor(red: 0.035, green: 0.10, blue: 0.21, alpha: 1).cgColor
        ]
        backgroundGradient.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradient, at: 0)

        glowView.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.16)
        glowView.layer.shadowColor = UIColor.systemTeal.cgColor
        glowView.layer.shadowOpacity = 0.55
        glowView.layer.shadowRadius = 70
        glowView.layer.shadowOffset = .zero
        glowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(glowView)

        NSLayoutConstraint.activate([
            glowView.widthAnchor.constraint(equalToConstant: 230),
            glowView.heightAnchor.constraint(equalTo: glowView.widthAnchor),
            glowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glowView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -65)
        ])
    }

    private func setupLayout() {
        [logoContainer, logoView, titleLabel, taglineLabel, captionLabel,
         progressTrack, progressFill].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        logoContainer.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        logoContainer.layer.borderWidth = 1
        logoContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        logoContainer.layer.cornerRadius = 36
        logoContainer.layer.shadowColor = UIColor.black.cgColor
        logoContainer.layer.shadowOpacity = 0.22
        logoContainer.layer.shadowRadius = 28
        logoContainer.layer.shadowOffset = CGSize(width: 0, height: 14)

        progressTrack.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        progressTrack.clipsToBounds = true
        progressFill.backgroundColor = UIColor.systemTeal
        progressFill.transform = CGAffineTransform(scaleX: 0, y: 1)
        progressFill.layer.anchorPoint = CGPoint(x: 0, y: 0.5)

        view.addSubview(logoContainer)
        logoContainer.addSubview(logoView)
        view.addSubview(titleLabel)
        view.addSubview(taglineLabel)
        view.addSubview(captionLabel)
        view.addSubview(progressTrack)
        progressTrack.addSubview(progressFill)

        NSLayoutConstraint.activate([
            logoContainer.widthAnchor.constraint(equalToConstant: 132),
            logoContainer.heightAnchor.constraint(equalToConstant: 132),
            logoContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -105),

            logoView.leadingAnchor.constraint(equalTo: logoContainer.leadingAnchor, constant: 13),
            logoView.trailingAnchor.constraint(equalTo: logoContainer.trailingAnchor, constant: -13),
            logoView.topAnchor.constraint(equalTo: logoContainer.topAnchor, constant: 13),
            logoView.bottomAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: -13),

            titleLabel.topAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: 31),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),

            taglineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            captionLabel.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 15),
            captionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            captionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            progressTrack.widthAnchor.constraint(equalToConstant: 116),
            progressTrack.heightAnchor.constraint(equalToConstant: 4),
            progressTrack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressTrack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48),

            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressTrack.widthAnchor)
        ])

        // Keep the title configurable from one place.
        titleLabel.text = appName
        taglineLabel.text = tagline
    }

    // MARK: - Animation

    private func startEntranceAnimation() {
        logoContainer.alpha = 0
        logoContainer.transform = CGAffineTransform(scaleX: 0.72, y: 0.72)
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 14)
        taglineLabel.alpha = 0
        captionLabel.alpha = 0

        UIView.animate(
            withDuration: 0.85,
            delay: 0.12,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.45,
            options: [.curveEaseOut]
        ) {
            self.logoContainer.alpha = 1
            self.logoContainer.transform = .identity
        }

        UIView.animate(withDuration: 0.65, delay: 0.42, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
            self.taglineLabel.alpha = 1
        }

        UIView.animate(withDuration: 0.65, delay: 0.68, options: .curveEaseOut) {
            self.captionLabel.alpha = 1
        }

        UIView.animate(withDuration: 1.35, delay: 0.45, options: .curveEaseInOut) {
            self.progressFill.transform = .identity
        }

        // Subtle breathing glow.
        UIView.animate(
            withDuration: 1.8,
            delay: 0.8,
            options: [.autoreverse, .repeat, .allowUserInteraction]
        ) {
            self.glowView.alpha = 0.55
            self.logoContainer.transform = CGAffineTransform(scaleX: 1.025, y: 1.025)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.35) { [weak self] in
            self?.finishSplash()
        }
    }

    private func finishSplash() {
        guard !didFinish else { return }
        didFinish = true

        UIView.animate(withDuration: 0.35, animations: {
            self.view.alpha = 0
        }, completion: { [weak self] _ in
            self?.onFinish?()
        })
    }
}

// MARK: - Logo

private final class DirectoryLogoView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let white = UIColor.white
        let teal = UIColor(red: 0.26, green: 0.91, blue: 0.83, alpha: 1)
        let blue = UIColor(red: 0.34, green: 0.66, blue: 1, alpha: 1)

        // Three connected employee profile circles.
        let people: [(CGPoint, CGFloat, UIColor)] = [
            (CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.29), 15, white),
            (CGPoint(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.43), 11, blue),
            (CGPoint(x: rect.maxX - rect.width * 0.25, y: rect.minY + rect.height * 0.43), 11, teal)
        ]

        for (center, radius, color) in people {
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
        }

        // Shared directory/network line.
        context.setStrokeColor(white.withAlphaComponent(0.88).cgColor)
        context.setLineWidth(4)
        context.setLineCap(.round)
        context.move(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.44))
        context.addLine(to: CGPoint(x: rect.minX + rect.width * 0.25,
                                    y: rect.minY + rect.height * 0.58))
        context.move(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.44))
        context.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.25,
                                    y: rect.minY + rect.height * 0.58))
        context.strokePath()

        // Employee directory card.
        let card = CGRect(
            x: rect.minX + rect.width * 0.16,
            y: rect.minY + rect.height * 0.59,
            width: rect.width * 0.68,
            height: rect.height * 0.25
        )
        let cardPath = UIBezierPath(roundedRect: card, cornerRadius: 8)
        context.setFillColor(white.withAlphaComponent(0.96).cgColor)
        context.addPath(cardPath.cgPath)
        context.fillPath()

        // Card rows.
        context.setFillColor(UIColor(red: 0.16, green: 0.29, blue: 0.45, alpha: 1).cgColor)
        for index in 0..<2 {
            let y = card.minY + 9 + CGFloat(index) * 10
            let line = CGRect(x: card.minX + 11, y: y, width: card.width * 0.55, height: 3)
            let linePath = UIBezierPath(roundedRect: line, cornerRadius: 1.5)
            context.addPath(linePath.cgPath)
            context.fillPath()
        }

        // Small accent dot on the card.
        context.setFillColor(teal.cgColor)
        context.fillEllipse(in: CGRect(
            x: card.maxX - 18,
            y: card.minY + 9,
            width: 8,
            height: 8
        ))
    }
}
