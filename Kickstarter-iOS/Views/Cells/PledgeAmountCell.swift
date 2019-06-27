import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

protocol PledgeAmountCellDelegate: AnyObject {
  func pledgeAmountCell(_ cell: PledgeAmountCell, didUpdateAmount amount: Double)
}

final class PledgeAmountCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  public weak var delegate: PledgeAmountCellDelegate?
  private let viewModel = PledgeAmountCellViewModel()

  private lazy var adaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var amountInputView: AmountInputView = { AmountInputView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var spacer: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var stepper: UIStepper = { UIStepper(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    _ = self
      |> \.accessibilityElements .~ [self.titleLabel, self.stepper, self.amountInputView]

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.adaptableStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.stepper, self.spacer, self.amountInputView], self.adaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.amountInputView.textField.delegate = self

    self.spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: Styles.grid(3)).isActive = true

    self.amountInputView.doneButton.addTarget(
      self,
      action: #selector(PledgeAmountCell.doneButtonTapped(_:)),
      for: .touchUpInside
    )

    self.amountInputView.textField.addTarget(
      self,
      action: #selector(PledgeAmountCell.textFieldDidChange(_:)),
      for: .editingChanged
    )

    self.stepper.addTarget(
      self,
      action: #selector(PledgeAmountCell.stepperValueChanged(_:)),
      for: .valueChanged
    )

    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutBackgroundStyle

    _ = self.adaptableStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )

    _ = self.titleLabel
      |> checkoutBackgroundStyle
    _ = self.titleLabel
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in Strings.Your_pledge_amount() }

    _ = self.rootStackView
      |> checkoutStackViewStyle

    _ = self.stepper
      |> stepperStyle
  }

  // MARK: - Binding

  override func bindViewModel() {
    super.bindViewModel()

    self.amountInputView.doneButton.rac.enabled = self.viewModel.outputs.doneButtonIsEnabled
    self.amountInputView.label.rac.text = self.viewModel.outputs.currency
    self.amountInputView.textField.rac.isFirstResponder = self.viewModel.outputs.textFieldIsFirstResponder
    self.amountInputView.textField.rac.text = self.viewModel.outputs.textFieldValue
    self.stepper.rac.maximumValue = self.viewModel.outputs.stepperMaxValue
    self.stepper.rac.minimumValue = self.viewModel.outputs.stepperMinValue
    self.stepper.rac.value = self.viewModel.outputs.stepperValue

    self.viewModel.outputs.generateSelectionFeedback
      .observeForUI()
      .observeValues { generateSelectionFeedback() }

    self.viewModel.outputs.generateNotificationWarningFeedback
      .observeForUI()
      .observeValues { generateNotificationWarningFeedback() }

    self.viewModel.outputs.amountPrimitive
      .observeForUI()
      .observeValues { [weak self] amount in
        guard let self = self else { return }
        self.delegate?.pledgeAmountCell(self, didUpdateAmount: amount)
      }
  }

  // MARK: - Configuration

  func configureWith(value: (project: Project, reward: Reward)) {
    self.viewModel.inputs.configureWith(project: value.project, reward: value.reward)
  }

  // MARK: - Actions

  @objc func doneButtonTapped(_: UIButton) {
    self.viewModel.inputs.doneButtonTapped()
  }

  @objc func stepperValueChanged(_ stepper: UIStepper) {
    self.viewModel.inputs.stepperValueChanged(stepper.value)
  }

  @objc func textFieldDidChange(_ textField: UITextField) {
    self.viewModel.inputs.textFieldValueChanged(textField.text)
  }
}

extension PledgeAmountCell: UITextFieldDelegate {
  func textField(
    _ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String
  ) -> Bool {
    let decimalSeparatorCharacters = CharacterSet.ksr_decimalSeparators()
    let existingCharacters = CharacterSet(charactersIn: textField.text.coalesceWith(""))
    let inputCharacters = CharacterSet(charactersIn: string)
    let numericCharacters = CharacterSet.ksr_numericCharacters()

    if numericCharacters.isSuperset(of: inputCharacters) {
      return true
    } else if decimalSeparatorCharacters.isSuperset(of: inputCharacters) {
      return !decimalSeparatorCharacters.isSubset(of: existingCharacters)
    } else {
      return false
    }
  }

  func textFieldDidEndEditing(_ textField: UITextField, reason _: UITextField.DidEndEditingReason) {
    self.viewModel.inputs.textFieldDidEndEditing(textField.text)
  }
}

// MARK: - Styles

private func stepperStyle(_ stepper: UIStepper) -> UIStepper {
  return stepper
    |> \.tintColor .~ UIColor.clear
    <> UIStepper.lens.decrementImage(for: .normal) .~ image(named: "stepper-decrement-normal")
    <> UIStepper.lens.decrementImage(for: .disabled) .~ image(named: "stepper-decrement-disabled")
    <> UIStepper.lens.decrementImage(for: .highlighted) .~ image(named: "stepper-decrement-highlighted")
    <> UIStepper.lens.incrementImage(for: .normal) .~ image(named: "stepper-increment-normal")
    <> UIStepper.lens.incrementImage(for: .disabled) .~ image(named: "stepper-increment-disabled")
    <> UIStepper.lens.incrementImage(for: .highlighted) .~ image(named: "stepper-increment-highlighted")
}
