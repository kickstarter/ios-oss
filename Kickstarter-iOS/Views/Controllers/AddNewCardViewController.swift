import KsApi
import Library
import Prelude
import ReactiveSwift
import Stripe
import UIKit

internal final class AddNewCardViewController: UIViewController, STPPaymentCardTextFieldDelegate {

  private weak var saveButtonView: LoadingBarButtonItemView!
  @IBOutlet private weak var cardholderNameLabel: UILabel!
  @IBOutlet private weak var cardholderNameTextField: UITextField!
  @IBOutlet private weak var paymentTextField: STPPaymentCardTextField!

  fileprivate let viewModel: AddNewCardViewModelType = AddNewCardViewModel()

  internal static func instantiate() -> AddNewCardViewController {
    return Storyboard.Settings.instantiate(AddNewCardViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

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

    self.viewModel.outputs.saveButtonIsEnabled
      .observeForUI()
      .observeValues { [weak self] (isEnabled) in
        self?.saveButtonView.setIsEnabled(isEnabled: isEnabled)
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
  }

  @objc fileprivate func cancelButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc fileprivate func saveButtonTapped() {
    self.viewModel.inputs.saveButtonTapped()
  }

  @IBAction func cardholderNameTextDidChange(_ sender: UITextField) {
    guard let text = sender.text else {
      return
    }

    self.viewModel.inputs.cardholderNameFieldTextChanged(text: text)
  }

  @IBAction func cardholderNameFieldDidEndEditing(_ sender: UITextField) {
    guard let cardholderName = sender.text else {
      return
    }

    self.viewModel.inputs.cardholderNameFieldTextChanged(text: cardholderName)
  }

  @IBAction func cardholderNameDidReturn(_ sender: UITextField) {
    guard let cardholderName = sender.text else {
      return
    }

    self.viewModel.inputs.cardholderNameFieldDidReturn(cardholderName: cardholderName)
  }

  @IBAction func paymentCardTextDidChange(_ sender: STPPaymentCardTextField) {
    guard let cardnumber = sender.cardNumber, let cvc = sender.cvc else {
      return
    }

    self.viewModel.inputs.paymentCardFieldTextChanged(cardNumber: cardnumber,
                                                      expMonth: Int(sender.expirationMonth),
                                                      expYear: Int(sender.expirationYear),
                                                      cvc: cvc)
  }

  @IBAction func paymentCardFieldDidEndEditing(_ sender: STPPaymentCardTextField) {
    guard let cardnumber = sender.cardNumber, let cvc = sender.cvc else {
      return
    }

    self.viewModel.inputs.paymentCardFieldTextChanged(cardNumber: cardnumber,
                                                      expMonth: Int(sender.expirationMonth),
                                                      expYear: Int(sender.expirationYear),
                                                      cvc: cvc)
  }

  @IBAction func paymentCardDidReturn(_ sender: STPPaymentCardTextField) {
    guard let cardnumber = sender.cardNumber, let cvc = sender.cvc else {
      return
    }

    self.viewModel.inputs.paymentCardFieldDidReturn(cardNumber: cardnumber,
                                                    expMonth: Int(sender.expirationMonth),
                                                    expYear: Int(sender.expirationYear),
                                                    cvc: cvc)
  }

  func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
    self.viewModel.inputs.paymentInfo(valid: textField.isValid)
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
      guard let token = token, let error = error else {
        return
      }
      self.viewModel.inputs.stripeCreatedToken(stripeToken: token.tokenId, error: error)
    }
  }
}
