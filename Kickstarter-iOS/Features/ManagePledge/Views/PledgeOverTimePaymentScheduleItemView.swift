import Library
import UIKit

private enum Constants {
  static let badgeTopButtonPadding = 6.0
  static let badgeLeadingTrailingPadding = 8.0
  static let cornerRadius = Styles.grid(1)
  static let stackViewSpacing = Styles.grid(1)
}

import UIKit

final class PledgeOverTimePaymentScheduleItemView: UIView {
  // MARK: - Properties

  private lazy var amountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var badgeView: UIView = { UIView(frame: .zero) }()
  private lazy var badgeLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var dateAndStatusStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var dateLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
    self.bindStyles()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  private func configureViews() {
    self.addSubview(self.amountLabel)
    self.addSubview(self.dateAndStatusStackView)

    self.dateAndStatusStackView.addArrangedSubviews(
      self.dateLabel,
      self.badgeView
    )

    self.badgeView.addSubview(self.badgeLabel)
  }

  private func setupConstraints() {
    self.amountLabel.translatesAutoresizingMaskIntoConstraints = false
    self.amountLabel.setContentCompressionResistancePriority(.required, for: .vertical)

    NSLayoutConstraint.activate([
      self.amountLabel.leadingAnchor
        .constraint(equalTo: self.dateAndStatusStackView.trailingAnchor),
      self.amountLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.amountLabel.topAnchor.constraint(equalTo: self.topAnchor),
      self.amountLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor)

    ])

    self.dateAndStatusStackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.dateAndStatusStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.dateAndStatusStackView.topAnchor.constraint(equalTo: self.topAnchor),
      self.dateAndStatusStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])

    self.badgeLabel.translatesAutoresizingMaskIntoConstraints = false

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

  public func configure(
    with date: String,
    badgeTitle: String,
    badgeBackgroundColor: UIColor,
    badgeTextColor: UIColor,
    amountAttributedText: NSAttributedString?
  ) {
    self.dateLabel.text = date
    self.badgeLabel.text = badgeTitle
    self.badgeView.backgroundColor = badgeBackgroundColor
    self.badgeLabel.textColor = badgeTextColor
    self.amountLabel.attributedText = amountAttributedText
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    applyDateAndStatusStackViewStyle(self.dateAndStatusStackView)
    applyDateLabelStyle(self.dateLabel)
    applyBadgeViewStyle(self.badgeView)
    applyBadgeLabelStyle(self.badgeLabel)
    applyAmountLabelStyle(self.amountLabel)
  }
}

private func applyDateAndStatusStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Constants.stackViewSpacing
  stackView.alignment = .leading
}

private func applyDateLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_subhead().bolded
  label.textColor = .ksr_black
}

private func applyBadgeViewStyle(_ view: UIView) {
  view.rounded(with: Constants.cornerRadius)
}

private func applyBadgeLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_caption1().bolded
  label.adjustsFontForContentSizeCategory = true
}

private func applyAmountLabelStyle(_ label: UILabel) {
  label.textAlignment = .right
  label.adjustsFontForContentSizeCategory = true
}
