import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class RewardsCollectionViewModelTests: TestCase {
  private let reloadDataWithValues = TestObserver<[Reward], Never>()
  private let scrollToRewardIndex = TestObserver<Int, Never>()
  private let goToCustomizeYourReward = TestObserver<PledgeViewData, Never>()
  private let shippingLocationViewHidden = TestObserver<Bool, Never>()

  private let vm = RewardsCollectionViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadDataWithValues.map { $0.map { $0.reward } }
      .observe(self.reloadDataWithValues.observer)

    self.vm.outputs.scrollToRewardIndexPath.map { $0.row }.observe(self.scrollToRewardIndex.observer)

    self.vm.outputs.goToCustomizeYourReward.observe(self.goToCustomizeYourReward.observer)

    self.vm.outputs.shippingLocationViewHidden.observe(self.shippingLocationViewHidden.observer)
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
    self.vm.shippingLocationSelected(nil)
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
    self.vm.shippingLocationSelected(nil)
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
    self.vm.shippingLocationSelected(nil)
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
    self.vm.shippingLocationSelected(nil)
    self.vm.viewDidLoad()
    self.vm.viewDidLayoutSubviews()

    self.scrollToRewardIndex.assertDidNotEmitValue()
  }

  func test_selectLocation_outputsShippingRule_forRewardWithShipping() {
    let location1 = Location(
      country: "Country 1",
      displayableName: "Country 1",
      id: 1,
      localizedName: "Country 1",
      name: "Country 1"
    )
    let location2 = Location(
      country: "Country 2",
      displayableName: "Country 2",
      id: 2,
      localizedName: "Country 2",
      name: "Country 2"
    )

    let shippingRule1 = ShippingRule(
      cost: 10,
      id: 1,
      location: location1,
      estimatedMin: nil,
      estimatedMax: nil
    )
    let shippingRule2 = ShippingRule(
      cost: 72,
      id: 2,
      location: location2,
      estimatedMin: nil,
      estimatedMax: nil
    )

    let reward = Reward.template
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule1, shippingRule2]
      |> Reward.lens.shipping .~ Reward.Shipping(
        enabled: true,
        location: nil,
        preference: .restricted,
        summary: "Restricted shipping",
        type: .multipleLocations
      )

    let rewards = [
      reward
    ]

    let testProject = Project.template
      |> Project.lens.rewardData.rewards .~ rewards

    self.vm.configure(with: testProject, refTag: nil, context: .createPledge, secretRewardToken: nil)
    self.vm.inputs.shippingLocationSelected(nil)
    self.vm.viewDidLoad()
    self.vm.viewDidLayoutSubviews()

    self.shippingLocationViewHidden.assertLastValue(true)

    self.vm.inputs.shippingLocationSelected(location2)
    self.vm.inputs.rewardSelected(with: reward.id)

    self.goToCustomizeYourReward.assertDidEmitValue()

    if let pledgeData = self.goToCustomizeYourReward.lastValue {
      XCTAssertEqual(
        pledgeData.selectedShippingRule,
        shippingRule2,
        "Pledge data should include shipping rule for location 2"
      )
    }
  }

  func test_selectLocation_outputsNilShippingRule_forRewardWithoutShipping() {
    let location1 = Location(
      country: "Country 1",
      displayableName: "Country 1",
      id: 1,
      localizedName: "Country 1",
      name: "Country 1"
    )

    let reward = Reward.template
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.shippingRulesExpanded .~ []
      |> Reward.lens.shipping .~ Reward.Shipping(
        enabled: true,
        location: nil,
        preference: Reward.Shipping.Preference.none,
        summary: "Digital reward",
        type: .noShipping
      )

    let rewards = [
      reward
    ]

    let testProject = Project.template
      |> Project.lens.rewardData.rewards .~ rewards

    self.vm.configure(with: testProject, refTag: nil, context: .createPledge, secretRewardToken: nil)
    self.vm.inputs.shippingLocationSelected(nil)
    self.vm.viewDidLoad()
    self.vm.viewDidLayoutSubviews()

    self.shippingLocationViewHidden.assertLastValue(true)

    self.vm.inputs.shippingLocationSelected(location1)
    self.vm.inputs.rewardSelected(with: reward.id)

    self.goToCustomizeYourReward.assertDidEmitValue()

    if let pledgeData = self.goToCustomizeYourReward.lastValue {
      XCTAssertEqual(
        pledgeData.selectedShippingRule,
        nil,
        "Pledge data should have no shipping rule, because the reward is digital"
      )
    }
  }

  func test_selectLocation_outputsNilShippingRule_forProjectWithNoShippableRewards() {
    let noReward = Reward.noReward
    let digitalReward = Reward.template
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.shippingRulesExpanded .~ []
      |> Reward.lens.shipping .~ Reward.Shipping(
        enabled: true,
        location: nil,
        preference: Reward.Shipping.Preference.none,
        summary: "Digital reward",
        type: .noShipping
      )

    let localShippingReward = Reward.template
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.shippingRulesExpanded .~ []
      |> Reward.lens.shipping .~ Reward.Shipping(
        enabled: true,
        location: Reward.Shipping.Location(
          id: 1,
          localizedName: "Pickup your stuff"
        ),
        preference: Reward.Shipping.Preference.local,
        summary: "Digital reward",
        type: .noShipping
      )

    let rewards = [
      noReward,
      digitalReward,
      localShippingReward
    ]

    let testProject = Project.template
      |> Project.lens.rewardData.rewards .~ rewards

    self.vm.configure(with: testProject, refTag: nil, context: .createPledge, secretRewardToken: nil)
    self.vm.inputs.shippingLocationSelected(nil)
    self.vm.viewDidLoad()
    self.vm.viewDidLayoutSubviews()

    // Because the shipping location is powered by the available shipping rules,
    // if there are no shippable rewards, the location element may be hidden and output `nil` once.
    self.shippingLocationViewHidden.assertLastValue(false)

    self.vm.inputs.rewardSelected(with: digitalReward.id)

    self.goToCustomizeYourReward.assertDidEmitValue()

    if let pledgeData = self.goToCustomizeYourReward.lastValue {
      XCTAssertEqual(
        pledgeData.selectedShippingRule,
        nil,
        "Pledge data should have no shipping rule, because the reward is digital"
      )
    }
  }
}
