import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class RewardsCollectionViewModelTests: TestCase {
  private let reloadDataWithValues = TestObserver<[Reward], Never>()

  private let vm = RewardsCollectionViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadDataWithValues.map { $0.map { $0.reward } }
      .observe(self.reloadDataWithValues.observer)
  }

  func testRewardsOrdered() {
    let availableReward = Reward.template
      |> Reward.lens.isAvailable .~ true
    let notAvailableReward = Reward.template
      |> Reward.lens.isAvailable .~ false

    let rewards = [
      availableReward,
      Reward.noReward,
      notAvailableReward,
      Reward.secretRewardTemplate
    ]

    let testProject = Project.template
      |> Project.lens.rewardData.rewards .~ rewards

    self.vm.configure(with: testProject, refTag: nil, context: .createPledge)
    self.vm.shippingRuleSelected(nil)
    self.vm.viewDidLoad()

    let rewardsOrdered = [
      Reward.noReward,
      Reward.secretRewardTemplate,
      availableReward,
      notAvailableReward
    ]

    self.reloadDataWithValues.assertValues([rewardsOrdered])
  }
}
