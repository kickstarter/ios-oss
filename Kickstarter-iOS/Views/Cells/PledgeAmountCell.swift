import Library
import Prelude
import UIKit

final class PledgeAmountCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var amountInputView: AmountInputView = { AmountInputView(frame: .zero) }()
  private lazy var inputStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var label: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var spacer: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  } ()
  private lazy var stepper: UIStepper = { UIStepper(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    _ = self
      |> \.accessibilityElements .~ [self.label, self.stepper, self.amountInputView]
      |> \.backgroundColor .~ UIColor.ksr_grey_300

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.rootStackView.addArrangedSubview(self.label)
    self.rootStackView.addArrangedSubview(self.inputStackView)
    self.inputStackView.addArrangedSubview(self.stepper)
    self.inputStackView.addArrangedSubview(spacer)
    self.inputStackView.addArrangedSubview(self.amountInputView)

    self.spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: Styles.grid(3)).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.inputStackView
      |> inputStackViewStyle(self.traitCollection.ksr_isAccessibilityCategory())

    _ = self.label
      |> labelStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.stepper
      |> stepperStyle
  }

  // MARK: - Configuration

  func configureWith(value: (amount: Double, currency: String)) {
    self.amountInputView.configureWith(
      amount: String(format: "%i", value.amount),
      placeholder: "\(0)",
      currency: value.currency
    )
  }
}

// MARK: - Styles

private func inputStackViewStyle(_ isAccessibilityCategory: Bool) -> ((UIStackView) -> UIStackView) {
  return { (stackView: UIStackView) in
    let alignment: UIStackView.Alignment = (isAccessibilityCategory ? .leading : .center)
    let axis: NSLayoutConstraint.Axis = (isAccessibilityCategory ? .vertical : .horizontal)
    let distribution: UIStackView.Distribution = (isAccessibilityCategory ? .equalSpacing : .fill)
    let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : 0)

    return stackView
      |> \.alignment .~ alignment
      |> \.axis .~ axis
      |> \.distribution .~ distribution
      |> \.spacing .~ spacing
  }
}

private let labelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_headline()
    |> \.numberOfLines .~ 0
    |> \.text %~ { _ in Strings.Your_pledge_amount() }
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets(
      top: Styles.grid(2), left: Styles.grid(4), bottom: Styles.grid(3), right: Styles.grid(4)
    )
    |> \.spacing .~ (Styles.grid(1) + Styles.gridHalf(1))
}

private func stepperStyle(_ stepper: UIStepper) -> UIStepper {
  stepper.setDecrementImage(UIImage(named: "stepper-decrement-normal"), for: .normal)
  stepper.setDecrementImage(UIImage(named: "stepper-decrement-disabled"), for: .disabled)
  stepper.setDecrementImage(UIImage(named: "stepper-decrement-highlighted"), for: .highlighted)
  stepper.setIncrementImage(UIImage(named: "stepper-increment-normal"), for: .normal)
  stepper.setIncrementImage(UIImage(named: "stepper-increment-disabled"), for: .disabled)
  stepper.setIncrementImage(UIImage(named: "stepper-increment-highlighted"), for: .highlighted)
  return stepper
    |> \.tintColor .~ UIColor.clear
}
