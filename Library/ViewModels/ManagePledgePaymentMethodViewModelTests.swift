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
    self.cardImageName.assertDidNotEmitValue()
    self.cardNumberAccessibilityLabel.assertDidNotEmitValue()
    self.cardNumberTextShortStyle.assertDidNotEmitValue()
    self.expirationDateText.assertDidNotEmitValue()
    self.fixButtonHidden.assertDidNotEmitValue()
    self.notifyDelegateFixButtonTapped.assertDidNotEmitValue()

    let data = ManagePledgePaymentMethodViewData(
      backingState: .pledged,
      expirationDate: "2019-09-30",
      lastFour: "1111",
      creditCardType: .visa,
      paymentType: .creditCard
    )

    self.vm.inputs.configureWith(data: data)

    self.cardImageName.assertValues(["icon--visa"])
    self.cardNumberAccessibilityLabel.assertValues(["Visa, Card ending in 1111"])
    self.cardNumberTextShortStyle.assertValues(["Ending in 1111"])
    self.expirationDateText.assertValues(["Expires 09/2019"])
    self.fixButtonHidden.assertValues([true])
    self.notifyDelegateFixButtonTapped.assertDidNotEmitValue()
  }

  func testApplePay() {
    self.cardImageName.assertDidNotEmitValue()
    self.cardNumberAccessibilityLabel.assertDidNotEmitValue()
    self.cardNumberTextShortStyle.assertDidNotEmitValue()
    self.expirationDateText.assertDidNotEmitValue()
    self.fixButtonHidden.assertDidNotEmitValue()
    self.notifyDelegateFixButtonTapped.assertDidNotEmitValue()

    let data = ManagePledgePaymentMethodViewData(
      backingState: .pledged,
      expirationDate: "2019-10-19",
      lastFour: "1111",
      creditCardType: .visa,
      paymentType: .applePay
    )

    self.vm.inputs.configureWith(data: data)

    self.cardImageName.assertValues(["icon--apple-pay"])
    self.cardNumberAccessibilityLabel.assertValues(["Apple Pay, Visa, Card ending in 1111"])
    self.cardNumberTextShortStyle.assertValues(["Ending in 1111"])
    self.expirationDateText.assertValues(["Expires 10/2019"])
    self.fixButtonHidden.assertValues([true])
    self.notifyDelegateFixButtonTapped.assertDidNotEmitValue()
  }

  func testGooglePay() {
    self.cardImageName.assertDidNotEmitValue()
    self.cardNumberAccessibilityLabel.assertDidNotEmitValue()
    self.cardNumberTextShortStyle.assertDidNotEmitValue()
    self.expirationDateText.assertDidNotEmitValue()
    self.fixButtonHidden.assertDidNotEmitValue()
    self.notifyDelegateFixButtonTapped.assertDidNotEmitValue()

    let data = ManagePledgePaymentMethodViewData(
      backingState: .pledged,
      expirationDate: "2019-10-19",
      lastFour: "4111",
      creditCardType: .visa,
      paymentType: .googlePay
    )

    self.vm.inputs.configureWith(data: data)

    self.cardImageName.assertValues(["icon--google-pay"])
    self.cardNumberAccessibilityLabel.assertValues(["Google Pay, Visa, Card ending in 4111"])
    self.cardNumberTextShortStyle.assertValues(["Ending in 4111"])
    self.expirationDateText.assertValues(["Expires 10/2019"])
    self.fixButtonHidden.assertValues([true])
    self.notifyDelegateFixButtonTapped.assertDidNotEmitValue()
  }

  func testFixButton_IsNotHidden() {
    self.cardImageName.assertDidNotEmitValue()
    self.cardNumberAccessibilityLabel.assertDidNotEmitValue()
    self.cardNumberTextShortStyle.assertDidNotEmitValue()
    self.expirationDateText.assertDidNotEmitValue()
    self.fixButtonHidden.assertDidNotEmitValue()
    self.notifyDelegateFixButtonTapped.assertDidNotEmitValue()

    let data = ManagePledgePaymentMethodViewData(
      backingState: .errored,
      expirationDate: "2019-09-30",
      lastFour: "1111",
      creditCardType: .visa,
      paymentType: .creditCard
    )

    self.vm.inputs.configureWith(data: data)

    self.cardImageName.assertValues(["icon--visa"])
    self.cardNumberAccessibilityLabel.assertValues(["Visa, Card ending in 1111"])
    self.cardNumberTextShortStyle.assertValues(["Ending in 1111"])
    self.expirationDateText.assertValues(["Expires 09/2019"])
    self.fixButtonHidden.assertValues([false])
    self.notifyDelegateFixButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.fixButtonTapped()

    self.cardImageName.assertValues(["icon--visa"])
    self.cardNumberAccessibilityLabel.assertValues(["Visa, Card ending in 1111"])
    self.cardNumberTextShortStyle.assertValues(["Ending in 1111"])
    self.expirationDateText.assertValues(["Expires 09/2019"])
    self.fixButtonHidden.assertValues([false])
    self.notifyDelegateFixButtonTapped.assertValueCount(1)
  }
}
