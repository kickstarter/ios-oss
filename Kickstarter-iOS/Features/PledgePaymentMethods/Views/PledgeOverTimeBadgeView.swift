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

final class PledgeOverTimeBadgeView: UIView {
  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var badgeView: UIView = { UIView(frame: .zero) }()
  private lazy var badgeLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var chargesLabel: UILabel = { UILabel(frame: .zero) }()

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

    self.rootStackView.addArrangedSubviews(
      self.badgeView,
      self.chargesLabel
    )

    self.badgeView.addSubview(self.badgeLabel)
    self.badgeLabel.text = Strings.Pledge_Over_Time()
  }

  private func setupConstraints() {
    self.rootStackView.constrainViewToEdges(in: self)
    self.badgeLabel.translatesAutoresizingMaskIntoConstraints = false
    self.badgeLabel.setContentHuggingPriority(.required, for: .horizontal)
    self.badgeView.setContentHuggingPriority(.required, for: .horizontal)
    self.chargesLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

    NSLayoutConstraint.activate([
      self.badgeLabel.topAnchor.constraint(
        equalTo: self.badgeView.topAnchor,
        constant: Constants.badgeTopButtonPadding
      ),
      self.badgeLabel.bottomAnchor.constraint(
        equalTo: self.badgeView.bottomAnchor,
        constant: -Constants.badgeTopButtonPadding
      ),
      self.badgeLabel.leadingAnchor.constraint(
        equalTo: self.badgeView.leadingAnchor,
        constant: Constants.badgeLeadingTrailingPadding
      ),
      self.badgeLabel.trailingAnchor.constraint(
        equalTo: self.badgeView.trailingAnchor,
        constant: -Constants.badgeLeadingTrailingPadding
      )
    ])
  }

  public func configure(with chargesLabelText: String) {
    self.chargesLabel.text = chargesLabelText
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    applyRootStackViewStyle(self.rootStackView)
    applyBadgeViewStyle(self.badgeView)
    applyBadgeLabelStyle(self.badgeLabel)
    applyChargesLabelStyle(self.chargesLabel)
  }
}

private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .horizontal
  stackView.spacing = Constants.defaultStackViewSpacing
  stackView.alignment = .center
}

private func applyBadgeViewStyle(_ view: UIView) {
  view.backgroundColor = .ksr_create_100
  view.rounded(with: Constants.defaultCornerRadius)
}

private func applyBadgeLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_caption1().bolded
  label.textColor = .ksr_create_700
  label.textAlignment = .center
  label.numberOfLines = 1
  label.adjustsFontForContentSizeCategory = true
}

private func applyChargesLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_footnote()
  label.textColor = .ksr_support_700
  label.textAlignment = .right
  label.numberOfLines = 0
  label.adjustsFontForContentSizeCategory = true
}
