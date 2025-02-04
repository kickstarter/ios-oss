import Library
import UIKit

private enum Constants {
  /// Spacing
  public static let defaultStackViewSpacing = Styles.grid(1)
}

final class PledgeOverTimeBadgeView: UIView {
  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var badgeView: BadgeView = { BadgeView(frame: .zero) }()
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

    self.badgeView.configure(with: Strings.Pledge_Over_Time(), style: .success)
  }

  private func setupConstraints() {
    self.rootStackView.constrainViewToEdges(in: self)
    self.badgeView.setContentHuggingPriority(.required, for: .horizontal)
    self.chargesLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
  }

  public func configure(with chargesLabelText: String) {
    self.chargesLabel.text = chargesLabelText
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    applyRootStackViewStyle(self.rootStackView)
    applyChargesLabelStyle(self.chargesLabel)
  }
}

private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .horizontal
  stackView.spacing = Constants.defaultStackViewSpacing
  stackView.alignment = .center
}

private func applyChargesLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_footnote()
  label.textColor = .ksr_support_700
  label.textAlignment = .right
  label.numberOfLines = 0
  label.adjustsFontForContentSizeCategory = true
}
