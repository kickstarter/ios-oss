import KsApi
import Library
import Prelude
import ReactiveSwift
import Stripe
import UIKit

internal protocol AddNewCardViewControllerDelegate: AnyObject {
  func addNewCardViewController(
    _ viewController: AddNewCardViewController,
    didSucceedWithMessage message: String
  )
  func addNewCardViewControllerDismissed(_ viewController: AddNewCardViewController)
}

internal final class AddNewCardViewController: UIViewController,
  STPPaymentCardTextFieldDelegate, MessageBannerViewControllerPresenting {
  internal weak var delegate: AddNewCardViewControllerDelegate?

  @IBOutlet private var cardholderNameLabel: UILabel!
  @IBOutlet private var cardholderNameTextField: UITextField!
  @IBOutlet private var creditCardTextField: STPPaymentCardTextField!
  @IBOutlet private var creditCardValidationErrorLabel: UILabel!
  @IBOutlet private var creditCardValidationErrorContainer: UIView!
  @IBOutlet private var scrollView: UIScrollView!
  @IBOutlet private var stackView: UIStackView!
  @IBOutlet private var zipcodeView: SettingsFormFieldView!

  private let supportedCardBrands: [STPCardBrand] = [
    .amex,
    .dinersClub,
    .discover,
    .JCB,
    .masterCard,
    .unionPay,
    .visa
  ]

  private var saveButtonView: LoadingBarButtonItemView!

  internal var messageBannerViewController: MessageBannerViewController?

  fileprivate let viewModel: AddNewCardViewModelType = AddNewCardViewModel()

  internal static func instantiate() -> AddNewCardViewController {
    return Storyboard.Settings.instantiate(AddNewCardViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.cardholderNameTextField.addTarget(
      self,
      action: #selector(self.cardholderNameTextFieldReturn),
      for: .editingDidEndOnExit
    )

    self.cardholderNameTextField.addTarget(
      self,
      action: #selector(self.cardholderNameTextFieldChanged(_:)),
      for: [.editingDidEndOnExit, .editingChanged]
    )

    let cancelButton = UIBarButtonItem(
      title: Strings.Cancel(),
      style: .plain,
      target: self,
      action: #selector(self.cancelButtonTapped)
    )
    cancelButton.tintColor = .ksr_green_700
    self.navigationItem.leftBarButtonItem = cancelButton

    self.saveButtonView = LoadingBarButtonItemView.instantiate()
    self.saveButtonView.setTitle(title: Strings.Save())
    self.saveButtonView.addTarget(self, action: #selector(self.saveButtonTapped))

    let navigationBarButton = UIBarButtonItem(customView: self.saveButtonView)
    self.navigationItem.setRightBarButton(navigationBarButton, animated: false)

    self.zipcodeView.textField.addTarget(
      self, action: #selector(zipcodeTextFieldDoneEditing),
      for: .editingDidEndOnExit
    )

    self.zipcodeView.textField.addTarget(
      self, action: #selector(zipcodeTextFieldChanged(textField:)),
      for: .editingChanged
    )

    self.creditCardTextField.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle

    _ = self.cardholderNameLabel
      |> settingsTitleLabelStyle
      |> cardholderNameLabelStyle

    _ = self.cardholderNameTextField
      |> formFieldStyle
      |> cardholderNameTextFieldStyle
      |> \.accessibilityLabel .~ self.cardholderNameLabel.text

    _ = self.creditCardTextField
      |> creditCardTextFieldStyle

    _ = self.creditCardValidationErrorLabel
      |> settingsDescriptionLabelStyle
      |> \.textColor .~ .ksr_red_400
      |> \.text %~ { _ in Strings.Unsupported_card_type() }

    _ = self.scrollView
      |> \.alwaysBounceVertical .~ true

    _ = self.stackView
      |> \.layoutMargins .~ .init(leftRight: Styles.grid(2))

    _ = self.zipcodeView.titleLabel
      |> \.text %~ { _ in
        localizedPostalCode()
      }

    _ = self.zipcodeView
      |> \.autocapitalizationType .~ .allCharacters
      |> \.returnKeyType .~ .done
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.creditCardValidationErrorContainer.rac.hidden =
      self.viewModel.outputs.creditCardValidationErrorContainerHidden
    self.cardholderNameTextField.rac.becomeFirstResponder =
      self.viewModel.outputs.cardholderNameBecomeFirstResponder

    self.viewModel.outputs.creditCardValidationErrorContainerHidden
      .filter(isFalse)
      .observeForUI()
      .observeValues { _ in
        UIAccessibility.post(
          notification: .layoutChanged,
          argument: self.creditCardValidationErrorLabel
        )
      }

    self.viewModel.outputs.paymentDetailsBecomeFirstResponder
      .observeForUI()
      .observeValues { [weak self] in
        self?.creditCardTextField.becomeFirstResponder()
      }

    self.viewModel.outputs.saveButtonIsEnabled
      .observeForUI()
      .observeValues { [weak self] isEnabled in
        self?.saveButtonView.setIsEnabled(isEnabled: isEnabled)
      }

    self.viewModel.outputs.setStripePublishableKey
      .observeForUI()
      .observeValues {
        STPPaymentConfiguration.shared().publishableKey = $0
      }

    self.viewModel.outputs.dismissKeyboard
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        self?.dismissKeyboard()
      }

    self.viewModel.outputs.paymentDetails
      .observeForUI()
      .observeValues { [weak self] paymentDetails in
        self?.createStripeToken(with: paymentDetails)
      }

    self.viewModel.outputs.activityIndicatorShouldShow
      .observeForUI()
      .observeValues { [weak self] shouldShow in
        if shouldShow {
          self?.saveButtonView.startAnimating()
        } else {
          self?.saveButtonView.stopAnimating()
        }
      }

    self.viewModel.outputs.addNewCardSuccess
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.dismissAndPresentMessageBanner(with: message)
      }

    self.viewModel.outputs.addNewCardFailure
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
        self?.messageBannerViewController?.showBanner(with: .error, message: errorMessage)
      }

    self.viewModel.outputs.zipcodeTextFieldBecomeFirstResponder
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        self?.zipcodeView.textField.becomeFirstResponder()
      }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.scrollView.handleKeyboardVisibilityDidChange(change)
      }
  }

  @objc fileprivate func cancelButtonTapped() {
    self.delegate?.addNewCardViewControllerDismissed(self)
  }

  @objc fileprivate func saveButtonTapped() {
    self.viewModel.inputs.saveButtonTapped()
  }

  @objc func cardholderNameTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.cardholderNameChanged(textField.text)
  }

  @objc func cardholderNameTextFieldReturn(_: UITextField) {
    self.viewModel.inputs.cardholderNameTextFieldReturn()
  }

  // MARK: - Functions

  private func createStripeToken(with paymentDetails: PaymentDetails) {
    let cardParams = STPCardParams()
    cardParams.name = paymentDetails.cardholderName
    cardParams.number = paymentDetails.cardNumber
    cardParams.expMonth = paymentDetails.expMonth
    cardParams.expYear = paymentDetails.expYear
    cardParams.cvc = paymentDetails.cvc
    cardParams.address.postalCode = paymentDetails.postalCode

    STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
      if let token = token {
        self.viewModel.inputs.stripeCreated(token.tokenId, stripeID: token.stripeID)
      } else {
        self.viewModel.inputs.stripeError(error)
      }
    }
  }

  private func cardBrandIsSupported(brand: STPCardBrand, supportedCardBrands _: [STPCardBrand]) -> Bool {
    return self.supportedCardBrands.contains(brand)
  }

  private func dismissAndPresentMessageBanner(with message: String) {
    self.delegate?.addNewCardViewController(self, didSucceedWithMessage: message)
  }

  private func dismissKeyboard() {
    [self.cardholderNameTextField, self.creditCardTextField, self.zipcodeView.textField]
      .forEach { $0?.resignFirstResponder() }
  }
}

// MARK: - Zipcode UITextField Delegate

extension AddNewCardViewController {
  @objc internal func zipcodeTextFieldDoneEditing() {
    self.viewModel.inputs.zipcodeTextFieldDidEndEditing()
  }

  @objc internal func zipcodeTextFieldChanged(textField: UITextField) {
    self.viewModel.inputs.zipcodeChanged(zipcode: textField.text)
  }
}

// MARK: - STPPaymentCardTextFieldDelegate

extension AddNewCardViewController {
  internal func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
    self.viewModel.inputs.paymentInfo(isValid: textField.isValid)

    guard let cardnumber = textField.cardNumber else {
      return
    }

    let cardBrand = STPCardValidator.brand(forNumber: cardnumber)
    let isValid = self.cardBrandIsSupported(brand: cardBrand, supportedCardBrands: self.supportedCardBrands)

    self.viewModel.inputs.cardBrand(isValid: isValid)

    self.viewModel.inputs.creditCardChanged(cardDetails: (
      cardnumber, textField.expirationMonth,
      textField.expirationYear, textField.cvc
    ))
  }

  internal func paymentCardTextFieldDidEndEditing(_: STPPaymentCardTextField) {
    self.viewModel.inputs.paymentCardTextFieldDidEndEditing()
  }
}

// MARK: - Styles

private let cardholderNameLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.isAccessibilityElement .~ false
    |> \.text %~ { _ in Strings.Cardholder_name() }
}

private let cardholderNameTextFieldStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.autocapitalizationType .~ .words
    |> \.returnKeyType .~ .next
    |> \.textAlignment .~ .right
    |> \.textColor .~ .ksr_text_dark_grey_500
    |> \.attributedPlaceholder .~ NSAttributedString(
      string: Strings.Name(),
      attributes: [NSAttributedString.Key.foregroundColor: UIColor.ksr_text_dark_grey_400]
    )
}

private typealias PaymentCardTextFieldStyle = (STPPaymentCardTextField) -> STPPaymentCardTextField

private let creditCardTextFieldStyle: PaymentCardTextFieldStyle = { (textField: STPPaymentCardTextField) in
  textField
    |> \.borderColor .~ nil
    |> \.font .~ .ksr_body()
    |> \.textColor .~ .ksr_text_dark_grey_500
    |> \.textErrorColor .~ .ksr_red_400
    |> \.cursorColor .~ .ksr_green_700
    |> \.placeholderColor .~ .ksr_text_dark_grey_400
}
