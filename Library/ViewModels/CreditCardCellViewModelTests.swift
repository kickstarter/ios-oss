import XCTest
import Result
import ReactiveSwift
import Prelude
@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

internal final class CreditCardCellViewModelTests: TestCase {

  internal let vm: CreditCardCellViewModelType = CreditCardCellViewModel()

  let cardImage = TestObserver<UIImage?, NoError>()
  let cardNumberAccessibilityLabel = TestObserver<String, NoError>()
  let cardNumberText = TestObserver<String, NoError>()
  let expirationDateText = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.cardImage.observe(cardImage.observer)
    self.vm.outputs.cardNumberAccessibilityLabel.observe(cardNumberAccessibilityLabel.observer)
    self.vm.outputs.cardNumberText.observe(cardNumberText.observer)
    self.vm.outputs.expirationDateText.observe(expirationDateText.observer)
  }

  func testCardInfoForSupportedCards() {
    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.amex)

    self.cardImage.assertLastValue(UIImage(named: "icon--amex"))
    self.cardNumberAccessibilityLabel.assertLastValue("Amex, Card ending in 8882")
    self.cardNumberText.assertLastValue("Card ending in 8882")
    self.expirationDateText.assertLastValue("Expires 01/2024")

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.discover)

    self.cardImage.assertLastValue(UIImage(named: "icon--discover"))
    self.cardNumberAccessibilityLabel.assertLastValue("Discover, Card ending in 4242")
    self.cardNumberText.assertLastValue("Card ending in 4242")
    self.expirationDateText.assertLastValue("Expires 03/2022")

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.jcb)

    self.cardImage.assertLastValue(UIImage(named: "icon--jcb"))
    self.cardNumberAccessibilityLabel.assertLastValue("Jcb, Card ending in 2222")
    self.cardNumberText.assertLastValue("Card ending in 2222")
    self.expirationDateText.assertLastValue("Expires 01/2022")

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.masterCard)

    self.cardImage.assertLastValue(UIImage(named: "icon--mastercard"))
    self.cardNumberAccessibilityLabel.assertLastValue("Mastercard, Card ending in 0000")
    self.cardNumberText.assertLastValue("Card ending in 0000")
    self.expirationDateText.assertLastValue("Expires 10/2018")

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.visa)

    self.cardImage.assertLastValue(UIImage(named: "icon--visa"))
    self.cardNumberAccessibilityLabel.assertLastValue("Visa, Card ending in 1111")
    self.cardNumberText.assertLastValue("Card ending in 1111")
    self.expirationDateText.assertLastValue("Expires 09/2019")

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.diners)

    self.cardImage.assertLastValue(UIImage(named: "icon--diners"))
    self.cardNumberAccessibilityLabel.assertLastValue("Diners, Card ending in 1212")
    self.cardNumberText.assertLastValue("Card ending in 1212")
    self.expirationDateText.assertLastValue("Expires 09/2022")
  }

  func testCardInfoForUnsupportedCards() {
    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.generic)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberAccessibilityLabel.assertLastValue("Card ending in 1882")
    self.cardNumberText.assertValue("Card ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
  }

  func testCardInfoForUnknownCardType() {
    let unknownCard = GraphUserCreditCard.generic |> \.type .~ nil

    self.vm.inputs.configureWith(creditCard: unknownCard)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberAccessibilityLabel.assertLastValue("Card ending in 1882")
    self.cardNumberText.assertValue("Card ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
  }
}
