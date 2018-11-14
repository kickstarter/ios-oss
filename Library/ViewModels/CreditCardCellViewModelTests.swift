import XCTest
import Result
import ReactiveSwift
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class CreditCardCellViewModelTests: TestCase {

  internal let vm: CreditCardCellViewModelType = CreditCardCellViewModel()

  let cardImage = TestObserver<UIImage?, NoError>()
  let cardNumberText = TestObserver<String, NoError>()
  let expirationDateText = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.cardImage.observe(cardImage.observer)
    self.vm.outputs.cardNumberText.observe(cardNumberText.observer)
    self.vm.outputs.expirationDateText.observe(expirationDateText.observer)

  }

  func testCardInfo() {

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.amex)
    self.cardImage.assertValue(UIImage(named: "icon--amex"))

    self.expirationDateText.assertValue("Expires 01/2024")

    self.cardNumberText.assertValue("Card ending in 8882")
  }

  func testCardImage_ReturnsGenericImage_IfCardHasInvalidType() {

    self.vm.inputs.configureWith(creditCard: GraphUserCreditCard.generic)
    self.cardImage.assertValue(UIImage(named: "icon--generic"))
  }
}
