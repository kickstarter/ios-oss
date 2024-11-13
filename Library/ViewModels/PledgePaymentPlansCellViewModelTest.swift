import Foundation
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgePaymentPlansCellViewModelTest: TestCase {
  // MARK: Properties

  private var vm: PledgePaymentPlansCellViewModelType = PledgePaymentPlansCellViewModel()

  private var checkmarkImageName = TestObserver<String, Never>()

  // MARK: Liifecycle

  override func setUp() {
    super.setUp()

    self.vm.outputs.checkmarkImageName.observe(self.checkmarkImageName.observer)
  }

  // MARK: Test cases

  func testPaymentPlanCell_CheckedImageName() {
    self.vm.inputs.configureWith(value: true)

    self.checkmarkImageName.assertValue("icon-payment-method-selected")
  }

  func testPaymentPlanCell_UnCheckedImageName() {
    self.vm.inputs.configureWith(value: false)

    self.checkmarkImageName.assertValue("icon-payment-method-unselected")
  }
}
