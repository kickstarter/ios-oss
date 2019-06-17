@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeDescriptionCellViewModelTests: TestCase {
  private let vm: PledgeDescriptionCellViewModelType = PledgeDescriptionCellViewModel()

  private let estimatedDeliveryText = TestObserver<String, Never>()
  private let presentTrustAndSafety = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.estimatedDeliveryText.observe(self.estimatedDeliveryText.observer)
    self.vm.outputs.presentTrustAndSafety.observe(self.presentTrustAndSafety.observer)
  }

  func testEstimatedDeliveryDate() {
    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ 1_468_527_587.32843

    self.vm.inputs.configureWith(reward: reward)

    self.estimatedDeliveryText.assertValues(["July 2016"], "Emits the estimated delivery date")
  }

  func testPresentTrustAndSafety() {
    self.vm.inputs.learnMoreTapped()

    self.presentTrustAndSafety.assertDidEmitValue()
  }
}
