@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ManagePledgePaymentMethodViewModelTests: TestCase {
  internal let vm: ManagePledgePaymentMethodViewModelType = ManagePledgePaymentMethodViewModel()

  private let cardImageName = TestObserver<String, Never>()
  private let cardNumberAccessibilityLabel = TestObserver<String, Never>()
  private let cardNumberTextShortStyle = TestObserver<String, Never>()
  private let expirationDateText = TestObserver<String, Never>()
  private let fixButtonHidden = TestObserver<Bool, Never>()
  private let notifyDelegateFixButtonTapped = TestObserver<Void, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.cardImageName.observe(self.cardImageName.observer)
    self.vm.outputs.cardNumberAccessibilityLabel.observe(self.cardNumberAccessibilityLabel.observer)
    self.vm.outputs.cardNumberTextShortStyle.observe(self.cardNumberTextShortStyle.observer)
    self.vm.outputs.expirationDateText.observe(self.expirationDateText.observer)
    self.vm.outputs.fixButtonHidden.observe(self.fixButtonHidden.observer)
    self.vm.outputs.notifyDelegateFixButtonTapped.observe(self.notifyDelegateFixButtonTapped.observer)
  }

  func testPaymentSourceInfo() {
    self.vm.inputs.configureWith(value: Backing.template)

    self.cardImageName.assertLastValue("icon--visa")
    self.cardNumberAccessibilityLabel.assertLastValue("Visa, Card ending in 1111")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1111")
    self.expirationDateText.assertLastValue("Expires 09/2019")
  }

  func testApplePay() {
    let backing = Backing.template
      |> Backing.lens.paymentSource .~ Backing.PaymentSource.applePay

    self.vm.inputs.configureWith(value: backing)

    self.cardImageName.assertValue("icon--apple-pay")
    self.cardNumberAccessibilityLabel.assertLastValue("Apple Pay, Visa, Card ending in 1111")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 1111")
    self.expirationDateText.assertValue("Expires 10/2019")
  }

  func testGooglePay() {
    let backing = Backing.template
      |> Backing.lens.paymentSource .~ Backing.PaymentSource.googlePay

    self.vm.inputs.configureWith(value: backing)

    self.cardImageName.assertValue("icon--google-pay")
    self.cardNumberAccessibilityLabel.assertLastValue("Google Pay, Visa, Card ending in 4111")
    self.cardNumberTextShortStyle.assertLastValue("Ending in 4111")
    self.expirationDateText.assertValue("Expires 10/2019")
  }

  func testFixButton_IsNotHidden() {
    let backing = Backing.template |> Backing.lens.status .~ .errored

    self.vm.inputs.configureWith(value: backing)

    self.fixButtonHidden.assertValues([false])
  }

  func testFixButton_IsHidden() {
    self.vm.inputs.configureWith(value: Backing.template)

    self.fixButtonHidden.assertValues([true])
  }

  func testFixButtonTapped() {
    let backing = Backing.template |> Backing.lens.status .~ .errored

    self.vm.inputs.configureWith(value: backing)

    self.fixButtonHidden.assertValues([false])

    self.notifyDelegateFixButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.fixButtonTapped()

    self.notifyDelegateFixButtonTapped.assertDidEmitValue()
  }
}
