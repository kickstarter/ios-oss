import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

protocol PledgeAmountViewControllerDelegate: AnyObject {
  func pledgeAmountViewController(
    _ viewController: PledgeAmountViewController,
    didUpdateWith data: PledgeAmountData
  )
}

final class PledgeAmountViewController: UIViewController {
  // MARK: - Properties

  public weak var delegate: PledgeAmountViewControllerDelegate?
  private let viewModel: PledgeAmountViewModelType = PledgeAmountViewModel()

  private lazy var adaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var amountInputView: AmountInputView = { AmountInputView(frame: .zero) }()
  private lazy var maxPledgeAmountErrorLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var minPledgeAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var horizontalSpacer: UIView = { UIView(frame: .zero) }()
  private lazy var stepper: UIStepper = { UIStepper(frame: .zero) }()
  private lazy var verticalSpacer: UIView = { UIView(frame: .zero) }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.accessibilityElements .~ [self.titleLabel, self.stepper, self.amountInputView]

    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([
      self.titleLabel,
      self.minPledgeAmountLabel,
      self.adaptableStackView,
      self.maxPledgeAmountErrorLabel,
      self.verticalSpacer
    ], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.stepper, self.horizontalSpacer, self.amountInputView], self.adaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.amountInputView.textField.delegate = self

    self.amountInputView.doneButton.addTarget(
      self,
      action: #selector(PledgeAmountViewController.doneButtonTapped(_:)),
      for: .touchUpInside
    )

    self.amountInputView.textField.addTarget(
      self,
      action: #selector(PledgeAmountViewController.textFieldDidChange(_:)),
      for: .editingChanged
    )

    self.stepper.addTarget(
      self,
      action: #selector(PledgeAmountViewController.stepperValueChanged(_:)),
      for: .valueChanged
    )
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    let isAccessibilityCategory = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.adaptableStackView
      |> adaptableStackViewStyle(isAccessibilityCategory)
      |> \.spacing .~ Styles.grid(3)

    _ = self.horizontalSpacer
      |> \.isHidden .~ isAccessibilityCategory

    _ = self.titleLabel
      |> checkoutBackgroundStyle
    _ = self.titleLabel
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in Strings.Your_pledge_amount() }

    _ = self.rootStackView
      |> checkoutStackViewStyle

    _ = self.stepper
      |> stepperStyle

    _ = self.minPledgeAmountLabel
      |> minPledgeAmountLabelStyle

    _ = self.maxPledgeAmountErrorLabel
      |> maxPledgeAmountErrorLabelStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.amountInputView.doneButton.rac.enabled = self.viewModel.outputs.doneButtonIsEnabled
    self.amountInputView.label.rac.text = self.viewModel.outputs.currency
    self.amountInputView.label.rac.textColor = self.viewModel.outputs.labelTextColor
    self.amountInputView.textField.rac.isFirstResponder = self.viewModel.outputs.textFieldIsFirstResponder
    self.amountInputView.textField.rac.text = self.viewModel.outputs.textFieldValue
    self.amountInputView.textField.rac.textColor = self.viewModel.outputs.textFieldTextColor
    self.maxPledgeAmountErrorLabel.rac.hidden = self.viewModel.outputs.maxPledgeAmountErrorLabelIsHidden
    self.maxPledgeAmountErrorLabel.rac.text = self.viewModel.outputs.maxPledgeAmountErrorLabelText
    self.minPledgeAmountLabel.rac.hidden = self.viewModel.outputs.minPledgeAmountLabelIsHidden
    self.minPledgeAmountLabel.rac.text = self.viewModel.outputs.minPledgeAmountLabelText
    self.stepper.rac.maximumValue = self.viewModel.outputs.stepperMaxValue
    self.stepper.rac.minimumValue = self.viewModel.outputs.stepperMinValue
    self.stepper.rac.value = self.viewModel.outputs.stepperValue

    self.viewModel.outputs.generateSelectionFeedback
      .observeForUI()
      .observeValues { generateSelectionFeedback() }

    self.viewModel.outputs.generateNotificationWarningFeedback
      .observeForUI()
      .observeValues { generateNotificationWarningFeedback() }

    self.viewModel.outputs.notifyDelegateAmountUpdated
      .observeForUI()
      .observeValues { [weak self] data in
        guard let self = self else { return }

        self.delegate?.pledgeAmountViewController(self, didUpdateWith: data)
      }
  }

  override func didMove(toParent _: UIViewController?) {
    self.verticalSpacer.isHidden = true
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

  // MARK: - Accessors

  func selectedShippingAmountChanged(to amount: Double) {
    self.viewModel.inputs.selectedShippingAmountChanged(to: amount)
  }
}

extension PledgeAmountViewController: UITextFieldDelegate {
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
    |> \.stepValue .~ 1.0
    |> \.tintColor .~ UIColor.clear
    <> UIStepper.lens.decrementImage(for: .normal) .~ image(named: "stepper-decrement-normal")
    <> UIStepper.lens.decrementImage(for: .disabled) .~ image(named: "stepper-decrement-disabled")
    <> UIStepper.lens.decrementImage(for: .highlighted) .~ image(named: "stepper-decrement-highlighted")
    <> UIStepper.lens.incrementImage(for: .normal) .~ image(named: "stepper-increment-normal")
    <> UIStepper.lens.incrementImage(for: .disabled) .~ image(named: "stepper-increment-disabled")
    <> UIStepper.lens.incrementImage(for: .highlighted) .~ image(named: "stepper-increment-highlighted")
}

private let minPledgeAmountLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_caption1()
    |> \.numberOfLines .~ 0
    |> \.textColor .~ UIColor.ksr_text_navy_600
}

private let maxPledgeAmountErrorLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_caption1()
    |> \.numberOfLines .~ 0
    |> \.textColor .~ UIColor.ksr_red_400
    |> \.textAlignment .~ .right
}
