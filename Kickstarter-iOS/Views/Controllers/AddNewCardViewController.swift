import KsApi
import Library
import Prelude
import ReactiveSwift
import Stripe
import UIKit

internal protocol AddNewCardViewControllerDelegate: class {
  func presentAddCardSuccessfulBanner(_ message: String)
}

internal final class AddNewCardViewController: UIViewController,
STPPaymentCardTextFieldDelegate, MessageBannerViewControllerPresenting {
  internal weak var delegate: AddNewCardViewControllerDelegate?

  @IBOutlet private weak var cardholderNameLabel: UILabel!
  @IBOutlet private weak var cardholderNameTextField: UITextField!
  @IBOutlet private weak var creditCardTextField: STPPaymentCardTextField!
  @IBOutlet private weak var creditCardValidationErrorLabel: UILabel!
  @IBOutlet private weak var creditCardValidationErrorContainer: UIView!
  @IBOutlet weak var zipcodeView: UIView!
  private let unsupportedCardBrands: [STPCardBrand] = [.unionPay, .unknown]

  private var saveButtonView: LoadingBarButtonItemView!
  private var zipcodeFormView: SettingsFormFieldView!
  internal var messageBannerViewController: MessageBannerViewController?

  fileprivate let viewModel: AddNewCardViewModelType = AddNewCardViewModel()

  internal static func instantiate() -> AddNewCardViewController {
    return Storyboard.Settings.instantiate(AddNewCardViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.cardholderNameTextField.addTarget(self,
                                           action: #selector(cardholderNameTextFieldReturn),
                                           for: .editingDidEndOnExit)

    self.cardholderNameTextField.addTarget(self,
                                           action: #selector(cardholderNameTextFieldChanged(_:)),
                                           for: [.editingDidEndOnExit, .editingChanged])

    let cancelButton = UIBarButtonItem(title: Strings.Cancel(),
                                       style: .plain,
                                       target: self,
                                       action: #selector(cancelButtonTapped))
    cancelButton.tintColor = .ksr_green_700
    self.navigationItem.leftBarButtonItem = cancelButton

    self.saveButtonView = LoadingBarButtonItemView.instantiate()
    self.saveButtonView.setTitle(title: Strings.Save())
    self.saveButtonView.addTarget(self, action: #selector(saveButtonTapped))

    let navigationBarButton = UIBarButtonItem(customView: self.saveButtonView)
    self.navigationItem.setRightBarButton(navigationBarButton, animated: false)

    self.zipcodeFormView = SettingsFormFieldView.instantiate()
    self.zipcodeFormView.frame = self.zipcodeView.bounds

    self.zipcodeFormView.textField.addTarget(self,
                                             action: #selector(zipcodeTextFieldDoneEditing),
                                             for: .editingDidEndOnExit)

    self.zipcodeFormView.textField.addTarget(self,
                                             action: #selector(zipcodeTextFieldChanged(textField:)),
                                             for: .editingChanged)

    self.zipcodeView.addSubview(zipcodeFormView)

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
      |> \.isAccessibilityElement .~ false
      |> \.text %~ { _ in Strings.Cardholder_name() }

    _ = self.cardholderNameTextField
      |> formFieldStyle
      |> \.autocapitalizationType .~ .words
      |> \.returnKeyType .~ .next
      |> \.textAlignment .~ .right
      |> \.textColor .~ .ksr_text_dark_grey_500

    _ = self.cardholderNameTextField
      |> \.accessibilityLabel .~ self.cardholderNameLabel.text
      |> \.attributedPlaceholder .~ NSAttributedString(
          string: Strings.Name(),
          attributes: [NSAttributedString.Key.foregroundColor: UIColor.ksr_text_dark_grey_400])

    _ = self.creditCardTextField
      |> \.borderColor .~ nil
      |> \.font .~ .ksr_body()
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.textErrorColor .~ .ksr_red_400

    _ = self.creditCardTextField
      |> \.cursorColor .~ .ksr_green_700
      |> \.placeholderColor .~ .ksr_text_dark_grey_400

    _ = self.creditCardValidationErrorLabel
      |> settingsDescriptionLabelStyle
      |> \.textColor .~ .ksr_red_400
      |> \.text %~ { _ in Strings.Unsupported_card_type() }

    _ = self.zipcodeFormView.titleLabel
      |> \.text %~ { _ in
        Strings.Zip_postal_code()
      }
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
        UIAccessibility.post(notification: .layoutChanged,
                             argument: self.creditCardValidationErrorLabel)
    }

    self.viewModel.outputs.paymentDetailsBecomeFirstResponder
      .observeForUI()
      .observeValues { [weak self] in
        self?.creditCardTextField.becomeFirstResponder()
    }

    self.viewModel.outputs.saveButtonIsEnabled
      .observeForUI()
      .observeValues { [weak self] (isEnabled) in
        self?.saveButtonView.setIsEnabled(isEnabled: isEnabled)
    }

    self.viewModel.outputs.setStripePublishableKey
      .observeForUI()
      .observeValues {
        STPPaymentConfiguration.shared().publishableKey = $0
    }

    self.viewModel.outputs.dismissKeyboard
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismissKeyboard()
    }

    self.viewModel.outputs.paymentDetails
      .observeForUI()
      .observeValues { [weak self] paymentDetails in
        self?.createStripeToken(paymentDetails: paymentDetails)
    }

    self.viewModel.outputs.activityIndicatorShouldShow
      .observeForUI()
      .observeValues { shouldShow in
        if shouldShow {
          self.saveButtonView.startAnimating()
        } else {
          self.saveButtonView.stopAnimating()
        }
    }

    self.viewModel.outputs.addNewCardSuccess
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.delegate?.presentAddCardSuccessfulBanner(message)
        self?.navigationController?.dismiss(animated: true, completion: nil)
    }

    self.viewModel.outputs.addNewCardFailure
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
        self?.messageBannerViewController?.showBanner(with: .error, message: errorMessage)
    }

    self.viewModel.outputs.zipcodeTextFieldBecomeFirstResponder
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        self?.zipcodeFormView.textField.becomeFirstResponder()
    }
  }

  @objc fileprivate func cancelButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc fileprivate func saveButtonTapped() {
    self.viewModel.inputs.saveButtonTapped()
  }

  @objc func cardholderNameTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.cardholderNameChanged(textField.text)
  }

  @objc func cardholderNameTextFieldReturn(_ textField: UITextField
    ) {
    self.viewModel.inputs.cardholderNameTextFieldReturn()
  }

  // MARK: - Zipcode UITextField Delegate
  @objc internal func zipcodeTextFieldDoneEditing() {
    self.viewModel.inputs.zipcodeTextFieldDidEndEditing()
  }

  @objc internal func zipcodeTextFieldChanged(textField: UITextField) {
    self.viewModel.inputs.zipcodeChanged(zipcode: textField.text)
  }

  // MARK: - STPPaymentCardTextFieldDelegate
  internal func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
    self.viewModel.inputs.paymentInfo(isValid: textField.isValid)

    guard let cardnumber = textField.cardNumber else {
      return
    }

    let cardBrand = STPCardValidator.brand(forNumber: cardnumber)
    let isValid = self.cardBrandIsSupported(brand: cardBrand,
                                            unsupportedCardBrands: self.unsupportedCardBrands)

    self.viewModel.inputs.cardBrand(isValid: isValid)

    self.viewModel.inputs.creditCardChanged(cardDetails: (cardnumber, textField.expirationMonth,
                                                          textField.expirationYear, textField.cvc))

  }

  internal func paymentCardTextFieldDidEndEditing(_ textField: STPPaymentCardTextField) {
    self.viewModel.inputs.paymentCardTextFieldDidEndEditing()
  }

  // MARK: - Private Functions
  private func createStripeToken(paymentDetails: PaymentDetails) {
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

  private func cardBrandIsSupported(brand: STPCardBrand, unsupportedCardBrands: [STPCardBrand]) -> Bool {
    return !self.unsupportedCardBrands.contains(brand)
  }

  private func dismissKeyboard() {
    self.cardholderNameTextField.resignFirstResponder()
    self.creditCardTextField.resignFirstResponder()
    self.zipcodeFormView.textField.resignFirstResponder()
  }
}
