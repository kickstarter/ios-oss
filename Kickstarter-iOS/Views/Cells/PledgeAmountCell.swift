import Library
import Prelude
import UIKit

final class PledgeAmountCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var amountInputView: AmountInputView = { AmountInputView(frame: .zero) }()
  private lazy var inputStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var label: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var stepper: UIStepper = { UIStepper(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    _ = self
      |> \.backgroundColor .~ UIColor.hex(0xf0f0f0) // Extract to Colors.json

    self.contentView.addSubviewConstrainedToEdges(self.rootStackView)

    self.rootStackView.addArrangedSubview(self.label)
    self.rootStackView.addArrangedSubview(self.inputStackView)
    self.inputStackView.addArrangedSubview(self.stepper)
    self.inputStackView.addArrangedSubview(UIView(frame: .zero))
    self.inputStackView.addArrangedSubview(self.amountInputView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    let traitCollection = self.traitCollection

    if previousTraitCollection?.preferredContentSizeCategory
      != traitCollection.preferredContentSizeCategory {
      self.configureView(for: traitCollection)
    }
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.inputStackView
      |> inputStackViewStyle

    _ = self.label
      |> labelStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.stepper
      |> stepperStyle
  }

  // MARK: - Configuration

  private func configureView(for traitCollection: UITraitCollection) {
    let isAccessibilityCategory = self.traitCollection.ksr_isAccessibilityCategory()

    _ = self.inputStackView
      |> \.alignment .~ (isAccessibilityCategory ? .leading : .center)
      |> \.axis .~ (isAccessibilityCategory ? .vertical : .horizontal)
      |> \.distribution .~ (isAccessibilityCategory ? .equalSpacing : .fill)
      |> \.spacing .~ (isAccessibilityCategory ? Styles.grid(1) : 0)
  }

  func configureWith(value: Double) {
    self.amountInputView.configureWith(amount: value, placeholder: 0, currency: "$")
  }
}

// MARK: - Styles

private let inputStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.spacing .~ Styles.grid(1)
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
    |> \.axis .~ .vertical
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ .init(
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
