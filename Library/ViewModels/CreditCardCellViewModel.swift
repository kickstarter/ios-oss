import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public protocol CreditCardCellViewModelInputs {
  /// Call to configure cell with card value.
  func configureWith(creditCard: GraphUserCreditCard.CreditCard)
}

public protocol CreditCardCellViewModelOutputs {
  /// Emits the card's image.
  var cardImage: Signal<UIImage?, Never> { get }

  /// Emits a formatted accessibility string containing the card type, number and last four digits
  var cardNumberAccessibilityLabel: Signal<String, Never> { get }

  /// Emits a formatted string containing the card's last four digits.
  var cardNumberText: Signal<String, Never> { get }

  /// Emits the formatted card's expirationdate.
  var expirationDateText: Signal<String, Never> { get }
}

public protocol CreditCardCellViewModelType {
  var inputs: CreditCardCellViewModelInputs { get }
  var outputs: CreditCardCellViewModelOutputs { get }
}

public final class CreditCardCellViewModel: CreditCardCellViewModelInputs,
  CreditCardCellViewModelOutputs, CreditCardCellViewModelType {
  public init() {
    self.cardImage = self.cardProperty.signal.skipNil()
      .map(cardImageForCard)

    self.cardNumberAccessibilityLabel = self.cardProperty.signal.skipNil()
      .map {
        [$0.type?.description, Strings.Card_ending_in_last_four(last_four: $0.lastFour)]
          .compact()
          .joined(separator: ", ")
      }

    self.cardNumberText = self.cardProperty.signal.skipNil()
      .map { Strings.Card_ending_in_last_four(last_four: $0.lastFour) }

    self.expirationDateText = self.cardProperty.signal.skipNil()
      .map { $0.formattedExpirationDate }
      .map { Strings.Credit_card_expiration(expiration_date: formatted(dateString: $0)) }
  }

  fileprivate let cardProperty = MutableProperty<GraphUserCreditCard.CreditCard?>(nil)
  public func configureWith(creditCard: GraphUserCreditCard.CreditCard) {
    self.cardProperty.value = creditCard
  }

  public let cardNumberAccessibilityLabel: Signal<String, Never>
  public let cardImage: Signal<UIImage?, Never>
  public let expirationDateText: Signal<String, Never>
  public let cardNumberText: Signal<String, Never>

  public var inputs: CreditCardCellViewModelInputs { return self }
  public var outputs: CreditCardCellViewModelOutputs { return self }
}

private func cardImageForCard(_ card: GraphUserCreditCard.CreditCard) -> UIImage? {
  return image(named: card.imageName)
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
