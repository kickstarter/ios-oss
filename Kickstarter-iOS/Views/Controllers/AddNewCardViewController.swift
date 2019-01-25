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

  private let unsupportedCardBrands: [STPCardBrand] = [.unionPay, .unknown]

  private var saveButtonView: LoadingBarButtonItemView!
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

    _ = self.creditCardTextField
      |> \.cursorColor .~ .ksr_green_700
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.placeholderColor .~ .ksr_text_dark_grey_400

    _ = self.creditCardValidationErrorLabel
      |> settingsDescriptionLabelStyle
      |> \.textColor .~ .ksr_red_400
      |> \.text %~ { _ in Strings.Unsupported_card_type() }
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
        self?.creditCardTextField.resignFirstResponder()
    }

    self.viewModel.outputs.paymentDetails
      .observeForUI()
      .observeValues { [weak self] cardholderName, cardNumber, expMonth, expYear, cvc in
        self?.createStripeToken(cardholderName: cardholderName,
                                cardNumber: cardNumber,
                                expirationMonth: expMonth,
                                expirationYear: expYear,
                                cvc: cvc)
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

  // MARK: - Private Functions
  private func createStripeToken(cardholderName: String, cardNumber: String, expirationMonth: Month,
                                 expirationYear: Year, cvc: String) {
    let cardParams = STPCardParams()
    cardParams.name = cardholderName
    cardParams.number = cardNumber
    cardParams.expMonth = expirationMonth
    cardParams.expYear = expirationYear
    cardParams.cvc = cvc

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
}
