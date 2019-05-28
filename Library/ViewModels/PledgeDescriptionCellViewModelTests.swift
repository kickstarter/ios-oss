@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import Result
import XCTest

internal final class PledgeDescriptionCellViewModelTests: TestCase {
  private let vm: PledgeDescriptionCellViewModelType = PledgeDescriptionCellViewModel()

  private let estimatedDeliveryText = TestObserver<String, NoError>()
  private let presentTrustAndSafety = TestObserver<Void, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.estimatedDeliveryText.observe(self.estimatedDeliveryText.observer)
    self.vm.outputs.presentTrustAndSafety.observe(self.presentTrustAndSafety.observer)
  }

  func testEstimatedDeliveryDate() {
    let estimatedDelivery = 1_468_527_587.32843

    let date = Format.date(secondsInUTC: estimatedDelivery, template: "MMMMyyyy", timeZone: UTCTimeZone)

    self.vm.inputs.configureWith(estimatedDeliveryDate: date)
    self.estimatedDeliveryText.assertValues(["July 2016"], "Emits the estimated delivery date")
  }

  func testPresentTrustAndSafety() {
    self.vm.inputs.learnMoreTapped()
    self.presentTrustAndSafety.assertDidEmitValue()
  }
}
