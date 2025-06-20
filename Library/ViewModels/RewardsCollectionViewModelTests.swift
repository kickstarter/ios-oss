import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class RewardsCollectionViewModelTests: TestCase {
  private let reloadDataWithValues = TestObserver<[Reward], Never>()
  private let scrollToRewardIndex = TestObserver<Int, Never>()

  private let vm = RewardsCollectionViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadDataWithValues.map { $0.map { $0.reward } }
      .observe(self.reloadDataWithValues.observer)

    self.vm.outputs.scrollToRewardIndexPath.map { $0.row }.observe(self.scrollToRewardIndex.observer)
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

    self.vm.configure(with: testProject, refTag: nil, context: .createPledge, secretRewardToken: "34342")
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

  func test_scrollsToFirstSecretReward_whenSecretRewardTokenIsProvided() {
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

    self.vm.configure(with: testProject, refTag: nil, context: .createPledge, secretRewardToken: "34342")
    self.vm.shippingRuleSelected(nil)
    self.vm.viewDidLoad()
    self.vm.viewDidLayoutSubviews()

    let rewardsOrdered = [
      Reward.noReward,
      Reward.secretRewardTemplate,
      availableReward,
      notAvailableReward
    ]

    self.reloadDataWithValues.assertValues([rewardsOrdered])
    self.scrollToRewardIndex.assertValues([1])
  }

  func test_autoscrollsToBackedReward_whenProjectIsBacked() {
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

    let backing = Backing.template
      |> Backing.lens.amount .~ 22
      |> Backing.lens.reward .~ availableReward
      |> Backing.lens.rewardId .~ availableReward.id
      |> Backing.lens.paymentSource .~ Backing.PaymentSource.template

    let testProject = Project.template
      |> Project.lens.rewardData.rewards .~ rewards
      |> Project.lens.personalization.backing .~ backing

    self.vm.configure(with: testProject, refTag: nil, context: .createPledge, secretRewardToken: nil)
    self.vm.shippingRuleSelected(nil)
    self.vm.viewDidLoad()
    self.vm.viewDidLayoutSubviews()

    let rewardsOrdered = [
      Reward.noReward,
      Reward.secretRewardTemplate,
      availableReward,
      notAvailableReward
    ]

    self.reloadDataWithValues.assertValues([rewardsOrdered])
    self.scrollToRewardIndex.assertValues([2])
  }

  func test_doesNotScroll_whenNoBackedRewardAndNoSecretRewardToken() {
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

    self.vm.configure(with: testProject, refTag: nil, context: .createPledge, secretRewardToken: nil)
    self.vm.shippingRuleSelected(nil)
    self.vm.viewDidLoad()
    self.vm.viewDidLayoutSubviews()

    self.scrollToRewardIndex.assertDidNotEmitValue()
  }
}
