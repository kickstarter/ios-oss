@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CreditCardCellViewModelTests: TestCase {
  internal let vm: CreditCardCellViewModelType = CreditCardCellViewModel()

  private let cardImage = TestObserver<UIImage?, Never>()
  private let cardNumberAccessibilityLabel = TestObserver<String, Never>()
  private let cardNumberTextLongStyle = TestObserver<String, Never>()
  private let expirationDateText = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.cardImage.observe(self.cardImage.observer)
    self.vm.outputs.cardNumberAccessibilityLabel.observe(self.cardNumberAccessibilityLabel.observer)
    self.vm.outputs.cardNumberTextLongStyle.observe(self.cardNumberTextLongStyle.observer)
    self.vm.outputs.expirationDateText.observe(self.expirationDateText.observer)
  }

  func testCardInfoForSupportedCards() {
    self.vm.inputs.configureWith(creditCard: UserCreditCards.amex)

    self.cardImage.assertLastValue(UIImage(named: "icon--amex"))
    self.cardNumberAccessibilityLabel.assertLastValue("Amex, Card ending in 8882")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 8882")
    self.expirationDateText.assertLastValue("Expires 01/2024")

    self.vm.inputs.configureWith(creditCard: UserCreditCards.discover)

    self.cardImage.assertLastValue(UIImage(named: "icon--discover"))
    self.cardNumberAccessibilityLabel.assertLastValue("Discover, Card ending in 4242")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 4242")
    self.expirationDateText.assertLastValue("Expires 03/2022")

    self.vm.inputs.configureWith(creditCard: UserCreditCards.jcb)

    self.cardImage.assertLastValue(UIImage(named: "icon--jcb"))
    self.cardNumberAccessibilityLabel.assertLastValue("Jcb, Card ending in 2222")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 2222")
    self.expirationDateText.assertLastValue("Expires 01/2022")

    self.vm.inputs.configureWith(creditCard: UserCreditCards.masterCard)

    self.cardImage.assertLastValue(UIImage(named: "icon--mastercard"))
    self.cardNumberAccessibilityLabel.assertLastValue("Mastercard, Card ending in 0000")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 0000")
    self.expirationDateText.assertLastValue("Expires 10/2018")

    self.vm.inputs.configureWith(creditCard: UserCreditCards.visa)

    self.cardImage.assertLastValue(UIImage(named: "icon--visa"))
    self.cardNumberAccessibilityLabel.assertLastValue("Visa, Card ending in 1111")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 1111")
    self.expirationDateText.assertLastValue("Expires 09/2019")

    self.vm.inputs.configureWith(creditCard: UserCreditCards.diners)

    self.cardImage.assertLastValue(UIImage(named: "icon--diners"))
    self.cardNumberAccessibilityLabel.assertLastValue("Diners, Card ending in 1212")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 1212")
    self.expirationDateText.assertLastValue("Expires 09/2022")
  }

  func testSelectedCard() {
    self.vm.inputs.configureWith(creditCard: UserCreditCards.generic)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
  }

  func testCardInfoForUnsupportedCards() {
    self.vm.inputs.configureWith(creditCard: UserCreditCards.generic)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
  }

  func testCardInfoForUnknownCardType() {
    let unknownCard = UserCreditCards.generic |> \.type .~ nil

    self.vm.inputs.configureWith(creditCard: unknownCard)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberAccessibilityLabel.assertLastValue("Card ending in 1882")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
  }
}
