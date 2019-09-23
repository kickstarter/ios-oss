import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public protocol PledgeCreditCardViewModelInputs {
  /// Call to configure cell with card and selected card values.
  func configureWith(value: GraphUserCreditCard.CreditCard)

  /// Call with the currently selected card.
  func setSelectedCard(_ creditCard: GraphUserCreditCard.CreditCard)

  /// Call when the "select" button is tapped.
  func selectButtonTapped()
}

public protocol PledgeCreditCardViewModelOutputs {
  /// Emits the card's image.
  var cardImage: Signal<UIImage?, Never> { get }

  /// Emits a formatted accessibility string containing the card type, number and last four digits
  var cardNumberAccessibilityLabel: Signal<String, Never> { get }

  /// Emits a formatted string containing the card's last four digits with the format: Ending in 8844.
  var cardNumberTextShortStyle: Signal<String, Never> { get }

  /// Emits the formatted card's expirationdate.
  var expirationDateText: Signal<String, Never> { get }

  /// Emits the paymentSourceId of the current card.
  var notifyDelegateOfCardSelected: Signal<String, Never> { get }

  /// Emits the button style type based on its selected state.
  var selectButtonStyleType: Signal<ButtonStyleType, Never> { get }

  /// Emits the button title.
  var selectButtonTitle: Signal<String, Never> { get }
}

public protocol PledgeCreditCardViewModelType {
  var inputs: PledgeCreditCardViewModelInputs { get }
  var outputs: PledgeCreditCardViewModelOutputs { get }
}

public final class PledgeCreditCardViewModel: PledgeCreditCardViewModelInputs,
  PledgeCreditCardViewModelOutputs, PledgeCreditCardViewModelType {
  public init() {
    let creditCard = self.creditCardProperty.signal.skipNil()
    let selectedCard = self.selectedCardProperty.signal.skipNil()

    self.cardImage = creditCard
      .map(cardImageForCard)

    self.cardNumberAccessibilityLabel = creditCard
      .map {
        [$0.type?.description, Strings.Card_ending_in_last_four(last_four: $0.lastFour)]
          .compact()
          .joined(separator: ", ")
      }

    self.cardNumberTextShortStyle = creditCard
      .map { Strings.Ending_in_last_four(last_four: $0.lastFour) }

    self.expirationDateText = creditCard
      .map { Strings.Credit_card_expiration(expiration_date: $0.expirationDate()) }

    self.notifyDelegateOfCardSelected = creditCard
      .takeWhen(self.selectButtonTappedProperty.signal)
      .map { $0.id }

    let cardAndSelectedCard = Signal.combineLatest(
      creditCard,
      selectedCard
    )

    self.selectButtonTitle = cardAndSelectedCard
      .map(==)
      .map { $0 ? Strings.Selected() : Strings.Select() }

    self.selectButtonStyleType = cardAndSelectedCard
      .map(==)
      .map { $0 ? .greyWhiteText : .black }
  }

  fileprivate let creditCardProperty = MutableProperty<GraphUserCreditCard.CreditCard?>(nil)
  public func configureWith(value: GraphUserCreditCard.CreditCard) {
    self.creditCardProperty.value = value
  }

  private let selectedCardProperty = MutableProperty<GraphUserCreditCard.CreditCard?>(nil)
  public func setSelectedCard(_ creditCard: GraphUserCreditCard.CreditCard) {
    self.selectedCardProperty.value = creditCard
  }

  fileprivate let selectButtonTappedProperty = MutableProperty(())
  public func selectButtonTapped() {
    self.selectButtonTappedProperty.value = ()
  }

  public let cardImage: Signal<UIImage?, Never>
  public let cardNumberAccessibilityLabel: Signal<String, Never>
  public let cardNumberTextShortStyle: Signal<String, Never>
  public let expirationDateText: Signal<String, Never>
  public let notifyDelegateOfCardSelected: Signal<String, Never>
  public let selectButtonTitle: Signal<String, Never>
  public let selectButtonStyleType: Signal<ButtonStyleType, Never>

  public var inputs: PledgeCreditCardViewModelInputs { return self }
  public var outputs: PledgeCreditCardViewModelOutputs { return self }
}

private func cardImageForCard(_ card: GraphUserCreditCard.CreditCard) -> UIImage? {
  return image(named: card.imageName)
}
