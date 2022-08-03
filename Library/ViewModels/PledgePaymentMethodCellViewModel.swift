import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public typealias PledgePaymentMethodCellData = (
  card: UserCreditCards.CreditCard,
  isEnabled: Bool,
  isSelected: Bool,
  projectCountry: String,
  isErroredPaymentMethod: Bool
)

public typealias PaymentSheetPaymentMethodCellData = (image: UIImage, redactedCardNumber: String)

public protocol PledgePaymentMethodCellViewModelInputs {
  /// Call to configure cell with card and selected card values.
  func configureWith(value: PledgePaymentMethodCellData)

  /// Call to configure cell with payment sheet card values (temporary Stripe enabled cards)
  func configureWithPaymentSheetCard(value: PaymentSheetPaymentMethodCellData)

  /// Call with the currently selected card.
  func setSelectedCard(_ creditCard: UserCreditCards.CreditCard)
}

public protocol PledgePaymentMethodCellViewModelOutputs {
  /// Emits the alpha for the card image
  var cardImageAlpha: Signal<CGFloat, Never> { get }

  /// Emits the card's image name.
  var cardImageName: Signal<String, Never> { get }

  /// Emits the card's image.
  var cardImage: Signal<UIImage, Never> { get }

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
    let paymentSheetCreditCardImage = self.configurePaymentSheetCardValueProperty.signal.skipNil()
      .map(\.image)
    let paymentSheetCreditCardRedactedNumber = self.configurePaymentSheetCardValueProperty.signal.skipNil()
      .map(\.redactedCardNumber)
    let creditCard = self.configureValueProperty.signal.skipNil().map(\.card)
    let selectedCard = self.selectedCardProperty.signal.skipNil()
    let cardTypeIsAvailable = self.configureValueProperty.signal.skipNil().map(\.isEnabled)
    let configuredAsSelected = self.configureValueProperty.signal.skipNil().map(\.isSelected)

    self.cardImage = paymentSheetCreditCardImage

    self.cardImageName = creditCard
      .map { $0.imageName }

    let creditCardAccessibilityLabel = creditCard
      .map {
        [$0.type?.description, Strings.Card_ending_in_last_four(last_four: $0.lastFour)]
          .compact()
          .joined(separator: ", ")
      }

    let paymentSheetCreditCardAccessibilityLabel = paymentSheetCreditCardRedactedNumber.map {
      Strings.Card_ending_in_last_four(last_four: $0)
    }

    self.cardNumberAccessibilityLabel = Signal
      .merge(creditCardAccessibilityLabel, paymentSheetCreditCardAccessibilityLabel)

    let redactedCardNumber = creditCard
      .map { "•••• \($0.lastFour)" }

    self.cardNumberTextShortStyle = Signal.merge(redactedCardNumber, paymentSheetCreditCardRedactedNumber)

    let creditCardExpiryDate = creditCard
      .map { Strings.Credit_card_expiration(expiration_date: $0.expirationDate()) }

    let paymentSheetCreditCardExpiryDate = paymentSheetCreditCardRedactedNumber
      .map(String.init)

    self.expirationDateText = Signal.merge(creditCardExpiryDate, paymentSheetCreditCardExpiryDate)

    let cardAndSelectedCard = Signal.combineLatest(
      creditCard,
      selectedCard
    )

    let setAsSelected = cardAndSelectedCard.map(==)

    let creditCardCheckImageName = Signal.merge(configuredAsSelected, setAsSelected)
      .map { $0 ? "icon-payment-method-selected" : "icon-payment-method-unselected" }

    // FIXME: All payment sheet cards are mapping to unselected temporarily. Revisit this once displaying multiple payment sheet cards is working.
    let paymentSheetCheckImageName = paymentSheetCreditCardExpiryDate
      .map { _ in "icon-payment-method-unselected" }

    self.checkmarkImageName = Signal.merge(creditCardCheckImageName, paymentSheetCheckImageName)

    let creditCardLabelUnavailable = self.configureValueProperty.signal.skipNil()
      .map { card in !card.isEnabled || card.isErroredPaymentMethod }

    let paymentSheetCreditCardUnavailable = paymentSheetCreditCardRedactedNumber.mapConst(false)

    self.unavailableCardLabelHidden = Signal
      .merge(creditCardLabelUnavailable.negate(), paymentSheetCreditCardUnavailable.negate())

    let cardText = self.configureValueProperty.signal.skipNil()
      .filter { card in !card.isEnabled || card.isErroredPaymentMethod }
      .map { card -> String in
        if !card.isEnabled {
          return Strings.You_cant_use_this_credit_card_to_back_a_project_from_project_country(
            project_country: card.projectCountry
          )
        }

        return Strings.Retry_or_select_another_method()
      }

    let paymentSheetCardText = paymentSheetCreditCardRedactedNumber.map { _ in Strings.general_error_oops() }

    self.unavailableCardText = Signal.merge(cardText, paymentSheetCardText)

    let creditCardIsAvailableForSelectionStyle = cardTypeIsAvailable.map {
      $0 ? UITableViewCell.SelectionStyle.default : .none
    }

    let paymentSheetCreditCardIsAvailableForSelectionStyle = paymentSheetCreditCardRedactedNumber
      .map { _ in UITableViewCell.SelectionStyle.default }

    self.selectionStyle = Signal
      .merge(creditCardIsAvailableForSelectionStyle, paymentSheetCreditCardIsAvailableForSelectionStyle)

    let creditCardIsAvailable = cardTypeIsAvailable.map {
      CGFloat($0 ? 1.0 : 0.5)
    }

    let paymentSheetCreditCardIsAvailable = paymentSheetCreditCardRedactedNumber.map { _ in CGFloat(1.0) }

    self.cardImageAlpha = Signal.merge(creditCardIsAvailable, paymentSheetCreditCardIsAvailable)

    let creditCardImageHidden = cardTypeIsAvailable.negate()

    let paymentSheetCreditCardImageHidden = paymentSheetCreditCardRedactedNumber.mapConst(false)

    self.checkmarkImageHidden = Signal.merge(creditCardImageHidden, paymentSheetCreditCardImageHidden)

    let creditCardTextColor = cardTypeIsAvailable.map { cardTypeIsAvailable in
      cardTypeIsAvailable ? UIColor.ksr_support_700 : UIColor.ksr_support_400
    }

    let paymentSheetTextColor = paymentSheetCreditCardRedactedNumber.mapConst(UIColor.ksr_support_700)

    self.lastFourLabelTextColor = Signal.merge(creditCardTextColor, paymentSheetTextColor)
  }

  fileprivate let configureValueProperty = MutableProperty<PledgePaymentMethodCellData?>(nil)
  public func configureWith(value: PledgePaymentMethodCellData) {
    self.configureValueProperty.value = value
  }

  fileprivate let configurePaymentSheetCardValueProperty =
    MutableProperty<PaymentSheetPaymentMethodCellData?>(nil)
  public func configureWithPaymentSheetCard(value: PaymentSheetPaymentMethodCellData) {
    self.configurePaymentSheetCardValueProperty.value = value
  }

  private let selectedCardProperty = MutableProperty<UserCreditCards.CreditCard?>(nil)
  public func setSelectedCard(_ creditCard: UserCreditCards.CreditCard) {
    self.selectedCardProperty.value = creditCard
  }

  public let cardImageAlpha: Signal<CGFloat, Never>
  public let cardImageName: Signal<String, Never>
  public let cardImage: Signal<UIImage, Never>
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
