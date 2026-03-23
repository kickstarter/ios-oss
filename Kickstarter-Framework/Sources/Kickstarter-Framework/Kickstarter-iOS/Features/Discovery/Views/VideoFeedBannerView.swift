import KDS
import UIKit

internal final class VideoFeedBannerView: UIView {
  internal var onTryItNowTapped: (() -> Void)?

  // MARK: - Constants

  private enum Constants {
    // TODO: Update with Video Feed Translations [mbl=3158](https://kickstarter.atlassian.net/browse/MBL-3158)
    static let title = "Try our new discovery mode"
    static let subtitle = "Swipe through a video feed, tuning your recommendations along the way."
    static let ctaTitle = "Try it now"

    // Card
    static let cardCornerRadius: CGFloat = Spacing.unit_02
    static let cardBackgroundColor = Colors.Background.Accent.Purple.banner
    static let cardPadding: CGFloat = Spacing.unit_03

    // Layout
    static let rootStackSpacing: CGFloat = Spacing.unit_03
    static let textStackSpacing: CGFloat = Spacing.unit_02

    // Thumbnail
    static let thumbnailWidth: CGFloat = 110
    static let thumbnailHeight: CGFloat = 100

    // Text colors
    static let titleColor = Colors.Text.constantPrimary
    static let subtitleColor = Colors.Text.secondary

    // Subtitle label
    static let subtitleMaxLines: Int = 2

    // CTA Button
    static let ctaCornerRadius: CGFloat = Spacing.unit_04
    static let ctaContentInsets = UIEdgeInsets(
      top: Spacing.unit_02,
      left: Spacing.unit_03,
      bottom: Spacing.unit_02,
      right: Spacing.unit_03
    )
    static let ctaTextColor = Colors.Text.constantPrimary
    static let ctaBackgroundColor = UIColor.white
  }

  // MARK: - Subviews

  private let cardView = UIView()
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let ctaButton = UIButton(type: .system)

  private let thumbnailView = UIImageView(image: UIImage(named: "video-feed-banner-thumbnail"))

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

  internal func configure() {
    self.titleLabel.text = Constants.title
    self.subtitleLabel.text = Constants.subtitle
    self.ctaButton.setTitle(Constants.ctaTitle, for: .normal)
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

    self.cardView.backgroundColor = Constants.cardBackgroundColor.uiColor()
    self.cardView.layer.cornerRadius = Constants.cardCornerRadius
    self.cardView.layer.masksToBounds = true

    NSLayoutConstraint.activate([
      self.cardView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.cardView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.cardView.topAnchor.constraint(equalTo: self.topAnchor),
      self.cardView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }

  private func setupContent() {
    let textStack = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel, self.ctaButton])
    textStack.translatesAutoresizingMaskIntoConstraints = false
    textStack.axis = .vertical
    textStack.alignment = .leading
    textStack.spacing = Constants.textStackSpacing

    self.thumbnailView.translatesAutoresizingMaskIntoConstraints = false

    let rootStack = UIStackView(arrangedSubviews: [textStack, self.thumbnailView])
    rootStack.translatesAutoresizingMaskIntoConstraints = false
    rootStack.axis = .horizontal
    rootStack.alignment = .center
    rootStack.spacing = Constants.rootStackSpacing

    self.cardView.addSubview(rootStack)

    NSLayoutConstraint.activate([
      rootStack.leadingAnchor.constraint(
        equalTo: self.cardView.leadingAnchor,
        constant: Constants.cardPadding
      ),
      rootStack.trailingAnchor.constraint(
        equalTo: self.cardView.trailingAnchor,
        constant: -Constants.cardPadding
      ),
      rootStack.topAnchor.constraint(equalTo: self.cardView.topAnchor, constant: Constants.cardPadding),
      rootStack.bottomAnchor.constraint(
        equalTo: self.cardView.bottomAnchor,
        constant: -Constants.cardPadding
      ),

      self.thumbnailView.widthAnchor.constraint(equalToConstant: Constants.thumbnailWidth),
      self.thumbnailView.heightAnchor.constraint(equalToConstant: Constants.thumbnailHeight)
    ])
  }

  private func configure(titleLabel: UILabel, subtitleLabel: UILabel) {
    titleLabel.numberOfLines = 1
    titleLabel.lineBreakMode = .byTruncatingTail
    titleLabel.font = UIFont.ksr_headingLG()
    titleLabel.textColor = Constants.titleColor.uiColor()

    subtitleLabel.numberOfLines = Constants.subtitleMaxLines
    subtitleLabel.lineBreakMode = .byTruncatingTail
    subtitleLabel.font = UIFont.ksr_bodySM()
    subtitleLabel.textColor = Constants.subtitleColor.uiColor()
  }

  private func configureCTAButton(_ button: UIButton) {
    button.titleLabel?.font = UIFont.ksr_bodyMD()
    button.setTitleColor(Constants.ctaTextColor.uiColor(), for: .normal)
    button.backgroundColor = Constants.ctaBackgroundColor
    button.contentEdgeInsets = Constants.ctaContentInsets
    button.layer.cornerRadius = Constants.ctaCornerRadius
    button.layer.masksToBounds = true

    button.addTarget(self, action: #selector(self.ctaTapped), for: .touchUpInside)
  }

  private func configureThumbnail(_ thumbnailView: UIImageView) {
    thumbnailView.contentMode = .scaleAspectFit
    thumbnailView.layer.masksToBounds = true
  }

  // MARK: - Actions

  @objc private func ctaTapped() {
    self.onTryItNowTapped?()
  }
}
