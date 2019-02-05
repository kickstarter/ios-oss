import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import Stripe

public typealias Month = UInt
public typealias Year = UInt
public typealias CardDetails = (cardNumber: String, expMonth: Month?, expYear: Year?, cvc: String?)

public protocol AddNewCardViewModelInputs {
  func cardBrand(isValid: Bool)
  func cardholderNameChanged(_ cardholderName: String?)
  func cardholderNameTextFieldReturn()
  func creditCardChanged(cardDetails: CardDetails)
  func paymentInfo(isValid: Bool)
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
  var creditCardValidationErrorContainerHidden: Signal<Bool, NoError> { get }
  var cardholderNameBecomeFirstResponder: Signal<Void, NoError> { get }
  var dismissKeyboard: Signal<Void, NoError> { get }
  var paymentDetails: Signal<(String, String, Month, Year, String), NoError> { get }
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
    let creditCardDetails = self.creditCardChangedProperty.signal
      .skipNil()
      .filterMap { cardDetails -> (String, UInt, UInt, String)? in
        guard let expMonth = cardDetails.expMonth, let expYear = cardDetails.expYear,
          let cvc = cardDetails.cvc else {
          return nil
        }

        return (cardDetails.cardNumber, expMonth, expYear, cvc)
      }

    let cardNumber = self.creditCardChangedProperty.signal
      .skipNil()
      .map { $0.cardNumber }

    self.cardholderNameBecomeFirstResponder = self.viewDidLoadProperty.signal
    self.paymentDetailsBecomeFirstResponder = self.cardholderNameTextFieldReturnProperty.signal

    let cardBrandValidAndCardNumberValid = Signal
      .combineLatest(self.cardBrandIsValidProperty.signal,
                     cardNumber)
      .map { (brandValid, cardNumber) -> Bool in
        // If card number is insufficiently long, always return "valid card brand" behaviour
        return brandValid || cardNumber.count < 2
    }

    self.creditCardValidationErrorContainerHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      cardBrandValidAndCardNumberValid
      )

    self.saveButtonIsEnabled = Signal.combineLatest(
      cardholderName.map { !$0.isEmpty },
      self.paymentInfoIsValidProperty.signal,
      self.cardBrandIsValidProperty.signal
      ).map { cardholderNameFieldNotEmpty, creditCardIsValid, cardBrandIsValid in
        cardholderNameFieldNotEmpty && creditCardIsValid && cardBrandIsValid }
      .skipRepeats()

    let paymentInput = Signal.combineLatest(cardholderName, creditCardDetails)
      .map { cardholderName, creditCardDetails in
        (cardholderName, creditCardDetails.0, creditCardDetails.1, creditCardDetails.2, creditCardDetails.3) }

    self.paymentDetails = paymentInput.takeWhen(self.saveButtonTappedProperty.signal)

    self.dismissKeyboard = self.saveButtonTappedProperty.signal

    self.setStripePublishableKey = self.viewDidLoadProperty.signal
      .map { _ in AppEnvironment.current.config?.stripePublishableKey }
      .skipNil()

    let addNewCardEvent = self.stripeTokenProperty.signal.skipNil()
      .map { CreatePaymentSourceInput(paymentType: PaymentType.creditCard,
                                      stripeToken: $0.0, stripeCardId: $0.1) }
      .switchMap {
        AppEnvironment.current.apiService.addNewCreditCard(input: $0)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { (envelope: CreatePaymentSourceEnvelope) in envelope.createPaymentSource }
          .materialize()
       }

    let stripeInvalidToken = self.stripeErrorProperty.signal.map {
      $0?.localizedDescription
    }.skipNil()
    let graphError = addNewCardEvent.errors().map {
      $0.localizedDescription
    }
    let addNewCardError = addNewCardEvent.map { $0.value?.errorMessage }.skipNil()

    let errorMessage = Signal.merge (
      stripeInvalidToken,
      graphError,
      addNewCardError
    )

    self.addNewCardFailure = errorMessage.map { $0 }

    let cardAddedSuccessfully = addNewCardEvent
      .filter { $0.value?.isSuccessful == true }
      .mapConst(true)

    self.addNewCardSuccess = cardAddedSuccessfully
      .map { _ in Strings.Got_it_your_changes_have_been_saved() }

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
  public func cardBrand(isValid: Bool) {
    self.cardBrandIsValidProperty.value = isValid
  }

  private let cardholderNameChangedProperty = MutableProperty<String?>(nil)
  public func cardholderNameChanged(_ cardholderName: String?) {
    self.cardholderNameChangedProperty.value = cardholderName
  }

  private let cardholderNameTextFieldReturnProperty = MutableProperty(())
  public func cardholderNameTextFieldReturn() {
    self.cardholderNameTextFieldReturnProperty.value = ()
  }

  private let creditCardChangedProperty = MutableProperty<CardDetails?>(nil)
  public func creditCardChanged(cardDetails: CardDetails) {
    self.creditCardChangedProperty.value = cardDetails
  }

  private let paymentInfoIsValidProperty = MutableProperty(false)
  public func paymentInfo(isValid: Bool) {
    self.paymentInfoIsValidProperty.value = isValid
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
  public let creditCardValidationErrorContainerHidden: Signal<Bool, NoError>
  public let cardholderNameBecomeFirstResponder: Signal<Void, NoError>
  public let dismissKeyboard: Signal<Void, NoError>
  public let paymentDetails: Signal<(String, String, Month, Year, String), NoError>
  public let paymentDetailsBecomeFirstResponder: Signal<Void, NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>
  public let setStripePublishableKey: Signal<String, NoError>

  public var inputs: AddNewCardViewModelInputs { return self }
  public var outputs: AddNewCardViewModelOutputs { return self }
}
