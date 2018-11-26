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
  func stripeCreatedToken(stripeToken: STPToken, error: Error)
}

public protocol AddNewCardViewModelOutputs {
  var activityIndicatorShouldShow: Signal<Bool, NoError> { get }
  var addNewCardFailure: Signal<String, NoError> { get }
  var addNewCardSuccess: Signal<Void, NoError> { get }
  var paymentDetails: Signal<(String, String, Int, Int, String), NoError> { get }
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
}

public protocol AddNewCardViewModelType {
  var inputs: AddNewCardViewModelInputs { get }
  var outputs: AddNewCardViewModelOutputs { get }
}

public final class AddNewCardViewModel: AddNewCardViewModelType, AddNewCardViewModelInputs,
AddNewCardViewModelOutputs {

  public init() {
    let cardholderName = self.cardholderNameProperty.signal
    let paymentDetails = self.paymentCardProperty.signal.skipNil()

    self.saveButtonIsEnabled = Signal.combineLatest(
      cardholderName.map { !$0.isEmpty },
      self.paymentInfoIsValidProperty.signal
      ).map { cardholderName, validation in cardholderName && validation }

    let autoSaveSignal = self.saveButtonIsEnabled
      .takeWhen(self.paymentCardDoneEditingProperty.signal)
      .filter { isTrue($0) }
      .ignoreValues()

    let triggerSaveAction = Signal.merge(
      autoSaveSignal,
      self.saveButtonTappedProperty.signal
    )

    let paymentInput = Signal.combineLatest(cardholderName, paymentDetails)
      .map { cardholderName, paymentInfo in
        (cardholderName, paymentInfo.0, paymentInfo.1, paymentInfo.2, paymentInfo.3) }

    self.paymentDetails = paymentInput
      .takeWhen(self.saveButtonTappedProperty.signal)

    let stripeTokenId = self.stripeTokenAndErrorProperty.signal.map { $0?.0.tokenId }.skipNil()
    let stripeCardId = self.stripeTokenAndErrorProperty.signal.map { $0?.0.stripeID }.skipNil()

    let addNewCardEvent = Signal.combineLatest(stripeTokenId, stripeCardId)
      .takeWhen(triggerSaveAction)
      .map { CreatePaymentSourceInput(paymentType: PaymentType.creditCard, stripeToken: $0.0, stripeCardId: $0.1) }
      .flatMap {
        AppEnvironment.current.apiService.addNewCreditCard(input: $0)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.addNewCardSuccess = addNewCardEvent.values().ignoreValues()
    self.addNewCardFailure = addNewCardEvent.errors().map { $0.localizedDescription }

    self.activityIndicatorShouldShow = Signal.merge(
      triggerSaveAction.signal.mapConst(true),
      self.addNewCardSuccess.mapConst(false),
      self.addNewCardFailure.mapConst(false)
    )
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

  private let stripeTokenAndErrorProperty = MutableProperty<(STPToken, Error)?>(nil)
  public func stripeCreatedToken(stripeToken: STPToken, error: Error) {
    self.stripeTokenAndErrorProperty.value = (stripeToken, error)
  }

  public let activityIndicatorShouldShow: Signal<Bool, NoError>
  public let addNewCardFailure: Signal<String, NoError>
  public let addNewCardSuccess: Signal<Void, NoError>
  public let paymentDetails: Signal<(String, String, Int, Int, String), NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>

  public var inputs: AddNewCardViewModelInputs { return self }
  public var outputs: AddNewCardViewModelOutputs { return self }
}
