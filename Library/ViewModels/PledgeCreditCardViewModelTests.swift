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
  private let expirationDateText = TestObserver<String, Never>()
  private let notifyDelegateOfCardSelected = TestObserver<String, Never>()
  private let selectButtonEnabled = TestObserver<Bool, Never>()
  private let selectButtonIsSelected = TestObserver<Bool, Never>()
  private let selectButtonTitle = TestObserver<String, Never>()
  private let spacerIsHidden = TestObserver<Bool, Never>()
  private let unavailableCardLabelHidden = TestObserver<Bool, Never>()
  private let unavailableCardText = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.cardImage.observe(self.cardImage.observer)
    self.vm.outputs.cardNumberAccessibilityLabel.observe(self.cardNumberAccessibilityLabel.observer)
    self.vm.outputs.cardNumberTextShortStyle.observe(self.cardNumberTextShortStyle.observer)
    self.vm.outputs.expirationDateText.observe(self.expirationDateText.observer)
    self.vm.outputs.notifyDelegateOfCardSelected.observe(self.notifyDelegateOfCardSelected.observer)
    self.vm.outputs.selectButtonEnabled.observe(self.selectButtonEnabled.observer)
    self.vm.outputs.selectButtonIsSelected.observe(self.selectButtonIsSelected.observer)
    self.vm.outputs.selectButtonTitle.observe(self.selectButtonTitle.observer)
    self.vm.outputs.spacerIsHidden.observe(self.spacerIsHidden.observer)
    self.vm.outputs.unavailableCardLabelHidden.observe(self.unavailableCardLabelHidden.observer)
    self.vm.outputs.unavailableCardText.observe(self.unavailableCardText.observer)
  }

  func testCardInfoForSupportedCards() {
    self.vm.inputs.configureWith(value: (GraphUserCreditCard.amex, true, "Brooklyn, NY"))

    self.cardImage.assertLastValue(UIImage(named: "icon--amex"))
    self.cardNumberAccessibilityLabel.assertLastValue("Amex, Card ending in 8882")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 8882")
    self.expirationDateText.assertLastValue("Expires 01/2024")
    self.selectButtonEnabled.assertValues([true])
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.discover, true, "Brooklyn, NY"))

    self.cardImage.assertLastValue(UIImage(named: "icon--discover"))
    self.cardNumberAccessibilityLabel.assertLastValue("Discover, Card ending in 4242")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 4242")
    self.expirationDateText.assertLastValue("Expires 03/2022")
    self.selectButtonEnabled.assertValues([true, true])
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.jcb, true, "Brooklyn, NY"))

    self.cardImage.assertLastValue(UIImage(named: "icon--jcb"))
    self.cardNumberAccessibilityLabel.assertLastValue("Jcb, Card ending in 2222")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 2222")
    self.expirationDateText.assertLastValue("Expires 01/2022")

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.masterCard, true, "Brooklyn, NY"))

    self.cardImage.assertLastValue(UIImage(named: "icon--mastercard"))
    self.cardNumberAccessibilityLabel.assertLastValue("Mastercard, Card ending in 0000")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 0000")
    self.expirationDateText.assertLastValue("Expires 10/2018")
    self.selectButtonEnabled.assertValues([true, true, true, true])
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.visa, true, "Brooklyn, NY"))

    self.cardImage.assertLastValue(UIImage(named: "icon--visa"))
    self.cardNumberAccessibilityLabel.assertLastValue("Visa, Card ending in 1111")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1111")
    self.expirationDateText.assertLastValue("Expires 09/2019")
    self.selectButtonEnabled.assertValues([true, true, true, true, true])
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.diners, true, "Brooklyn, NY"))

    self.cardImage.assertLastValue(UIImage(named: "icon--diners"))
    self.cardNumberAccessibilityLabel.assertLastValue("Diners, Card ending in 1212")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1212")
    self.expirationDateText.assertLastValue("Expires 09/2022")
    self.selectButtonEnabled.assertValues([true, true, true, true, true, true])
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])
  }

  func testNonSelectedCard() {
    self.cardImage.assertValues([])
    self.cardNumberTextShortStyle.assertValues([])
    self.expirationDateText.assertValues([])
    self.selectButtonEnabled.assertValues([])
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.generic, true, "Brooklyn, NY"))
    self.vm.inputs.setSelectedCard(GraphUserCreditCard.diners)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
    self.selectButtonEnabled.assertValues([true])
    self.selectButtonIsSelected.assertValues([false])
    self.selectButtonTitle.assertValues(["Select"])
  }

  func testSelectedCard() {
    self.cardImage.assertValues([])
    self.cardNumberTextShortStyle.assertValues([])
    self.expirationDateText.assertValues([])
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.generic, true, "Brooklyn, NY"))
    self.vm.inputs.setSelectedCard(GraphUserCreditCard.generic)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
    self.selectButtonIsSelected.assertValues([true])
    self.selectButtonTitle.assertValues(["Selected"])
  }

  func testCardIsSelectedAndDisabled() {
    self.cardImage.assertValues([])
    self.cardNumberTextShortStyle.assertValues([])
    self.expirationDateText.assertValues([])
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])
    self.selectButtonEnabled.assertValues([])

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.generic, false, "Brooklyn, NY"))
    self.vm.inputs.setSelectedCard(GraphUserCreditCard.generic)

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
    self.selectButtonIsSelected.assertValues([false])
    self.selectButtonTitle.assertDidNotEmitValue()
    self.selectButtonEnabled.assertValues([false])
  }

  func testUnavailableCard() {
    self.cardImage.assertValues([])
    self.cardNumberTextShortStyle.assertValues([])
    self.expirationDateText.assertValues([])
    self.selectButtonIsSelected.assertValues([])
    self.selectButtonTitle.assertValues([])
    self.selectButtonEnabled.assertValues([])
    self.unavailableCardText.assertValues([])
    self.unavailableCardLabelHidden.assertValues([])
    self.spacerIsHidden.assertValues([])

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.generic, false, "Brooklyn, NY"))

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
    self.selectButtonIsSelected.assertDidNotEmitValue()
    self.selectButtonTitle.assertDidNotEmitValue()
    self.selectButtonEnabled.assertValues([false])
    self.unavailableCardText.assertValues(
      ["You can’t use this credit card to back a project from Brooklyn, NY."])
    self.unavailableCardLabelHidden.assertValues([false])
    self.spacerIsHidden.assertValues([true])
  }

  func testSpacerIsHidden() {
    self.cardImage.assertValues([])
    self.cardNumberTextShortStyle.assertValues([])
    self.expirationDateText.assertValues([])
    self.selectButtonTitle.assertValues([])
    self.selectButtonEnabled.assertValues([])
    self.spacerIsHidden.assertValues([])

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.generic, false, "Brooklyn, NY"))

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
    self.selectButtonTitle.assertDidNotEmitValue()
    self.selectButtonEnabled.assertValues([false])
    self.spacerIsHidden.assertValues([true])
  }

  func testCardInfoForUnsupportedCards() {
    self.vm.inputs.configureWith(value: (GraphUserCreditCard.generic, true, "Brooklyn, NY"))

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
  }

  func testCardInfoForUnknownCardType() {
    let unknownCard = GraphUserCreditCard.generic |> \.type .~ nil

    self.vm.inputs.configureWith(value: (unknownCard, true, "Brooklyn, NY"))

    self.cardImage.assertValue(UIImage(named: "icon--generic"))
    self.cardNumberAccessibilityLabel.assertLastValue("Card ending in 1882")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1882")
    self.expirationDateText.assertValue("Expires 01/2024")
  }

  func testCardConfiguredAsSelected() {
    let card = GraphUserCreditCard.amex
      |> \.id .~ "123"

    self.vm.inputs.configureWith(value: (card, true, "Brooklyn, NY"))

    self.notifyDelegateOfCardSelected.assertDidNotEmitValue()

    self.vm.inputs.setSelectedCard(card)

    self.notifyDelegateOfCardSelected.assertValues(["123"])
  }

  func testSelectButtonTapped() {
    let card = GraphUserCreditCard.amex
      |> \.id .~ "123"

    self.vm.inputs.configureWith(value: (card, true, "Brooklyn, NY"))

    self.notifyDelegateOfCardSelected.assertDidNotEmitValue()

    self.vm.inputs.selectButtonTapped()
    self.notifyDelegateOfCardSelected.assertValues(["123"])
  }
}
