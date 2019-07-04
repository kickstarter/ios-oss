@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeDescriptionCellViewModelTests: TestCase {
  private let vm: PledgeDescriptionCellViewModelType = PledgeDescriptionCellViewModel()

  private let configureRewardCardViewWithDataProject = TestObserver<Project, Never>()
  private let configureRewardCardViewWithDataReward = TestObserver<Either<Reward, Backing>, Never>()
  private let estimatedDeliveryText = TestObserver<String, Never>()
  private let presentTrustAndSafety = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureRewardCardViewWithData.map(first)
      .observe(self.configureRewardCardViewWithDataProject.observer)
    self.vm.outputs.configureRewardCardViewWithData.map(second)
      .observe(self.configureRewardCardViewWithDataReward.observer)
    self.vm.outputs.estimatedDeliveryText.observe(self.estimatedDeliveryText.observer)
    self.vm.outputs.presentTrustAndSafety.observe(self.presentTrustAndSafety.observer)
  }

  func testEstimatedDeliveryDate() {
    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ 1_468_527_587.32843

    self.vm.inputs.configure(with: (.template, reward))

    self.estimatedDeliveryText.assertValues(["July 2016"], "Emits the estimated delivery date")
  }

  func testPresentTrustAndSafety() {
    self.vm.inputs.learnMoreTapped()

    self.presentTrustAndSafety.assertDidEmitValue()
  }

  func testConfigureRewardCardViewWithData() {
    self.configureRewardCardViewWithDataProject.assertValues([])
    self.configureRewardCardViewWithDataReward.assertValueCount(0)

    let project = Project.template
    let reward = Reward.template

    self.vm.inputs.configure(with: (.template, .template))

    self.configureRewardCardViewWithDataProject.assertValues([project])
    XCTAssertEqual(self.configureRewardCardViewWithDataReward.values.last?.left, reward)
    self.configureRewardCardViewWithDataReward.assertValueCount(1)
  }
}
