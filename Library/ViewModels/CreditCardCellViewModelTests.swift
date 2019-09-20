@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CreditCardCellViewModelTests: TestCase {
  internal let vm: CreditCardCellViewModelType = CreditCardCellViewModel()

  let cardImage = TestObserver<UIImage?, Never>()
  let cardNumberAccessibilityLabel = TestObserver<String, Never>()
  let cardNumberTextLongStyle = TestObserver<String, Never>()
  let cardNumberTextShortStyle = TestObserver<String, Never>()
  let expirationDateText = TestObserver<String, Never>()
  let newlyAddedCardSelected = TestObserver<Bool, Never>()
  let notifyButtonTapped = TestObserver<Void, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.cardImage.observe(self.cardImage.observer)
    self.vm.outputs.cardNumberAccessibilityLabel.observe(self.cardNumberAccessibilityLabel.observer)
    self.vm.outputs.cardNumberTextLongStyle.observe(self.cardNumberTextLongStyle.observer)
    self.vm.outputs.cardNumberTextShortStyle.observe(self.cardNumberTextShortStyle.observer)
    self.vm.outputs.expirationDateText.observe(self.expirationDateText.observer)
    self.vm.outputs.newlyAddedCardSelected.observe(self.newlyAddedCardSelected.observer)
    self.vm.outputs.notifyButtonTapped.observe(self.notifyButtonTapped.observer)
  }

  func testCardInfoForSupportedCards() {
    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.amex, isNew: false)

    self.cardImage.assertLastValue(UIImage(named: "icon--amex"))
    self.cardNumberAccessibilityLabel.assertLastValue("Amex, Card ending in 8882")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 8882")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 8882")
    self.expirationDateText.assertLastValue("Expires 01/2024")
    self.newlyAddedCardSelected.assertValues([false])

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.discover, isNew: false)

    self.cardImage.assertLastValue(UIImage(named: "icon--discover"))
    self.cardNumberAccessibilityLabel.assertLastValue("Discover, Card ending in 4242")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 4242")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 4242")
    self.expirationDateText.assertLastValue("Expires 03/2022")
    self.newlyAddedCardSelected.assertValues([false, false])

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.jcb, isNew: false)

    self.cardImage.assertLastValue(UIImage(named: "icon--jcb"))
    self.cardNumberAccessibilityLabel.assertLastValue("Jcb, Card ending in 2222")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 2222")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 2222")
    self.expirationDateText.assertLastValue("Expires 01/2022")
    self.newlyAddedCardSelected.assertValues([false, false, false])

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.masterCard, isNew: false)

    self.cardImage.assertLastValue(UIImage(named: "icon--mastercard"))
    self.cardNumberAccessibilityLabel.assertLastValue("Mastercard, Card ending in 0000")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 0000")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 0000")
    self.expirationDateText.assertLastValue("Expires 10/2018")
    self.newlyAddedCardSelected.assertValues([false, false, false, false])

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.visa, isNew: false)

    self.cardImage.assertLastValue(UIImage(named: "icon--visa"))
    self.cardNumberAccessibilityLabel.assertLastValue("Visa, Card ending in 1111")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 1111")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1111")
    self.expirationDateText.assertLastValue("Expires 09/2019")
    self.newlyAddedCardSelected.assertValues([false, false, false, false, false])

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.diners, isNew: false)

    self.cardImage.assertLastValue(UIImage(named: "icon--diners"))
    self.cardNumberAccessibilityLabel.assertLastValue("Diners, Card ending in 1212")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 1212")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1212")
    self.expirationDateText.assertLastValue("Expires 09/2022")
    self.newlyAddedCardSelected.assertValues([false, false, false, false, false, false])
  }

  func testNotifyButtonSelected() {
    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.amex, isNew: false)
    self.notifyButtonTapped.assertDidNotEmitValue()

    self.cardImage.assertLastValue(UIImage(named: "icon--amex"))
    self.cardNumberAccessibilityLabel.assertLastValue("Amex, Card ending in 8882")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 8882")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 8882")
    self.expirationDateText.assertLastValue("Expires 01/2024")
    self.newlyAddedCardSelected.assertValues([false])

    self.vm.inputs.selectButtonTapped()
    self.notifyButtonTapped.assertValueCount(1)
  }

  func testSelectedCard() {
    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.generic, isNew: true)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 1882")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
    self.newlyAddedCardSelected.assertValues([true])
  }

  func testCardInfoForUnsupportedCards() {
    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.generic, isNew: false)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 1882")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
    self.newlyAddedCardSelected.assertValues([false])
  }

  func testCardInfoForUnknownCardType() {
    let unknownCard = GraphUserCreditCard.generic |> \.type .~ nil

    self.vm.inputs.configureWith(creditCard: unknownCard, isNew: false)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberAccessibilityLabel.assertLastValue("Card ending in 1882")
    self.cardNumberTextLongStyle.assertLastValue("Card ending in 1882")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
    self.newlyAddedCardSelected.assertValues([false])
  }
}
