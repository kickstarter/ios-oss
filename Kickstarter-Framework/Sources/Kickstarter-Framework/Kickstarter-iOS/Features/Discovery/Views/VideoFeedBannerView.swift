import KDS
import UIKit

internal final class VideoFeedBannerView: UIView {
  internal var onTryItNowTapped: (() -> Void)?

  // MARK: - Subviews

  private let cardView = UIView()
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let ctaButton = UIButton(type: .system)

  /// Thumbnail background on the right
  private let thumbnailView = UIView()

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setupView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    self.setupView()
  }

  // MARK: - Public

  internal func configure(
    title: String = "Try our new discovery mode",
    subtitle: String = "Swipe through a video feed, tuning your recommendations along the way.",
    ctaTitle: String = "Try it now"
  ) {
    self.titleLabel.text = title
    self.subtitleLabel.text = subtitle
    self.ctaButton.setTitle(ctaTitle, for: .normal)
  }

  // MARK: - Setup

  private func setupView() {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.backgroundColor = .clear

    self.setupCard()
    self.setupContent()
    self.configure(titleLabel: self.titleLabel, subtitleLabel: self.subtitleLabel)
    self.configureCTAButton(self.ctaButton)
    self.configureThumbnail(self.thumbnailView)

    self.configure()
  }

  private func setupCard() {
    self.cardView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(self.cardView)

    /// Light purple tint similar to the screenshot
    self.cardView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.12)
    self.cardView.layer.cornerRadius = 16
    self.cardView.layer.masksToBounds = true

    NSLayoutConstraint.activate([
      self.cardView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.cardView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.cardView.topAnchor.constraint(equalTo: self.topAnchor),
      self.cardView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }

  private func setupContent() {
    /// Left side: title + subtitle + button
    let textStack = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel, self.ctaButton])
    textStack.translatesAutoresizingMaskIntoConstraints = false
    textStack.axis = .vertical
    textStack.alignment = .leading
    textStack.spacing = 8

    /// Right side: thumbnail with play icon
    self.thumbnailView.translatesAutoresizingMaskIntoConstraints = false

    let rootStack = UIStackView(arrangedSubviews: [textStack, self.thumbnailView])
    rootStack.translatesAutoresizingMaskIntoConstraints = false
    rootStack.axis = .horizontal
    rootStack.alignment = .center
    rootStack.spacing = 12

    self.cardView.addSubview(rootStack)

    NSLayoutConstraint.activate([
      rootStack.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor, constant: 16),
      rootStack.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor, constant: -16),
      rootStack.topAnchor.constraint(equalTo: self.cardView.topAnchor, constant: 14),
      rootStack.bottomAnchor.constraint(equalTo: self.cardView.bottomAnchor, constant: -14),

      self.thumbnailView.widthAnchor.constraint(equalToConstant: 86),
      self.thumbnailView.heightAnchor.constraint(equalToConstant: 64)
    ])
  }

  private func configure(titleLabel: UILabel, subtitleLabel: UILabel) {
    titleLabel.numberOfLines = 1
    titleLabel.lineBreakMode = .byTruncatingTail
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    titleLabel.textColor = .label

    /// Subtitle
    subtitleLabel.numberOfLines = 2
    subtitleLabel.lineBreakMode = .byTruncatingTail
    subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    subtitleLabel.textColor = .secondaryLabel
  }

  private func configureCTAButton(_ button: UIButton) {
    /// Pill button
    button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    button.setTitleColor(.label, for: .normal)
    button.backgroundColor = .systemBackground
    button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    button.layer.cornerRadius = 18
    button.layer.masksToBounds = true

    button.addTarget(self, action: #selector(self.ctaTapped), for: .touchUpInside)
  }

  private func configureThumbnail(_ thumbnailView: UIView) {
    /// Rounded thumbnail placeholder
    thumbnailView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.9)
    thumbnailView.layer.cornerRadius = 12
    thumbnailView.layer.masksToBounds = true
  }

  // MARK: - Actions

  @objc private func ctaTapped() {
    /// Forward the tap without forcing navigation logic into the view
    self.onTryItNowTapped?()
  }
}
