import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public protocol ManagePledgePaymentMethodViewModelInputs {
  /// Call to configure payment method section with payment source values.
  func configureWith(value: Backing.PaymentSource)
}

public protocol ManagePledgePaymentMethodViewModelOutputs {
  /// Emits the card's image.
  var cardImage: Signal<UIImage?, Never> { get }

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
      .map(cardImage(for:))

    self.cardNumberAccessibilityLabel = self.paymentSourceSignal
      .map {
        [$0.type?.description, Strings.Card_ending_in_last_four(last_four: $0.lastFour ?? .init())]
          .compact()
          .joined(separator: ", ")
      }

    self.cardNumberTextShortStyle = self.paymentSourceSignal
      .map { $0.lastFour }
      .skipNil()
      .map { Strings.Ending_in_last_four(last_four: $0) }

    self.expirationDateText = self.paymentSourceSignal
      .map { String($0.expirationDate?.dropLast(3) ?? "") }
      .map(formatted(dateString:))
      .map { Strings.Credit_card_expiration(expiration_date: $0) }
  }

  fileprivate let (paymentSourceSignal, paymentSourceObserver) = Signal<Backing.PaymentSource, Never>.pipe()
  public func configureWith(value: Backing.PaymentSource) {
    self.paymentSourceObserver.send(value: value)
  }

  public let cardImage: Signal<UIImage?, Never>
  public let cardNumberAccessibilityLabel: Signal<String, Never>
  public let cardNumberTextShortStyle: Signal<String, Never>
  public let expirationDateText: Signal<String, Never>

  public var inputs: ManagePledgePaymentMethodViewModelInputs { return self }
  public var outputs: ManagePledgePaymentMethodViewModelOutputs { return self }
}

private func cardImage(for paymentSource: Backing.PaymentSource) -> UIImage? {
  switch paymentSource.paymentType {
  case .creditCard?:
    return image(named: paymentSource.imageName)
  case .applePay?:
    return image(named: "icon--apple-pay")
  case .none:
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
