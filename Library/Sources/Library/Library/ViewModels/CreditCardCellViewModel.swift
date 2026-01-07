import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public protocol CreditCardCellViewModelInputs {
  /// Call to configure cell with card value.
  func configureWith(creditCard: UserCreditCards.CreditCard)
}

public protocol CreditCardCellViewModelOutputs {
  /// Emits the card's image.
  var cardImage: Signal<UIImage?, Never> { get }

  /// Emits a formatted accessibility string containing the card type, number and last four digits
  var cardNumberAccessibilityLabel: Signal<String, Never> { get }

  /// Emits a formatted string containing the card's last four digits with the format: Card ending in 8844.
  var cardNumberTextLongStyle: Signal<String, Never> { get }

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

    self.cardNumberTextLongStyle = self.cardProperty.signal.skipNil()
      .map { Strings.Card_ending_in_last_four(last_four: $0.lastFour) }

    self.expirationDateText = self.cardProperty.signal.skipNil()
      .map { Strings.Credit_card_expiration(expiration_date: $0.expirationDate()) }
  }

  fileprivate let cardProperty = MutableProperty<UserCreditCards.CreditCard?>(nil)
  public func configureWith(creditCard: UserCreditCards.CreditCard) {
    self.cardProperty.value = creditCard
  }

  public let cardImage: Signal<UIImage?, Never>
  public let cardNumberAccessibilityLabel: Signal<String, Never>
  public let cardNumberTextLongStyle: Signal<String, Never>
  public let expirationDateText: Signal<String, Never>

  public var inputs: CreditCardCellViewModelInputs { return self }
  public var outputs: CreditCardCellViewModelOutputs { return self }
}

private func cardImageForCard(_ card: UserCreditCards.CreditCard) -> UIImage? {
  return image(named: card.imageName)
}
