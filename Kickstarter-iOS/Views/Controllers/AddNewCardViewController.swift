import KsApi
import Library
import Prelude
import ReactiveSwift
import Stripe
import UIKit

internal final class AddNewCardViewController: UIViewController, STPPaymentCardTextFieldDelegate {
  @IBOutlet private weak var cardholderNameLabel: UILabel!
  @IBOutlet private weak var cardholderNameTextField: UITextField!
  @IBOutlet private weak var paymentTextField: STPPaymentCardTextField!

  private var saveButtonView: LoadingBarButtonItemView!
  private var messageBannerView: MessageBannerViewController!

  fileprivate let viewModel: AddNewCardViewModelType = AddNewCardViewModel()

  internal static func instantiate() -> AddNewCardViewController {
    return Storyboard.Settings.instantiate(AddNewCardViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let messageViewController = self.children.first as? MessageBannerViewController else {
      fatalError("Missing message View Controller")

    }
    self.messageBannerView = messageViewController

    self.cardholderNameTextField.addTarget(self,
                                           action: #selector(cardholderNameTextFieldReturn),
                                           for: .editingDidEndOnExit)

    self.cardholderNameTextField.addTarget(self,
                                           action: #selector(cardholderNameTextFieldChanged(_:)),
                                           for: [.editingDidEndOnExit, .editingChanged])

    self.paymentTextField.addTarget(self, action: #selector(paymentCardTextFieldReturn), for: [.editingDidEndOnExit])

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

    self.paymentTextField.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle

    _ = self.cardholderNameLabel
      |> \.textColor .~ .ksr_text_dark_grey_900
      |> \.font .~ .ksr_body()
      |> \.text %~ { _ in Strings.Cardholder_name() }

    _ = self.cardholderNameTextField
      |> formFieldStyle
      |> \.autocapitalizationType .~ .words
      |> \.returnKeyType .~ .next
      |> \.textAlignment .~ .right
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.attributedPlaceholder .~ NSAttributedString(
          string: Strings.Name(),
          attributes: [NSAttributedString.Key.foregroundColor: UIColor.ksr_text_dark_grey_400])

    _ = self.paymentTextField
      |> \.borderColor .~ nil
      |> \.font .~ .ksr_body()
      |> \.cursorColor .~ .ksr_green_700
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.placeholderColor .~ .ksr_text_dark_grey_400
  }

  override func bindViewModel() {
    super.bindViewModel()

     self.cardholderNameTextField.rac.becomeFirstResponder =
      self.viewModel.outputs.cardholderNameBecomeFirstResponder

    self.viewModel.outputs.paymentDetailsBecomeFirstResponder
      .observeForUI()
      .observeValues { [weak self] in
        self?.paymentTextField.becomeFirstResponder()
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
        self?.paymentTextField.resignFirstResponder()
    }

    self.viewModel.outputs.paymentDetails
      .observeForUI()
      .observeValues { [weak self] cardholderName, cardNumber, expMonth, expYear, cvc in
        self?.stripeToken(cardholderName: cardholderName,
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
      .observeValues { [weak self] in
        self?.dismiss()
    }

    self.viewModel.outputs.addNewCardFailure
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
        self?.messageBannerView.showBanner(with: .error, message: errorMessage)
    }
  }

  @objc fileprivate func cancelButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc fileprivate func saveButtonTapped() {
    self.viewModel.inputs.saveButtonTapped()
  }

  @objc func cardholderNameTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.cardholderNameChanged(textField.text ?? "")
  }

  @objc func cardholderNameTextFieldReturn(_ textField: UITextField
    ) {
    self.viewModel.inputs.cardholderNameTextFieldReturn()
  }

  func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {

    guard let cardnumber = textField.cardNumber, let cvc = textField.cvc else {
      return
    }

    self.viewModel.inputs.paymentCardChanged(cardNumber: cardnumber,
                                             expMonth: Int(textField.expirationMonth),
                                             expYear: Int(textField.expirationYear),
                                             cvc: cvc)

    self.viewModel.inputs.paymentInfo(valid: textField.isValid)
  }

  @objc func paymentCardTextFieldReturn(_ textField: STPPaymentCardTextField) {
    self.viewModel.inputs.paymentCardTextFieldReturn()
  }

  func stripeToken(cardholderName: String,
                   cardNumber: String,
                   expirationMonth: Int,
                   expirationYear: Int,
                   cvc: String) {
    let cardParams = STPCardParams()
    cardParams.name = cardholderName
    cardParams.number = cardNumber
    cardParams.expMonth = UInt(expirationMonth)
    cardParams.expYear = UInt(expirationYear)
    cardParams.cvc = cvc

    STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
      if let token = token {
         self.viewModel.inputs.stripeCreated(token)
      } else {
        self.viewModel.inputs.stripeError(error)
      }
    }
  }

  func dismiss() {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}
