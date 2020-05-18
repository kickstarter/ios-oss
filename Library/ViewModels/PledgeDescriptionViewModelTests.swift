@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeDescriptionViewModelTests: TestCase {
  private let vm: PledgeDescriptionViewModelType = PledgeDescriptionViewModel()

  private let estimatedDeliveryStackViewIsHidden = TestObserver<Bool, Never>()
  private let estimatedDeliveryText = TestObserver<String, Never>()
  private let popViewController = TestObserver<(), Never>()
  private let presentTrustAndSafety = TestObserver<Void, Never>()
  private let rewardTitle = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.estimatedDeliveryStackViewIsHidden.observe(
      self.estimatedDeliveryStackViewIsHidden.observer
    )
    self.vm.outputs.estimatedDeliveryText.observe(self.estimatedDeliveryText.observer)
    self.vm.outputs.popViewController.observe(self.popViewController.observer)
    self.vm.outputs.rewardTitle.observe(self.rewardTitle.observer)
  }

  func testEstimatedDeliveryDate() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ 1_468_527_587.32843

    self.vm.inputs.configureWith(data: (project, reward))

    self.estimatedDeliveryText.assertValues(["July 2016"], "Emits the estimated delivery date")
  }

  func testNotifyDelegateDidTapRewardThumbnail() {
    self.popViewController.assertValueCount(0)

    self.vm.inputs.configureWith(data: (.template, .template))

    self.popViewController.assertValueCount(0)

    self.vm.inputs.rewardCardTapped()

    self.popViewController.assertValueCount(1)
  }

  func testRewardTitle_WithReward() {
    let reward = Reward.template
      |> Reward.lens.title .~ "iPhone 15"

    self.vm.inputs.configureWith(data: (.template, reward))

    self.rewardTitle.assertValue("iPhone 15")
  }

  func testRewardTitle_WithNoReward() {
    self.vm.inputs.configureWith(data: (.template, .noReward))

    self.rewardTitle.assertValue("Back it because you believe in it.")
  }

  func testEstimatedDeliveryStackViewIsHidden_HasEstimatedDelivery() {
    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ 1_468_527_587.32843

    self.vm.inputs.configureWith(data: (.template, reward))

    self.estimatedDeliveryStackViewIsHidden.assertValue(false)
  }

  func testEstimatedDeliveryStackViewIsHidden_NoEstimatedDelivery() {
    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ nil

    self.vm.inputs.configureWith(data: (.template, reward))

    self.estimatedDeliveryStackViewIsHidden.assertValue(true)
  }
}
