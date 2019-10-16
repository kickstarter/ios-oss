@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class PledgeCreditCardViewModelTests: TestCase {
  internal let vm: PledgeCreditCardViewModelType = PledgeCreditCardViewModel()

  private let cardImage = TestObserver<UIImage?, Never>()
  private let cardNumberAccessibilityLabel = TestObserver<String, Never>()
  private let cardNumberTextShortStyle = TestObserver<String, Never>()
  private let disableButton = TestObserver<Bool, Never>()
  private let expirationDateText = TestObserver<String, Never>()
  private let notifyDelegateOfCardSelected = TestObserver<String, Never>()
  private let selectButtonIsSelected = TestObserver<Bool, Never>()
  private let selectButtonTitle = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.cardImage.observe(self.cardImage.observer)
    self.vm.outputs.cardNumberAccessibilityLabel.observe(self.cardNumberAccessibilityLabel.observer)
    self.vm.outputs.cardNumberTextShortStyle.observe(self.cardNumberTextShortStyle.observer)
    self.vm.outputs.disableButton.observe(self.disableButton.observer)
    self.vm.outputs.expirationDateText.observe(self.expirationDateText.observer)
    self.vm.outputs.notifyDelegateOfCardSelected.observe(self.notifyDelegateOfCardSelected.observer)
    self.vm.outputs.selectButtonIsSelected.observe(self.selectButtonIsSelected.observer)
    self.vm.outputs.selectButtonTitle.observe(self.selectButtonTitle.observer)
  }

  func testCardInfoForSupportedCards() {
    self.vm.inputs.configureWith(value: GraphUserCreditCard.amex)

    self.cardImage.assertLastValue(UIImage(named: "icon--amex"))
    self.cardNumberAccessibilityLabel.assertLastValue("Amex, Card ending in 8882")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 8882")
    self.expirationDateText.assertLastValue("Expires 01/2024")
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: GraphUserCreditCard.discover)

    self.cardImage.assertLastValue(UIImage(named: "icon--discover"))
    self.cardNumberAccessibilityLabel.assertLastValue("Discover, Card ending in 4242")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 4242")
    self.expirationDateText.assertLastValue("Expires 03/2022")
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: GraphUserCreditCard.jcb)

    self.cardImage.assertLastValue(UIImage(named: "icon--jcb"))
    self.cardNumberAccessibilityLabel.assertLastValue("Jcb, Card ending in 2222")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 2222")
    self.expirationDateText.assertLastValue("Expires 01/2022")

    self.vm.inputs.configureWith(value: GraphUserCreditCard.masterCard)

    self.cardImage.assertLastValue(UIImage(named: "icon--mastercard"))
    self.cardNumberAccessibilityLabel.assertLastValue("Mastercard, Card ending in 0000")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 0000")
    self.expirationDateText.assertLastValue("Expires 10/2018")
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: GraphUserCreditCard.visa)

    self.cardImage.assertLastValue(UIImage(named: "icon--visa"))
    self.cardNumberAccessibilityLabel.assertLastValue("Visa, Card ending in 1111")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1111")
    self.expirationDateText.assertLastValue("Expires 09/2019")
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: GraphUserCreditCard.diners)

    self.cardImage.assertLastValue(UIImage(named: "icon--diners"))
    self.cardNumberAccessibilityLabel.assertLastValue("Diners, Card ending in 1212")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1212")
    self.expirationDateText.assertLastValue("Expires 09/2022")
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])
  }

  func testNonSelectedCard() {
    self.cardImage.assertValues([])
    self.cardNumberTextShortStyle.assertValues([])
    self.expirationDateText.assertValues([])
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: GraphUserCreditCard.generic)
    self.vm.inputs.setSelectedCard(GraphUserCreditCard.diners)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
    self.selectButtonIsSelected.assertValues([false])
    self.selectButtonTitle.assertValues(["Select"])
  }

  func testSelectedCard() {
    self.cardImage.assertValues([])
    self.cardNumberTextShortStyle.assertValues([])
    self.expirationDateText.assertValues([])
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: GraphUserCreditCard.generic)
    self.vm.inputs.setSelectedCard(GraphUserCreditCard.generic)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
    self.selectButtonIsSelected.assertValues([true])
    self.selectButtonTitle.assertValues(["Selected"])
  }

  func testDisableCard() {
    self.cardImage.assertValues([])
    self.cardNumberTextShortStyle.assertValues([])
    self.expirationDateText.assertValues([])
    self.disableButton.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: GraphUserCreditCard.generic)
    self.vm.inputs.setDisabledCard(false)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
    self.disableButton.assertValues([false])
    self.selectButtonTitle.assertDidNotEmitValue()
  }

  func testCardInfoForUnsupportedCards() {
    self.vm.inputs.configureWith(value: GraphUserCreditCard.generic)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
  }

  func testCardInfoForUnknownCardType() {
    let unknownCard = GraphUserCreditCard.generic |> \.type .~ nil

    self.vm.inputs.configureWith(value: unknownCard)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberAccessibilityLabel.assertLastValue("Card ending in 1882")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
  }

  func testCardConfiguredAsSelected() {
    let card = GraphUserCreditCard.amex
      |> \.id .~ "123"

    self.vm.inputs.configureWith(value: card)

    self.notifyDelegateOfCardSelected.assertDidNotEmitValue()

    self.vm.inputs.setSelectedCard(card)

    self.notifyDelegateOfCardSelected.assertValues(["123"])
  }

  func testSelectButtonTapped() {
    let card = GraphUserCreditCard.amex
      |> \.id .~ "123"

    self.vm.inputs.configureWith(value: card)

    self.notifyDelegateOfCardSelected.assertDidNotEmitValue()

    self.vm.inputs.selectButtonTapped()
    self.notifyDelegateOfCardSelected.assertValues(["123"])
  }
}
