import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import Stripe

public protocol AddNewCardViewModelInputs {
  func cardholderNameFieldTextChanged(text: String)
  func cardholderNameFieldDidReturn(cardholderName: String)
  func paymentCardFieldTextChanged(cardNumber: String, expMonth: Int, expYear: Int, cvc: String)
  func paymentCardFieldDidReturn(cardNumber: String, expMonth: Int, expYear: Int, cvc: String)
  func paymentInfo(valid: Bool)
  func saveButtonTapped()
  func stripeCreatedToken(stripeToken: String?, error: Error)
}

public protocol AddNewCardViewModelOutputs {
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
  var paymentDetails: Signal<(String, String, Int, Int, String), NoError> { get }
}

public protocol AddNewCardViewModelType {
  var inputs: AddNewCardViewModelInputs { get }
  var outputs: AddNewCardViewModelOutputs { get }
}

public final class AddNewCardViewModel: AddNewCardViewModelType, AddNewCardViewModelInputs,
AddNewCardViewModelOutputs {

  public init() {
    let cardholderName = self.cardholderNameProperty.signal // Add to STPCardParams()
    let paymentDetails = self.paymentCardProperty.signal.skipNil()

    self.saveButtonIsEnabled = Signal.combineLatest(
      cardholderName.map { !$0.isEmpty },
      self.paymentInfoIsValidProperty.signal
      ).map { cardholderName, validation in cardholderName && validation }

    self.paymentDetails = Signal.combineLatest(cardholderName, paymentDetails)
      .map { cardholderName, paymentInfo in (cardholderName, paymentInfo.0, paymentInfo.1, paymentInfo.2, paymentInfo.3) }
      .takeWhen(self.saveButtonTappedProperty.signal)

    let addNewCardEvent = "AddNewCard Event"
  }

  private let cardholderNameDoneEditingProperty = MutableProperty(())
  public func cardholderNameFieldDidReturn(cardholderName: String) {
    self.cardholderNameProperty.value = cardholderName
    self.cardholderNameDoneEditingProperty.value = ()
  }

  private let cardholderNameProperty = MutableProperty<String>("")
  public func cardholderNameFieldTextChanged(text: String) {
    self.cardholderNameProperty.value = text
  }

  private let paymentCardDoneEditingProperty = MutableProperty(())
  public func paymentCardFieldDidReturn(cardNumber: String, expMonth: Int, expYear: Int, cvc: String) {
    self.paymentCardProperty.value = (cardNumber, expMonth, expYear, cvc)
    self.paymentCardDoneEditingProperty.value = ()
  }

  private let paymentCardProperty = MutableProperty<(String, Int, Int, String)?>(nil)
  public func paymentCardFieldTextChanged(cardNumber: String, expMonth: Int, expYear: Int, cvc: String) {
    self.paymentCardProperty.value = (cardNumber, expMonth, expYear, cvc)
  }

  private let paymentInfoIsValidProperty = MutableProperty(false)
  public func paymentInfo(valid: Bool) {
    self.paymentInfoIsValidProperty.value = valid
  }

  private let saveButtonTappedProperty = MutableProperty(())
  public func saveButtonTapped() {
    self.saveButtonTappedProperty.value = ()
  }

  private let stripeTokenAndErrorProperty = MutableProperty((String?.none, Error?.none))
  public func stripeCreatedToken(stripeToken: String?, error: Error) {
    self.stripeTokenAndErrorProperty.value = (stripeToken, error)
  }

  public let saveButtonIsEnabled: Signal<Bool, NoError>
  public let paymentDetails: Signal<(String, String, Int, Int, String), NoError>

  public var inputs: AddNewCardViewModelInputs { return self }
  public var outputs: AddNewCardViewModelOutputs { return self }
}
