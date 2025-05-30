import Library
import UIKit

private enum Constants {
  /// Spacing & Padding
  public static let badgeTopButtonPadding = 6.0
  public static let badgeLeadingTrailingPadding = 8.0
  public static let defaultStackViewSpacing = Styles.grid(1)

  /// Corner radius
  public static let defaultCornerRadius = Styles.grid(1)
}

final class BadgeView: UIView {
  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private var imageView: UIImageView?
  private lazy var badgeLabel: UILabel = { UILabel(frame: .zero) }()
  private var style: BadgeStyle = .success

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.bindStyles()
    self.setupConstraints()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  private func configureSubviews() {
    self.addSubview(self.rootStackView)

    self.rootStackView.addArrangedSubview(self.badgeLabel)
  }

  private func setupConstraints() {
    self.rootStackView.translatesAutoresizingMaskIntoConstraints = false

    self.badgeLabel.setContentHuggingPriority(.required, for: .horizontal)
    self.badgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    self.badgeLabel.setContentHuggingPriority(.required, for: .vertical)
    self.badgeLabel.setContentCompressionResistancePriority(.required, for: .vertical)

    NSLayoutConstraint.activate([
      self.rootStackView.topAnchor.constraint(
        equalTo: self.topAnchor,
        constant: Constants.badgeTopButtonPadding
      ),
      self.rootStackView.bottomAnchor.constraint(
        equalTo: self.bottomAnchor,
        constant: -Constants.badgeTopButtonPadding
      ),
      self.rootStackView.leadingAnchor.constraint(
        equalTo: self.leadingAnchor,
        constant: Constants.badgeLeadingTrailingPadding
      ),
      self.rootStackView.trailingAnchor.constraint(
        equalTo: self.trailingAnchor,
        constant: -Constants.badgeLeadingTrailingPadding
      )
    ])
  }

  public func configure(with text: String, image: UIImage? = nil, style: BadgeStyle = .success) {
    self.badgeLabel.text = text
    self.style = style

    if let image = image {
      self.imageViewSetup(image)
    }

    self.updateStyle()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    applyRootStackViewStyle(self.rootStackView)
    applyBadgeViewStyle(self)
    applyBadgeLabelStyle(self.badgeLabel)
    self.updateStyle()
  }

  private func updateStyle() {
    self.badgeLabel.textColor = self.style.foregroundColor
    self.backgroundColor = self.style.backgroundColor
    self.imageView?.tintColor = self.style.foregroundColor
  }

  private func imageViewSetup(_ image: UIImage) {
    guard self.imageView == nil else { return }
    
    self.imageView = UIImageView(image: image)
    self.rootStackView.insertArrangedSubview(self.imageView!, at: 0)

    self.imageView?.setContentHuggingPriority(.required, for: .horizontal)
    self.imageView?.setContentCompressionResistancePriority(.required, for: .horizontal)
    self.imageView?.setContentHuggingPriority(.required, for: .vertical)
    self.imageView?.setContentCompressionResistancePriority(.required, for: .vertical)
  }
}

private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .horizontal
  stackView.spacing = Styles.grid(1)
  stackView.alignment = .leading
}

private func applyBadgeViewStyle(_ view: UIView) {
  view.rounded(with: Constants.defaultCornerRadius)
}

private func applyBadgeLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_caption1().bolded
  label.textAlignment = .center
  label.numberOfLines = 1
  label.adjustsFontForContentSizeCategory = true
}
