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
    self.addSubview(self.badgeLabel)
  }

  private func setupConstraints() {
    self.badgeLabel.translatesAutoresizingMaskIntoConstraints = false
    self.badgeLabel.setContentHuggingPriority(.required, for: .horizontal)
    self.badgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    self.badgeLabel.setContentHuggingPriority(.required, for: .vertical)
    self.badgeLabel.setContentCompressionResistancePriority(.required, for: .vertical)

    NSLayoutConstraint.activate([
      self.badgeLabel.topAnchor.constraint(
        equalTo: self.topAnchor,
        constant: Constants.badgeTopButtonPadding
      ),
      self.badgeLabel.bottomAnchor.constraint(
        equalTo: self.bottomAnchor,
        constant: -Constants.badgeTopButtonPadding
      ),
      self.badgeLabel.leadingAnchor.constraint(
        equalTo: self.leadingAnchor,
        constant: Constants.badgeLeadingTrailingPadding
      ),
      self.badgeLabel.trailingAnchor.constraint(
        equalTo: self.trailingAnchor,
        constant: -Constants.badgeLeadingTrailingPadding
      )
    ])
  }

  public func configure(with text: String, style: BadgeStyle = .success) {
    self.badgeLabel.text = text
    self.style = style
    self.updateStyle()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    applyBadgeViewStyle(self)
    applyBadgeLabelStyle(self.badgeLabel)
    self.updateStyle()
  }

  private func updateStyle() {
    self.badgeLabel.textColor = self.style.foregroundColor
    self.backgroundColor = self.style.backgroundColor
  }
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
