@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ManagePledgePaymentMethodViewModelTests: TestCase {
  internal let vm: ManagePledgePaymentMethodViewModelType = ManagePledgePaymentMethodViewModel()

  private let cardImage = TestObserver<String, Never>()
  private let cardNumberAccessibilityLabel = TestObserver<String, Never>()
  private let cardNumberTextShortStyle = TestObserver<String, Never>()
  private let expirationDateText = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.cardImage.observe(self.cardImage.observer)
    self.vm.outputs.cardNumberAccessibilityLabel.observe(self.cardNumberAccessibilityLabel.observer)
    self.vm.outputs.cardNumberTextShortStyle.observe(self.cardNumberTextShortStyle.observer)
    self.vm.outputs.expirationDateText.observe(self.expirationDateText.observer)
  }

  func testPaymentSourceInfo() {
    self.vm.inputs.configureWith(value: Backing.PaymentSource.template)

    self.cardImage.assertLastValue("icon--visa")
    self.cardNumberAccessibilityLabel.assertLastValue("Visa, Card ending in 1111")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1111")
    self.expirationDateText.assertLastValue("Expires 09/2019")
  }

  func testApplePay() {
    self.vm.inputs.configureWith(value: Backing.PaymentSource.applePay)

    self.cardImage.assertValue("icon--apple-pay")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1111")
    self.expirationDateText.assertValue("Expires 10/2019")
  }
}
