import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import Stripe

public protocol AddNewCardViewModelInputs {
  func cardBrandIsValid(_ valid: Bool)
  func cardholderNameChanged(_ cardholderName: String?)
  func cardholderNameTextFieldReturn()
  func creditCardChanged(cardNumber: String, expMonth: UInt?, expYear: UInt?, cvc: String?)
  func paymentInfo(valid: Bool)
  func saveButtonTapped()
  func stripeCreated(_ token: String?, stripeID: String?)
  func stripeError(_ error: Error?)
  func viewDidLoad()
  func viewWillAppear()
}

public protocol AddNewCardViewModelOutputs {
  var activityIndicatorShouldShow: Signal<Bool, NoError> { get }
  var addNewCardFailure: Signal<String, NoError> { get }
  var addNewCardSuccess: Signal<String, NoError> { get }
  var cardBrandUnsupportedErrorMessageHidden: Signal<Bool, NoError> { get }
  var cardholderNameBecomeFirstResponder: Signal<Void, NoError> { get }
  var dismissKeyboard: Signal<Void, NoError> { get }
  var paymentDetails: Signal<(String, String, UInt, UInt, String), NoError> { get }
  var paymentDetailsBecomeFirstResponder: Signal<Void, NoError> { get }
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }
  var setStripePublishableKey: Signal<String, NoError> { get }
}

public protocol AddNewCardViewModelType {
  var inputs: AddNewCardViewModelInputs { get }
  var outputs: AddNewCardViewModelOutputs { get }
}

public final class AddNewCardViewModel: AddNewCardViewModelType, AddNewCardViewModelInputs,
AddNewCardViewModelOutputs {

  public init() {
    let cardholderName = self.cardholderNameChangedProperty.signal.skipNil()
    let creditCardDetails = self.creditCardChangedProperty
      .signal
      .skipNil()
      .filterMap { args -> (String, UInt, UInt, String)? in
        let (cardNumberArg, expMonthArg, expYearArg, cvcArg) = args

        guard let expMonth = expMonthArg,
              let expYear = expYearArg,
              let cvc = cvcArg else {
          return nil
        }

        return (cardNumberArg, expMonth, expYear, cvc)
      }

    let cardNumber = self.creditCardChangedProperty
      .signal
      .skipNil()
      .map { $0.0 }

    self.cardholderNameBecomeFirstResponder = self.viewDidLoadProperty.signal
    self.paymentDetailsBecomeFirstResponder = self.cardholderNameTextFieldReturnProperty.signal

    let cardBrandValidAndCardNumberValid = Signal
      .combineLatest(self.cardBrandIsValidProperty.signal,
                     cardNumber)
      .map { (brandValid, cardNumber) -> Bool in
        // Hide the message if the brand is "unknown" due to the cardNumber being empty,
        // or only one digit being entered
        if cardNumber.count < 2 {
          return true
        }

        return brandValid
    }

    self.cardBrandUnsupportedErrorMessageHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      cardBrandValidAndCardNumberValid
      )

    self.saveButtonIsEnabled = Signal.combineLatest(
      cardholderName.map { !$0.isEmpty }.logEvents(identifier: "CARDHOLDER NAME CHANGED"),
      self.paymentInfoIsValidProperty.signal.logEvents(identifier: "PAYMENT INFO VALID"),
      self.cardBrandIsValidProperty.signal.logEvents(identifier: "CREDIT CARD VALID")
      ).map { cardholderNameFieldNotEmpty, creditCardIsValid, cardBrandIsValid in
        cardholderNameFieldNotEmpty && creditCardIsValid && cardBrandIsValid }
      .skipRepeats()

    let paymentInput = Signal.combineLatest(cardholderName, creditCardDetails)
      .map { cardholderName, creditCardDetails in
        (cardholderName, creditCardDetails.0, creditCardDetails.1, creditCardDetails.2, creditCardDetails.3) }

    self.paymentDetails = paymentInput
      .takeWhen(self.saveButtonTappedProperty.signal)

    self.dismissKeyboard = self.saveButtonTappedProperty.signal

    self.setStripePublishableKey = self.viewDidLoadProperty.signal
      .map { _ in AppEnvironment.current.config?.stripePublishableKey }
      .skipNil()

    let addNewCardEvent = self.stripeTokenProperty.signal.skipNil()
      .map { CreatePaymentSourceInput(paymentType: PaymentType.creditCard,
                                      stripeToken: $0.0, stripeCardId: $0.1) }
      .flatMap {
        AppEnvironment.current.apiService.addNewCreditCard(input: $0)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
       }

    self.addNewCardSuccess = addNewCardEvent.values().ignoreValues()
      .map { _ in Strings.Got_it_your_changes_have_been_saved() }

    let stripeInvalidToken = self.stripeErrorProperty.signal.map {
      $0?.localizedDescription
    }.skipNil()
    let graphError = addNewCardEvent.errors().map {
      $0.localizedDescription
    }

    self.addNewCardFailure = Signal.merge (
      stripeInvalidToken,
      graphError
    )

    self.activityIndicatorShouldShow = Signal.merge(
      self.saveButtonTappedProperty.signal.mapConst(true),
      self.addNewCardSuccess.mapConst(false),
      self.addNewCardFailure.mapConst(false)
    )

    // Koala
    self.viewWillAppearProperty.signal
      .observeValues {
        AppEnvironment.current.koala.trackViewedAddNewCard()
    }

    self.addNewCardSuccess
      .observeValues { _ in
        AppEnvironment.current.koala.trackSavedPaymentMethod()
    }

    self.addNewCardFailure
      .observeValues { _ in
        AppEnvironment.current.koala.trackFailedPaymentMethodCreation()
    }
  }

  private let cardBrandIsValidProperty = MutableProperty<Bool>(true)
  public func cardBrandIsValid(_ valid: Bool) {
    self.cardBrandIsValidProperty.value = valid
  }

  private let cardholderNameChangedProperty = MutableProperty<String?>(nil)
  public func cardholderNameChanged(_ cardholderName: String?) {
    self.cardholderNameChangedProperty.value = cardholderName
  }

  private let cardholderNameTextFieldReturnProperty = MutableProperty(())
  public func cardholderNameTextFieldReturn() {
    self.cardholderNameTextFieldReturnProperty.value = ()
  }

  private let creditCardChangedProperty = MutableProperty<(String, UInt?, UInt?, String?)?>(nil)
  public func creditCardChanged(cardNumber: String, expMonth: UInt?, expYear: UInt?, cvc: String?) {
    self.creditCardChangedProperty.value = (cardNumber, expMonth, expYear, cvc)
  }

  private let paymentInfoIsValidProperty = MutableProperty(false)
  public func paymentInfo(valid: Bool) {
    self.paymentInfoIsValidProperty.value = valid
  }

  private let saveButtonTappedProperty = MutableProperty(())
  public func saveButtonTapped() {
    self.saveButtonTappedProperty.value = ()
  }

  private let stripeErrorProperty = MutableProperty(Error?.none)
  public func stripeError(_ error: Error?) {
    self.stripeErrorProperty.value = error
  }

  private let stripeTokenProperty = MutableProperty<(String, String)?>(nil)
  public func stripeCreated(_ token: String?, stripeID: String?) {
    if let token = token, let stripeID = stripeID {
      self.stripeTokenProperty.value = (token, stripeID )
    }
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let activityIndicatorShouldShow: Signal<Bool, NoError>
  public let addNewCardFailure: Signal<String, NoError>
  public let addNewCardSuccess: Signal<String, NoError>
  public let cardBrandUnsupportedErrorMessageHidden: Signal<Bool, NoError>
  public let cardholderNameBecomeFirstResponder: Signal<Void, NoError>
  public let dismissKeyboard: Signal<Void, NoError>
  public let paymentDetails: Signal<(String, String, UInt, UInt, String), NoError>
  public let paymentDetailsBecomeFirstResponder: Signal<Void, NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>
  public let setStripePublishableKey: Signal<String, NoError>

  public var inputs: AddNewCardViewModelInputs { return self }
  public var outputs: AddNewCardViewModelOutputs { return self }
}
