import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public typealias PledgePaymentMethodCellData = (
  card: GraphUserCreditCard.CreditCard,
  isEnabled: Bool,
  isSelected: Bool,
  projectCountry: String,
  isErroredPaymentMethod: Bool
)

public protocol PledgePaymentMethodCellViewModelInputs {
  /// Call to configure cell with card and selected card values.
  func configureWith(value: PledgePaymentMethodCellData)

  /// Call with the currently selected card.
  func setSelectedCard(_ creditCard: GraphUserCreditCard.CreditCard)
}

public protocol PledgePaymentMethodCellViewModelOutputs {
  /// Emits the alpha for the card image
  var cardImageAlpha: Signal<CGFloat, Never> { get }

  /// Emits the card's image name.
  var cardImageName: Signal<String, Never> { get }

  /// Emits a formatted accessibility string containing the card type, number and last four digits
  var cardNumberAccessibilityLabel: Signal<String, Never> { get }

  /// Emits a formatted string containing the card's last four digits.
  var cardNumberTextShortStyle: Signal<String, Never> { get }

  /// Emits when the checkmark image should be hidden.
  var checkmarkImageHidden: Signal<Bool, Never> { get }

  /// Emits the checkmark image.
  var checkmarkImageName: Signal<String, Never> { get }

  /// Emits the formatted card's expirationdate.
  var expirationDateText: Signal<String, Never> { get }

  /// Emits the text color for the last four digits label.
  var lastFourLabelTextColor: Signal<UIColor, Never> { get }

  /// Emits the selection cell's selection style.
  var selectionStyle: Signal<UITableViewCell.SelectionStyle, Never> { get }

  /// Emits whether or not the unavailable card type label should be hidden.
  var unavailableCardLabelHidden: Signal<Bool, Never> { get }

  /// Emits a string explaining why card type is unavailable.
  var unavailableCardText: Signal<String, Never> { get }
}

public protocol PledgePaymentMethodCellViewModelType {
  var inputs: PledgePaymentMethodCellViewModelInputs { get }
  var outputs: PledgePaymentMethodCellViewModelOutputs { get }
}

public final class PledgePaymentMethodCellViewModel: PledgePaymentMethodCellViewModelInputs,
  PledgePaymentMethodCellViewModelOutputs, PledgePaymentMethodCellViewModelType {
  public init() {
    let creditCard = self.configureValueProperty.signal.skipNil().map(\.card)
    let selectedCard = self.selectedCardProperty.signal.skipNil()
    let cardTypeIsAvailable = self.configureValueProperty.signal.skipNil().map(\.isEnabled)
    let configuredAsSelected = self.configureValueProperty.signal.skipNil().map(\.isSelected)

    self.cardImageName = creditCard
      .map { $0.imageName }

    self.cardNumberAccessibilityLabel = creditCard
      .map {
        [$0.type?.description, Strings.Card_ending_in_last_four(last_four: $0.lastFour)]
          .compact()
          .joined(separator: ", ")
      }

    self.cardNumberTextShortStyle = creditCard
      .map { "•••• \($0.lastFour)" }

    self.expirationDateText = creditCard
      .map { Strings.Credit_card_expiration(expiration_date: $0.expirationDate()) }

    let cardAndSelectedCard = Signal.combineLatest(
      creditCard,
      selectedCard
    )

    let setAsSelected = cardAndSelectedCard.map(==)

    self.checkmarkImageName = Signal.merge(configuredAsSelected, setAsSelected)
      .map { $0 ? "icon-payment-method-selected" : "icon-payment-method-unselected" }

    self.unavailableCardLabelHidden = self.configureValueProperty.signal.skipNil()
      .map { card in !card.isEnabled || card.isErroredPaymentMethod }
      .negate()

    self.unavailableCardText = self.configureValueProperty.signal.skipNil()
      .filter { card in !card.isEnabled || card.isErroredPaymentMethod }
      .map { card in
        if !card.isEnabled {
          return Strings.You_cant_use_this_credit_card_to_back_a_project_from_project_country(
            project_country: card.projectCountry
          )
        }

        return Strings.Retry_or_select_another_method()
      }

    self.selectionStyle = cardTypeIsAvailable.map {
      $0 ? .default : .none
    }

    self.cardImageAlpha = cardTypeIsAvailable.map {
      $0 ? 1.0 : 0.5
    }

    self.checkmarkImageHidden = cardTypeIsAvailable.negate()

    self.lastFourLabelTextColor = cardTypeIsAvailable.map {
      $0 ? .ksr_soft_black : .ksr_dark_grey_500
    }
  }

  fileprivate let configureValueProperty = MutableProperty<PledgePaymentMethodCellData?>(nil)
  public func configureWith(value: PledgePaymentMethodCellData) {
    self.configureValueProperty.value = value
  }

  private let selectedCardProperty = MutableProperty<GraphUserCreditCard.CreditCard?>(nil)
  public func setSelectedCard(_ creditCard: GraphUserCreditCard.CreditCard) {
    self.selectedCardProperty.value = creditCard
  }

  public let cardImageAlpha: Signal<CGFloat, Never>
  public let cardImageName: Signal<String, Never>
  public let cardNumberAccessibilityLabel: Signal<String, Never>
  public let cardNumberTextShortStyle: Signal<String, Never>
  public let checkmarkImageHidden: Signal<Bool, Never>
  public let checkmarkImageName: Signal<String, Never>
  public let expirationDateText: Signal<String, Never>
  public let lastFourLabelTextColor: Signal<UIColor, Never>
  public let selectionStyle: Signal<UITableViewCell.SelectionStyle, Never>
  public let unavailableCardLabelHidden: Signal<Bool, Never>
  public let unavailableCardText: Signal<String, Never>

  public var inputs: PledgePaymentMethodCellViewModelInputs { return self }
  public var outputs: PledgePaymentMethodCellViewModelOutputs { return self }
}
