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

  public func configure(with text: String) {
    self.badgeLabel.text = text
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    applyBadgeViewStyle(self)
    applyBadgeLabelStyle(self.badgeLabel)
  }
}

private func applyBadgeViewStyle(_ view: UIView) {
  view.backgroundColor = .ksr_create_100
  view.rounded(with: Constants.defaultCornerRadius)
}

private func applyBadgeLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_subhead().bolded
  label.textColor = .ksr_create_700
  label.textAlignment = .center
  label.numberOfLines = 1
  label.adjustsFontForContentSizeCategory = true
}
