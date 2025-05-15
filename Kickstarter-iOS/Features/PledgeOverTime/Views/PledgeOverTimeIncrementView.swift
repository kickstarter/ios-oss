import Library
import UIKit

private enum Constants {
  /// Spacing
  public static let detailsStackViewSpacing = Styles.grid(6)
  public static let incrementStackViewSpacing = Styles.gridHalf(1)
}

final class PledgeOverTimeIncrementView: UIView {
  // MARK: - Properties

  private lazy var rootStackView = { UIStackView(frame: .zero) }()
  private lazy var detailsStackView = { UIStackView(frame: .zero) }()
  private lazy var chargeNumberLabel = { UILabel(frame: .zero) }()
  private lazy var dateLabel = { UILabel(frame: .zero) }()
  private lazy var amountLabel = { UILabel(frame: .zero) }()

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  private func configureSubviews() {
    self.addSubview(self.rootStackView)

    self.detailsStackView.addArrangedSubviews(self.dateLabel, self.amountLabel)
    self.rootStackView.addArrangedSubviews(self.chargeNumberLabel, self.detailsStackView)
  }

  private func setupConstraints() {
    self.rootStackView.constrainViewToEdges(in: self)
    self.dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    self.amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  override func bindStyles() {
    super.bindStyles()

    applyRootStackViewStyle(self.rootStackView)
    applyChargeNumberLabelStyle(self.chargeNumberLabel)
    applyDetailsStackViewStyle(self.detailsStackView)
    applyDateLabelStyle(self.dateLabel)
    applyDateLabelStyle(self.amountLabel)
  }

  func configure(with increment: PledgePaymentIncrementFormatted) {
    self.chargeNumberLabel.text = increment.incrementChargeNumber
    self.dateLabel.text = increment.scheduledCollection
    self.amountLabel.text = increment.amount
  }

  /// Configures the width of the date label to maintain consistent alignment across all increments.
  /// - Parameter widthGuide: A `UILayoutGuide` used as a reference for setting a uniform width.
  ///
  /// This ensures that all date labels have equal width, preventing misalignment of the amount labels.
  /// Instead of constraining each label directly, we use a `UILayoutGuide` as a reference width anchor.
  /// This avoids layout inconsistencies caused by varying date string lengths (e.g., "4 Jan 2025" vs. "14 Feb 2025").
  func configureDateLabelWidthGuide(_ widthGuide: UILayoutGuide) {
    self.dateLabel.widthAnchor.constraint(equalTo: widthGuide.widthAnchor).isActive = true
  }
}

// MARK: - Styles helper

private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Constants.incrementStackViewSpacing
}

private func applyDetailsStackViewStyle(_ stackview: UIStackView) {
  stackview.axis = .horizontal
  stackview.distribution = .fill
  stackview.spacing = Constants.detailsStackViewSpacing
}

private func applyChargeNumberLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_footnote().bolded
  label.textColor = LegacyColors.ksr_black.uiColor()
  label.textAlignment = .left
  label.adjustsFontForContentSizeCategory = true
  label.setContentCompressionResistancePriority(.required, for: .vertical)
}

private func applyDateLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_footnote()
  label.textColor = LegacyColors.ksr_support_400.uiColor()
  label.textAlignment = .left
  label.adjustsFontForContentSizeCategory = true
}
