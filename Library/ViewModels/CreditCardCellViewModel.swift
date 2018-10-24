import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol CreditCardCellViewModelInputs {
  /// Call to configure cell with card value.
  func configureWith(creditCard: GraphUserCreditCard.CreditCard)
}

public protocol CreditCardCellViewModelOutputs {
  /// Emits the card's image.
  var cardImage: Signal<UIImage, NoError> { get }

  /// Emits a formatted string containing the card's last four digits.
  var cardNumberText: Signal<String, NoError> { get }

  /// Emits the formatted card's expirationdate.
  var expirationDateText: Signal<String, NoError> { get }
}

public protocol CreditCardCellViewModelType {
  var inputs: CreditCardCellViewModelInputs { get }
  var outputs: CreditCardCellViewModelOutputs { get }
}

public final class CreditCardCellViewModel: CreditCardCellViewModelInputs,
CreditCardCellViewModelOutputs, CreditCardCellViewModelType {

  public init() {

    self.cardImage = .empty

    self.cardNumberText = self.cardProperty.signal.skipNil()
      .map { "Card ending in " + $0.lastFour }

    self.expirationDateText = self.cardProperty.signal.skipNil()
      .map { "Expires " + $0.expirationDate }
  }

  fileprivate let cardProperty = MutableProperty<GraphUserCreditCard.CreditCard?>(nil)
  public func configureWith(creditCard: GraphUserCreditCard.CreditCard) {
    self.cardProperty.value = creditCard
  }

  public let cardImage: Signal<UIImage, NoError>
  public let expirationDateText: Signal<String, NoError>
  public let cardNumberText: Signal<String, NoError>

  public var inputs: CreditCardCellViewModelInputs { return self }
  public var outputs: CreditCardCellViewModelOutputs { return self }
}
