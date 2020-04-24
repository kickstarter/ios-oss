import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public typealias Month = UInt
public typealias Year = UInt
public typealias CardDetails = (
  cardNumber: String, expMonth: Month?, expYear: Year?, cvc: String?,
  cardBrand: CreditCardType?
)
public typealias PaymentDetails = (
  cardholderName: String, cardNumber: String, expMonth: Month, expYear: Year,
  cvc: String, postalCode: String
)

public protocol AddNewCardViewModelInputs {
  func cardholderNameChanged(_ cardholderName: String?)
  func cardholderNameTextFieldReturn()
  func creditCardChanged(cardDetails: CardDetails)
  func configure(with intent: AddNewCardIntent, project: Project?)
  func paymentInfo(isValid: Bool)
  func rememberThisCardToggleChanged(to value: Bool)
  func saveButtonTapped()
  func stripeCreated(_ token: String?, stripeID: String?)
  func stripeError(_ error: Error?)
  func viewDidLoad()
  func viewWillAppear()
  func zipcodeChanged(zipcode: String?)
  func zipcodeTextFieldDidEndEditing()
}

public protocol AddNewCardViewModelOutputs {
  var activityIndicatorShouldShow: Signal<Bool, Never> { get }
  var addNewCardFailure: Signal<String, Never> { get }
  var creditCardValidationErrorContainerHidden: Signal<Bool, Never> { get }
  var cardholderNameBecomeFirstResponder: Signal<Void, Never> { get }
  var dismissKeyboard: Signal<Void, Never> { get }
  var newCardAddedWithMessage: Signal<(GraphUserCreditCard.CreditCard, String), Never> { get }
  var paymentDetails: Signal<PaymentDetails, Never> { get }
  var paymentDetailsBecomeFirstResponder: Signal<Void, Never> { get }
  var rememberThisCardToggleViewControllerContainerIsHidden: Signal<Bool, Never> { get }
  var rememberThisCardToggleViewControllerIsOn: Signal<Bool, Never> { get }
  var saveButtonIsEnabled: Signal<Bool, Never> { get }
  var setStripePublishableKey: Signal<String, Never> { get }
  var unsupportedCardBrandErrorText: Signal<String, Never> { get }
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

    let cardBrand = self.creditCardChangedProperty.signal
      .skipNil()
      .map { $0.cardBrand }.skipNil()

    let cardNumber = self.creditCardChangedProperty.signal
      .skipNil()
      .map { $0.cardNumber }

    self.cardholderNameBecomeFirstResponder = self.viewDidLoadProperty.signal
    self.paymentDetailsBecomeFirstResponder = self.cardholderNameTextFieldReturnProperty.signal

    let zipcode = self.zipcodeProperty.signal.skipNil()
    let zipcodeIsValid: Signal<Bool, Never> = zipcode.map { !$0.isEmpty }

    let project = self.addNewCardIntentAndProjectProperty.signal.skipNil()
      .map(second)

    let cardBrandIsValid = Signal.combineLatest(
      project,
      cardBrand
    ).map(cardBrandIsSupported(project:cardBrand:))

    let cardBrandValidAndCardNumberValid = Signal
      .combineLatest(
        cardBrandIsValid,
        cardNumber
      )
      .map { (brandValid, cardNumber) -> Bool in
        brandValid || cardNumber.count < 2
      }

    let invalidCardBrand = cardBrandIsValid.filter(isFalse)

    let intent = Signal.combineLatest(
      self.addNewCardIntentAndProjectProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .map(first)

    self.unsupportedCardBrandErrorText = Signal.combineLatest(invalidCardBrand, project, intent)
      .map { _, project, intent in
        intent == .pledge ?
          Strings.You_cant_use_this_credit_card_to_back_a_project_from_project_country(
            project_country: project?.location.displayableName ?? ""
          ) : Strings.Unsupported_card_type()
      }

    self.creditCardValidationErrorContainerHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      cardBrandValidAndCardNumberValid
    )

    self.saveButtonIsEnabled = Signal.combineLatest(
      cardholderName.map { !$0.isEmpty },
      self.paymentInfoIsValidProperty.signal,
      cardBrandIsValid,
      zipcodeIsValid
    ).map { cardholderNameFieldNotEmpty, creditCardIsValid, cardBrandIsValid, zipcodeIsValid in
      cardholderNameFieldNotEmpty && creditCardIsValid && cardBrandIsValid && zipcodeIsValid
    }
    .skipRepeats()

    let paymentInput = Signal.combineLatest(cardholderName, creditCardDetails, zipcode)
      .map { cardholderName, creditCardDetails, zipcode -> PaymentDetails in
        (
          cardholderName, creditCardDetails.0, creditCardDetails.1, creditCardDetails.2, creditCardDetails.3,
          zipcode
        )
      }

    let saveButtonTappedOrZipCodeEditingEnded = Signal.merge(
      self.saveButtonTappedProperty.signal,
      self.zipcodeTextFieldDidEndEditingProperty.signal
    )

    let submitPaymentDetails = self.saveButtonIsEnabled
      .takeWhen(saveButtonTappedOrZipCodeEditingEnded)
      .filter(isTrue)

    self.paymentDetails = paymentInput.takeWhen(submitPaymentDetails)

    self.dismissKeyboard = submitPaymentDetails.ignoreValues()

    self.setStripePublishableKey = self.viewDidLoadProperty.signal
      .map { _ in AppEnvironment.current.environmentType.stripePublishableKey }

    self.rememberThisCardToggleViewControllerIsOn = intent.map { $0 == .settings }

    let rememberThisCard = Signal.merge(
      self.rememberThisCardToggleViewControllerIsOn,
      self.rememberThisCardToggleChangedToValue.signal
    )

    let addNewCardEvent = Signal.combineLatest(
      self.stripeTokenProperty.signal.skipNil(),
      rememberThisCard
    )
    .map(unpack)
    .map(CreatePaymentSourceInput.input(fromToken:stripeCardId:reusable:))
    .switchMap {
      AppEnvironment.current.apiService.addNewCreditCard(input: $0)
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .map { (envelope: CreatePaymentSourceEnvelope) in envelope.createPaymentSource }
        .materialize()
    }

    self.newCardAddedWithMessage = addNewCardEvent.values()
      .map { $0.paymentSource }
      .map { card in (card, Strings.Got_it_your_changes_have_been_saved()) }

    let stripeInvalidToken = self.stripeErrorProperty.signal.map {
      $0?.localizedDescription
    }.skipNil()
    let graphError = addNewCardEvent.errors().map {
      $0.localizedDescription
    }
    let addNewCardError = addNewCardEvent.map { $0.value?.errorMessage }.skipNil()

    let errorMessage = Signal.merge(
      stripeInvalidToken,
      graphError,
      addNewCardError
    )

    self.addNewCardFailure = errorMessage.map { $0 }

    self.activityIndicatorShouldShow = Signal.merge(
      submitPaymentDetails.mapConst(true),
      self.newCardAddedWithMessage.mapConst(false),
      self.addNewCardFailure.mapConst(false)
    )

    self.rememberThisCardToggleViewControllerContainerIsHidden = intent.map { $0 == .settings }

    // Koala
    self.viewWillAppearProperty.signal
      .observeValues {
        AppEnvironment.current.koala.trackViewedAddNewCard()
      }

    self.newCardAddedWithMessage
      .observeValues { _ in
        AppEnvironment.current.koala.trackSavedPaymentMethod()
      }

    self.addNewCardFailure
      .observeValues { _ in
        AppEnvironment.current.koala.trackFailedPaymentMethodCreation()
      }
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

  private let addNewCardIntentAndProjectProperty = MutableProperty<(AddNewCardIntent, Project?)?>(nil)
  public func configure(with intent: AddNewCardIntent, project: Project?) {
    self.addNewCardIntentAndProjectProperty.value = (intent, project)
  }

  private let paymentInfoIsValidProperty = MutableProperty(false)
  public func paymentInfo(isValid: Bool) {
    self.paymentInfoIsValidProperty.value = isValid
  }

  private let rememberThisCardToggleChangedToValue = MutableProperty(false)
  public func rememberThisCardToggleChanged(to value: Bool) {
    self.rememberThisCardToggleChangedToValue.value = value
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
      self.stripeTokenProperty.value = (token, stripeID)
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

  private let zipcodeProperty = MutableProperty<String?>(nil)
  public func zipcodeChanged(zipcode: String?) {
    self.zipcodeProperty.value = zipcode
  }

  private let zipcodeTextFieldDidEndEditingProperty = MutableProperty(())
  public func zipcodeTextFieldDidEndEditing() {
    self.zipcodeTextFieldDidEndEditingProperty.value = ()
  }

  public let activityIndicatorShouldShow: Signal<Bool, Never>
  public let addNewCardFailure: Signal<String, Never>
  public let creditCardValidationErrorContainerHidden: Signal<Bool, Never>
  public let cardholderNameBecomeFirstResponder: Signal<Void, Never>
  public let dismissKeyboard: Signal<Void, Never>
  public let newCardAddedWithMessage: Signal<(GraphUserCreditCard.CreditCard, String), Never>
  public let paymentDetails: Signal<PaymentDetails, Never>
  public let paymentDetailsBecomeFirstResponder: Signal<Void, Never>
  public let rememberThisCardToggleViewControllerContainerIsHidden: Signal<Bool, Never>
  public let rememberThisCardToggleViewControllerIsOn: Signal<Bool, Never>
  public let saveButtonIsEnabled: Signal<Bool, Never>
  public let setStripePublishableKey: Signal<String, Never>
  public let unsupportedCardBrandErrorText: Signal<String, Never>

  public var inputs: AddNewCardViewModelInputs { return self }
  public var outputs: AddNewCardViewModelOutputs { return self }
}

private func cardBrandIsSupported(project: Project?, cardBrand: CreditCardType) -> Bool {
  let supportedCardBrands: [CreditCardType] = [
    .amex,
    .diners,
    .discover,
    .jcb,
    .mastercard,
    .unionPay,
    .visa
  ]

  guard let availableCardTypes = project?.availableCardTypes else {
    return supportedCardBrands.contains(cardBrand)
  }

  let availableCreditCardTypes = availableCardTypes
    .compactMap { CreditCardType(rawValue: $0) }

  return availableCreditCardTypes.contains(cardBrand)
}
