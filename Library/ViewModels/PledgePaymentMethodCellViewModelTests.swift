@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class PledgePaymentMethodCellViewModelTests: TestCase {
  internal let vm: PledgePaymentMethodCellViewModelType = PledgePaymentMethodCellViewModel()

  private let cardImageAlpha = TestObserver<CGFloat, Never>()
  private let cardImageName = TestObserver<String, Never>()
  private let cardNumberAccessibilityLabel = TestObserver<String, Never>()
  private let cardNumberTextShortStyle = TestObserver<String, Never>()
  private let checkmarkImageHidden = TestObserver<Bool, Never>()
  private let checkmarkImageName = TestObserver<String, Never>()
  private let expirationDateText = TestObserver<String, Never>()
  private let lastFourLabelTextColor = TestObserver<UIColor, Never>()
  private let selectionStyle = TestObserver<UITableViewCell.SelectionStyle, Never>()
  private let unavailableCardLabelHidden = TestObserver<Bool, Never>()
  private let unavailableCardText = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.cardImageName.observe(self.cardImageName.observer)
    self.vm.outputs.cardImageAlpha.observe(self.cardImageAlpha.observer)
    self.vm.outputs.cardNumberAccessibilityLabel.observe(self.cardNumberAccessibilityLabel.observer)
    self.vm.outputs.cardNumberTextShortStyle.observe(self.cardNumberTextShortStyle.observer)
    self.vm.outputs.expirationDateText.observe(self.expirationDateText.observer)
    self.vm.outputs.checkmarkImageName.observe(self.checkmarkImageName.observer)
    self.vm.outputs.checkmarkImageHidden.observe(self.checkmarkImageHidden.observer)
    self.vm.outputs.lastFourLabelTextColor.observe(self.lastFourLabelTextColor.observer)
    self.vm.outputs.selectionStyle.observe(self.selectionStyle.observer)
    self.vm.outputs.unavailableCardLabelHidden.observe(self.unavailableCardLabelHidden.observer)
    self.vm.outputs.unavailableCardText.observe(self.unavailableCardText.observer)
  }

  func testCardInfoForSupportedCards() {
    self.cardImageName.assertDidNotEmitValue()
    self.cardNumberAccessibilityLabel.assertDidNotEmitValue()
    self.cardNumberTextShortStyle.assertDidNotEmitValue()
    self.expirationDateText.assertDidNotEmitValue()
    self.cardImageAlpha.assertDidNotEmitValue()
    self.checkmarkImageName.assertDidNotEmitValue()
    self.checkmarkImageHidden.assertDidNotEmitValue()
    self.lastFourLabelTextColor.assertDidNotEmitValue()
    self.selectionStyle.assertDidNotEmitValue()
    self.unavailableCardLabelHidden.assertDidNotEmitValue()
    self.unavailableCardText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.amex, true, false, "Brooklyn, NY", false))

    self.cardImageName.assertLastValue("icon--amex")
    self.cardNumberAccessibilityLabel.assertLastValue("Amex, Card ending in 8882")
    self.cardNumberTextShortStyle.assertLastValue("•••• 8882")
    self.expirationDateText.assertLastValue("Expires 01/2024")
    self.cardImageAlpha.assertLastValue(1.0)
    self.checkmarkImageName.assertLastValue("icon-payment-method-unselected")
    self.checkmarkImageHidden.assertLastValue(false)
    self.lastFourLabelTextColor.assertLastValue(.ksr_soft_black)
    self.selectionStyle.assertLastValue(.default)
    self.unavailableCardLabelHidden.assertLastValue(true)
    self.unavailableCardText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.discover, true, false, "Brooklyn, NY", false))

    self.cardImageName.assertLastValue("icon--discover")
    self.cardNumberAccessibilityLabel.assertLastValue("Discover, Card ending in 4242")
    self.cardNumberTextShortStyle.assertLastValue("•••• 4242")
    self.expirationDateText.assertLastValue("Expires 03/2022")
    self.cardImageAlpha.assertLastValue(1.0)
    self.checkmarkImageName.assertLastValue("icon-payment-method-unselected")
    self.checkmarkImageHidden.assertLastValue(false)
    self.lastFourLabelTextColor.assertLastValue(.ksr_soft_black)
    self.selectionStyle.assertLastValue(.default)
    self.unavailableCardLabelHidden.assertLastValue(true)
    self.unavailableCardText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.jcb, true, false, "Brooklyn, NY", false))

    self.cardImageName.assertLastValue("icon--jcb")
    self.cardNumberAccessibilityLabel.assertLastValue("Jcb, Card ending in 2222")
    self.cardNumberTextShortStyle.assertLastValue("•••• 2222")
    self.expirationDateText.assertLastValue("Expires 01/2022")
    self.cardImageAlpha.assertLastValue(1.0)
    self.checkmarkImageName.assertLastValue("icon-payment-method-unselected")
    self.checkmarkImageHidden.assertLastValue(false)
    self.lastFourLabelTextColor.assertLastValue(.ksr_soft_black)
    self.selectionStyle.assertLastValue(.default)
    self.unavailableCardLabelHidden.assertLastValue(true)
    self.unavailableCardText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.masterCard, true, false, "Brooklyn, NY", false))

    self.cardImageName.assertLastValue("icon--mastercard")
    self.cardNumberAccessibilityLabel.assertLastValue("Mastercard, Card ending in 0000")
    self.cardNumberTextShortStyle.assertLastValue("•••• 0000")
    self.expirationDateText.assertLastValue("Expires 10/2018")
    self.cardImageAlpha.assertLastValue(1.0)
    self.checkmarkImageName.assertLastValue("icon-payment-method-unselected")
    self.checkmarkImageHidden.assertLastValue(false)
    self.lastFourLabelTextColor.assertLastValue(.ksr_soft_black)
    self.selectionStyle.assertLastValue(.default)
    self.unavailableCardLabelHidden.assertLastValue(true)
    self.unavailableCardText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.visa, true, false, "Brooklyn, NY", false))

    self.cardImageName.assertLastValue("icon--visa")
    self.cardNumberAccessibilityLabel.assertLastValue("Visa, Card ending in 1111")
    self.cardNumberTextShortStyle.assertLastValue("•••• 1111")
    self.expirationDateText.assertLastValue("Expires 09/2019")
    self.cardImageAlpha.assertLastValue(1.0)
    self.checkmarkImageName.assertLastValue("icon-payment-method-unselected")
    self.checkmarkImageHidden.assertLastValue(false)
    self.lastFourLabelTextColor.assertLastValue(.ksr_soft_black)
    self.selectionStyle.assertLastValue(.default)
    self.unavailableCardLabelHidden.assertLastValue(true)
    self.unavailableCardText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.diners, true, false, "Brooklyn, NY", false))

    self.cardImageName.assertLastValue("icon--diners")
    self.cardNumberAccessibilityLabel.assertLastValue("Diners, Card ending in 1212")
    self.cardNumberTextShortStyle.assertLastValue("•••• 1212")
    self.expirationDateText.assertLastValue("Expires 09/2022")
    self.cardImageAlpha.assertLastValue(1.0)
    self.checkmarkImageName.assertLastValue("icon-payment-method-unselected")
    self.selectionStyle.assertLastValue(.default)
    self.checkmarkImageHidden.assertLastValue(false)
    self.lastFourLabelTextColor.assertLastValue(.ksr_soft_black)
    self.unavailableCardLabelHidden.assertLastValue(true)
    self.unavailableCardText.assertDidNotEmitValue()
  }

  func testUnselectingCard() {
    self.cardImageName.assertDidNotEmitValue()
    self.cardImageAlpha.assertDidNotEmitValue()
    self.cardNumberAccessibilityLabel.assertDidNotEmitValue()
    self.cardNumberTextShortStyle.assertDidNotEmitValue()
    self.checkmarkImageName.assertDidNotEmitValue()
    self.checkmarkImageHidden.assertDidNotEmitValue()
    self.expirationDateText.assertDidNotEmitValue()
    self.lastFourLabelTextColor.assertDidNotEmitValue()
    self.selectionStyle.assertDidNotEmitValue()
    self.unavailableCardLabelHidden.assertDidNotEmitValue()
    self.unavailableCardText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.generic, true, true, "Brooklyn, NY", false))
    self.vm.inputs.setSelectedCard(GraphUserCreditCard.diners)

    self.cardImageName.assertValues(["icon--generic"])
    self.cardImageAlpha.assertValues([1.0])
    self.cardNumberAccessibilityLabel.assertValues(["Card ending in 1882"])
    self.cardNumberTextShortStyle.assertValues(["•••• 1882"])
    self.checkmarkImageName.assertValues(["icon-payment-method-selected", "icon-payment-method-unselected"])
    self.checkmarkImageHidden.assertValues([false])
    self.expirationDateText.assertValues(["Expires 01/2024"])
    self.lastFourLabelTextColor.assertValues([.ksr_soft_black])
    self.selectionStyle.assertValues([.default])
    self.unavailableCardLabelHidden.assertValues([true])
    self.unavailableCardText.assertValues([])
  }

  func testSelectingCard() {
    self.cardImageName.assertDidNotEmitValue()
    self.cardImageAlpha.assertDidNotEmitValue()
    self.cardNumberAccessibilityLabel.assertDidNotEmitValue()
    self.cardNumberTextShortStyle.assertDidNotEmitValue()
    self.checkmarkImageName.assertDidNotEmitValue()
    self.checkmarkImageHidden.assertDidNotEmitValue()
    self.expirationDateText.assertDidNotEmitValue()
    self.lastFourLabelTextColor.assertDidNotEmitValue()
    self.selectionStyle.assertDidNotEmitValue()
    self.unavailableCardLabelHidden.assertDidNotEmitValue()
    self.unavailableCardText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.generic, true, false, "Brooklyn, NY", false))
    self.vm.inputs.setSelectedCard(GraphUserCreditCard.generic)

    self.cardImageName.assertValues(["icon--generic"])
    self.cardImageAlpha.assertValues([1.0])
    self.cardNumberAccessibilityLabel.assertValues(["Card ending in 1882"])
    self.cardNumberTextShortStyle.assertValues(["•••• 1882"])
    self.checkmarkImageName.assertValues(["icon-payment-method-unselected", "icon-payment-method-selected"])
    self.checkmarkImageHidden.assertValues([false])
    self.expirationDateText.assertValues(["Expires 01/2024"])
    self.lastFourLabelTextColor.assertValues([.ksr_soft_black])
    self.selectionStyle.assertValues([.default])
    self.unavailableCardLabelHidden.assertValues([true])
    self.unavailableCardText.assertValues([])
  }

  func testUnavailableCard() {
    self.cardImageName.assertDidNotEmitValue()
    self.cardImageAlpha.assertDidNotEmitValue()
    self.cardNumberAccessibilityLabel.assertDidNotEmitValue()
    self.cardNumberTextShortStyle.assertDidNotEmitValue()
    self.checkmarkImageName.assertDidNotEmitValue()
    self.checkmarkImageHidden.assertDidNotEmitValue()
    self.expirationDateText.assertDidNotEmitValue()
    self.lastFourLabelTextColor.assertDidNotEmitValue()
    self.selectionStyle.assertDidNotEmitValue()
    self.unavailableCardLabelHidden.assertDidNotEmitValue()
    self.unavailableCardText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (GraphUserCreditCard.generic, false, true, "Brooklyn, NY", false))
    self.vm.inputs.setSelectedCard(GraphUserCreditCard.generic)

    self.cardImageName.assertValues(["icon--generic"])
    self.cardImageAlpha.assertValues([0.5])
    self.cardNumberAccessibilityLabel.assertValues(["Card ending in 1882"])
    self.cardNumberTextShortStyle.assertValues(["•••• 1882"])
    self.checkmarkImageName.assertValues(["icon-payment-method-selected", "icon-payment-method-selected"])
    self.checkmarkImageHidden.assertValues([true])
    self.expirationDateText.assertValues(["Expires 01/2024"])
    self.lastFourLabelTextColor.assertValues([.ksr_dark_grey_500])
    self.selectionStyle.assertValues([.none])
    self.unavailableCardLabelHidden.assertValues([false])
    self.unavailableCardText.assertValues(
      ["You can’t use this credit card to back a project from Brooklyn, NY."]
    )
  }

  func testCardInfoForUnknownCardType() {
    self.cardImageName.assertDidNotEmitValue()
    self.cardImageAlpha.assertDidNotEmitValue()
    self.cardNumberAccessibilityLabel.assertDidNotEmitValue()
    self.cardNumberTextShortStyle.assertDidNotEmitValue()
    self.checkmarkImageName.assertDidNotEmitValue()
    self.checkmarkImageHidden.assertDidNotEmitValue()
    self.expirationDateText.assertDidNotEmitValue()
    self.lastFourLabelTextColor.assertDidNotEmitValue()
    self.selectionStyle.assertDidNotEmitValue()
    self.unavailableCardLabelHidden.assertDidNotEmitValue()
    self.unavailableCardText.assertDidNotEmitValue()

    let unknownCard = GraphUserCreditCard.generic |> \.type .~ nil

    self.vm.inputs.configureWith(value: (unknownCard, true, false, "Brooklyn, NY", false))

    self.cardImageName.assertValues(["icon--generic"])
    self.cardImageAlpha.assertValues([1.0])
    self.cardNumberAccessibilityLabel.assertValues(["Card ending in 1882"])
    self.cardNumberTextShortStyle.assertValues(["•••• 1882"])
    self.checkmarkImageName.assertValues(["icon-payment-method-unselected"])
    self.checkmarkImageHidden.assertValues([false])
    self.expirationDateText.assertValues(["Expires 01/2024"])
    self.lastFourLabelTextColor.assertValues([.ksr_soft_black])
    self.selectionStyle.assertValues([.default])
    self.unavailableCardLabelHidden.assertValues([true])
    self.unavailableCardText.assertValues([])
  }

  func testCardInfoForErroredCard() {
    self.cardImageName.assertDidNotEmitValue()
    self.cardImageAlpha.assertDidNotEmitValue()
    self.cardNumberAccessibilityLabel.assertDidNotEmitValue()
    self.cardNumberTextShortStyle.assertDidNotEmitValue()
    self.checkmarkImageName.assertDidNotEmitValue()
    self.checkmarkImageHidden.assertDidNotEmitValue()
    self.expirationDateText.assertDidNotEmitValue()
    self.lastFourLabelTextColor.assertDidNotEmitValue()
    self.selectionStyle.assertDidNotEmitValue()
    self.unavailableCardLabelHidden.assertDidNotEmitValue()
    self.unavailableCardText.assertDidNotEmitValue()

    let data = PledgePaymentMethodCellData(
      card: GraphUserCreditCard.visa,
      isEnabled: true,
      isSelected: false,
      projectCountry: "Brooklyn, NY",
      isErroredPaymentMethod: true
    )

    self.vm.inputs.configureWith(value: data)

    self.cardImageName.assertValues(["icon--visa"])
    self.cardImageAlpha.assertValues([1.0])
    self.cardNumberAccessibilityLabel.assertValues(["Visa, Card ending in 1111"])
    self.cardNumberTextShortStyle.assertValues(["•••• 1111"])
    self.checkmarkImageName.assertValues(["icon-payment-method-unselected"])
    self.checkmarkImageHidden.assertValues([false])
    self.expirationDateText.assertValues(["Expires 09/2019"])
    self.lastFourLabelTextColor.assertValues([.ksr_soft_black])
    self.selectionStyle.assertValues([.default])
    self.unavailableCardLabelHidden.assertValues([false])
    self.unavailableCardText.assertValues(["Retry or select another method."])
  }
}
