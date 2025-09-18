import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public struct ManagePledgePaymentMethodViewData: Equatable {
  public let backingState: Backing.Status
  public let expirationDate: String?
  public let lastFour: String?
  public let creditCardType: CreditCardType?
  public let paymentType: PaymentType?
  public let isPledgeOverTime: Bool
}

public protocol ManagePledgePaymentMethodViewModelInputs {
  /// Call to configure payment method section the values from a backing
  func configureWith(data: ManagePledgePaymentMethodViewData)

  /// Call when the "Fix" button is tapped
  func fixButtonTapped()
}

public protocol ManagePledgePaymentMethodViewModelOutputs {
  /// Emits the card's image.
  var cardImageName: Signal<String, Never> { get }

  /// Emits a formatted accessibility string containing the card type, number and last four digits
  var cardNumberAccessibilityLabel: Signal<String, Never> { get }

  /// Emits a formatted string containing the card's last four digits with the format: Ending in 8844.
  var cardNumberTextShortStyle: Signal<String, Never> { get }

  /// Emits the formatted card's expirationdate.
  var expirationDateText: Signal<String, Never> { get }

  /// Emits whether the Fix button is hidden
  var fixButtonHidden: Signal<Bool, Never> { get }

  /// Emits when the fix button was tapped
  var notifyDelegateFixButtonTapped: Signal<Void, Never> { get }
}

public protocol ManagePledgePaymentMethodViewModelType {
  var inputs: ManagePledgePaymentMethodViewModelInputs { get }
  var outputs: ManagePledgePaymentMethodViewModelOutputs { get }
}

public final class ManagePledgePaymentMethodViewModel: ManagePledgePaymentMethodViewModelInputs,
  ManagePledgePaymentMethodViewModelOutputs, ManagePledgePaymentMethodViewModelType {
  public init() {
    self.cardImageName = self.configureWithDataSignal
      .map { ($0.paymentType, $0.creditCardType) }
      .map(imageName(for:creditCardType:))
      .skipNil()

    let paymentType = self.configureWithDataSignal
      .map(\.paymentType)

    let cardType = self.configureWithDataSignal
      .map(\.creditCardType)

    let lastFour = self.configureWithDataSignal
      .map(\.lastFour)

    self.cardNumberAccessibilityLabel = Signal.combineLatest(
      paymentType,
      cardType,
      lastFour
    )
    .map(paymentMethodAccessibilityLabel)

    self.cardNumberTextShortStyle = lastFour
      .skipNil()
      .map { Strings.Ending_in_last_four(last_four: $0) }

    self.expirationDateText = self.configureWithDataSignal
      .map(\.expirationDate)
      .skipNil()
      .map { String($0.dropLast(3)) }
      .map(formatted(dateString:))
      .map { Strings.Credit_card_expiration(expiration_date: $0) }

    self.fixButtonHidden = self.configureWithDataSignal
      // TODO: these changes are temporary and will likely be removed when we get to the native implementation in this ticket [MBL-2012](https://kickstarter.atlassian.net/browse/MBL-2012)
      // For PLOT pledges, the fix button is always hidden because the fix action is handled by the `PledgeStatusLabelView`.
      .map { $0.backingState != .errored || $0.isPledgeOverTime }

    self.notifyDelegateFixButtonTapped = self.fixButtonTappedSignal
  }

  fileprivate let (configureWithDataSignal, configureWithDataObserver)
    = Signal<ManagePledgePaymentMethodViewData, Never>.pipe()
  public func configureWith(data: ManagePledgePaymentMethodViewData) {
    self.configureWithDataObserver.send(value: data)
  }

  fileprivate let (fixButtonTappedSignal, fixButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func fixButtonTapped() {
    self.fixButtonTappedObserver.send(value: ())
  }

  public let cardImageName: Signal<String, Never>
  public let cardNumberAccessibilityLabel: Signal<String, Never>
  public let cardNumberTextShortStyle: Signal<String, Never>
  public let expirationDateText: Signal<String, Never>
  public let fixButtonHidden: Signal<Bool, Never>
  public let notifyDelegateFixButtonTapped: Signal<Void, Never>

  public var inputs: ManagePledgePaymentMethodViewModelInputs { return self }
  public var outputs: ManagePledgePaymentMethodViewModelOutputs { return self }
}

private func imageName(for paymentType: PaymentType?, creditCardType: CreditCardType?) -> String? {
  switch paymentType {
  case .creditCard:
    return creditCardType?.imageName
  case .applePay:
    return "icon--apple-pay"
  case .googlePay:
    return "icon--google-pay"
  case .bankAccount:
    return "icon--credit-card"
  case nil:
    return nil
  }
}

private func paymentMethodAccessibilityLabel(
  for paymentType: PaymentType?,
  cardType: CreditCardType?,
  lastFour: String?
) -> String {
  let paymentTypeDescription = paymentType.flatMap { paymentType in
    switch paymentType {
    case .applePay:
      return Strings.accessibility_payment_types_apple_pay()
    case .googlePay:
      return Strings.accessibility_payment_types_google_pay()
    case .bankAccount:
      return Strings.accessibility_payment_types_bank_account()
    case .creditCard:
      return nil
    }
  }

  let lastFourDescription = lastFour.map(Strings.Card_ending_in_last_four)

  return [paymentTypeDescription, cardType?.description, lastFourDescription]
    .compact()
    .joined(separator: ", ")
}

private func formatted(dateString: String) -> String {
  let date = toDate(dateString: dateString)
  return Format.date(
    secondsInUTC: date.timeIntervalSince1970,
    template: "MM-yyyy",
    timeZone: UTCTimeZone
  )
}

private func toDate(dateString: String) -> Date {
  // Always use UTC timezone here this date should be timezone agnostic
  guard let date = Format.date(
    from: dateString,
    dateFormat: "yyyy-MM",
    timeZone: UTCTimeZone
  ) else {
    fatalError("Unable to parse date format")
  }

  return date
}
