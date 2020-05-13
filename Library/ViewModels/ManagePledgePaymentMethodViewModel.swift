import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public struct ManagePledgePaymentMethodViewData: Equatable {
  public let backingState: BackingState
  public let expirationDate: String?
  public let lastFour: String?
  public let creditCardType: CreditCardType?
  public let paymentType: PaymentType?
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
      .skipNil()

    let cardType = self.configureWithDataSignal
      .map(\.creditCardType)
      .skipNil()

    let lastFour = self.configureWithDataSignal
      .map(\.lastFour)
      .skipNil()

    self.cardNumberAccessibilityLabel = Signal.combineLatest(
      paymentType,
      cardType,
      lastFour
    )
    .map {
      [$0.0.accessibilityLabel, $0.1.description, Strings.Card_ending_in_last_four(last_four: $0.2)]
        .compact()
        .joined(separator: ", ")
    }

    self.cardNumberTextShortStyle = lastFour
      .map { Strings.Ending_in_last_four(last_four: $0) }

    self.expirationDateText = self.configureWithDataSignal
      .map(\.expirationDate)
      .skipNil()
      .map { String($0.dropLast(3)) }
      .map(formatted(dateString:))
      .map { Strings.Credit_card_expiration(expiration_date: $0) }

    self.fixButtonHidden = self.configureWithDataSignal
      .map { $0.backingState != .errored }

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
  case nil:
    return nil
  }
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
