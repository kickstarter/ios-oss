@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeDescriptionViewModelTests: TestCase {
  private let vm: PledgeDescriptionViewModelType = PledgeDescriptionViewModel()

  private let estimatedDeliveryText = TestObserver<String, Never>()
  private let popViewController = TestObserver<(), Never>()
  private let presentTrustAndSafety = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.estimatedDeliveryText.observe(self.estimatedDeliveryText.observer)
    self.vm.outputs.popViewController.observe(self.popViewController.observer)
    self.vm.outputs.presentTrustAndSafety.observe(self.presentTrustAndSafety.observer)
  }

  func testEstimatedDeliveryDate() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ 1_468_527_587.32843

    self.vm.inputs.configureWith(data: (project, reward))

    self.estimatedDeliveryText.assertValues(["July 2016"], "Emits the estimated delivery date")
  }

  func testPresentTrustAndSafety() {
    self.vm.inputs.learnMoreTapped()

    self.presentTrustAndSafety.assertDidEmitValue()
  }

  func testNotifyDelegateDidTapRewardThumbnail() {
    self.popViewController.assertValueCount(0)

    self.vm.inputs.configureWith(data: (.template, .template))

    self.popViewController.assertValueCount(0)

    self.vm.inputs.rewardCardTapped()

    self.popViewController.assertValueCount(1)
  }
}
