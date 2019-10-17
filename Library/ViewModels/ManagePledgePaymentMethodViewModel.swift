import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ManagePledgePaymentMethodViewModelInputs {
  /// Call to configure payment method section with payment source values.
  func configureWith(value: Backing.PaymentSource)
}

public protocol ManagePledgePaymentMethodViewModelOutputs {
  /// Emits the card's image.
  var cardImage: Signal<String, Never> { get }

  /// Emits a formatted accessibility string containing the card type, number and last four digits
  var cardNumberAccessibilityLabel: Signal<String, Never> { get }

  /// Emits a formatted string containing the card's last four digits with the format: Ending in 8844.
  var cardNumberTextShortStyle: Signal<String, Never> { get }

  /// Emits the formatted card's expirationdate.
  var expirationDateText: Signal<String, Never> { get }
}

public protocol ManagePledgePaymentMethodViewModelType {
  var inputs: ManagePledgePaymentMethodViewModelInputs { get }
  var outputs: ManagePledgePaymentMethodViewModelOutputs { get }
}

public final class ManagePledgePaymentMethodViewModel: ManagePledgePaymentMethodViewModelInputs,
  ManagePledgePaymentMethodViewModelOutputs, ManagePledgePaymentMethodViewModelType {
  public init() {
    self.cardImage = self.paymentSourceSignal
      .map(imageName(for:))
      .skipNil()

    let type = self.paymentSourceSignal
      .map { $0.type }
      .skipNil()

    let lastFour = self.paymentSourceSignal
      .map { $0.lastFour }
      .skipNil()

    self.cardNumberAccessibilityLabel = Signal.combineLatest(
      type,
      lastFour
    )
    .map {
      [$0.0.description, Strings.Card_ending_in_last_four(last_four: $0.1)]
        .compact()
        .joined(separator: ", ")
    }

    self.cardNumberTextShortStyle = lastFour
      .map { Strings.Ending_in_last_four(last_four: $0) }

    self.expirationDateText = self.paymentSourceSignal
      .map { $0.expirationDate }
      .skipNil()
      .map { String($0.dropLast(3)) }
      .map(formatted(dateString:))
      .map { Strings.Credit_card_expiration(expiration_date: $0) }
  }

  fileprivate let (paymentSourceSignal, paymentSourceObserver) = Signal<Backing.PaymentSource, Never>.pipe()
  public func configureWith(value: Backing.PaymentSource) {
    self.paymentSourceObserver.send(value: value)
  }

  public let cardImage: Signal<String, Never>
  public let cardNumberAccessibilityLabel: Signal<String, Never>
  public let cardNumberTextShortStyle: Signal<String, Never>
  public let expirationDateText: Signal<String, Never>

  public var inputs: ManagePledgePaymentMethodViewModelInputs { return self }
  public var outputs: ManagePledgePaymentMethodViewModelOutputs { return self }
}

private func imageName(for paymentSource: Backing.PaymentSource) -> String? {
  switch paymentSource.paymentType {
  case .creditCard:
    return paymentSource.imageName
  case .applePay:
    return "icon--apple-pay"
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
