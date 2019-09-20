import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public protocol CreditCardCellViewModelInputs {
  /// Call when a new card has been added by user.
  func addedNewCard()

  /// Call to configure cell with card value.
  func configureWith(creditCard: GraphUserCreditCard.CreditCard, isNew: Bool)

  /// Call when the "select" button is tapped.
  func selectButtonTapped()
}

public protocol CreditCardCellViewModelOutputs {
  /// Emits the card's image.
  var cardImage: Signal<UIImage?, Never> { get }

  /// Emits a formatted accessibility string containing the card type, number and last four digits
  var cardNumberAccessibilityLabel: Signal<String, Never> { get }

  /// Emits a formatted string containing the card's last four digits with the format: Card ending in 8844.
  var cardNumberTextLongStyle: Signal<String, Never> { get }

  /// Emits a formatted string containing the card's last four digits with the format: Ending in 8844.
  var cardNumberTextShortStyle: Signal<String, Never> { get }

  /// Emits the formatted card's expirationdate.
  var expirationDateText: Signal<String, Never> { get }

  /// Emits a bool to set the button state of newly added card to selected.
  var newlyAddedCardSelected: Signal<Bool, Never> { get }

  /// Emits that select button should be in the selected state.
  var notifyButtonTapped: Signal<Void, Never> { get }
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

    self.cardNumberTextShortStyle = self.cardProperty.signal.skipNil()
      .map { Strings.Ending_in_last_four(last_four: $0.lastFour) }

    self.expirationDateText = self.cardProperty.signal.skipNil()
      .map { Strings.Credit_card_expiration(expiration_date: $0.expirationDate()) }

    self.newlyAddedCardSelected = self.isNewCardProperty.signal

    self.notifyButtonTapped = self.selectButtonTappedProperty.signal
  }

  fileprivate let addedNewCardProperty = MutableProperty(())
  public func addedNewCard() {
    self.addedNewCardProperty.value = ()
  }

  fileprivate let cardProperty = MutableProperty<GraphUserCreditCard.CreditCard?>(nil)
  fileprivate let isNewCardProperty = MutableProperty(false)
  public func configureWith(creditCard: GraphUserCreditCard.CreditCard, isNew: Bool) {
    self.cardProperty.value = creditCard
    self.isNewCardProperty.value = isNew
  }

  fileprivate let selectButtonTappedProperty = MutableProperty(())
  public func selectButtonTapped() {
    self.selectButtonTappedProperty.value = ()
  }

  public let cardImage: Signal<UIImage?, Never>
  public let cardNumberAccessibilityLabel: Signal<String, Never>
  public let cardNumberTextLongStyle: Signal<String, Never>
  public let cardNumberTextShortStyle: Signal<String, Never>
  public let expirationDateText: Signal<String, Never>
  public let newlyAddedCardSelected: Signal<Bool, Never>
  public let notifyButtonTapped: Signal<Void, Never>

  public var inputs: CreditCardCellViewModelInputs { return self }
  public var outputs: CreditCardCellViewModelOutputs { return self }
}

private func cardImageForCard(_ card: GraphUserCreditCard.CreditCard) -> UIImage? {
  return image(named: card.imageName)
}
