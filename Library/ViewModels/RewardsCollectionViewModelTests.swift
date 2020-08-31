@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardsCollectionViewModelTests: TestCase {
  private let vm: RewardsCollectionViewModelType = RewardsCollectionViewModel()

  private let configureRewardsCollectionViewFooterWithCount = TestObserver<Int, Never>()
  private let flashScrollIndicators = TestObserver<Void, Never>()
  private let goToAddOnSelection = TestObserver<PledgeViewData, Never>()
  private let goToPledge = TestObserver<PledgeViewData, Never>()
  private let navigationBarShadowImageHidden = TestObserver<Bool, Never>()
  private let reloadDataWithValues = TestObserver<[RewardCardViewData], Never>()
  private let reloadDataWithValuesProject = TestObserver<[Project], Never>()
  private let reloadDataWithValuesRewardOrBacking = TestObserver<[Reward], Never>()
  private let rewardsCollectionViewFooterIsHidden = TestObserver<Bool, Never>()
  private let scrollToBackedRewardIndexPath = TestObserver<IndexPath, Never>()
  private let showEditRewardConfirmationPrompt = TestObserver<String, Never>()
  private let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureRewardsCollectionViewFooterWithCount
      .observe(self.configureRewardsCollectionViewFooterWithCount.observer)
    self.vm.outputs.flashScrollIndicators.observe(self.flashScrollIndicators.observer)
    self.vm.outputs.goToAddOnSelection.observe(self.goToAddOnSelection.observer)
    self.vm.outputs.goToPledge.observe(self.goToPledge.observer)
    self.vm.outputs.navigationBarShadowImageHidden.observe(self.navigationBarShadowImageHidden.observer)
    self.vm.outputs.reloadDataWithValues.observe(self.reloadDataWithValues.observer)
    self.vm.outputs.reloadDataWithValues.map { $0.map { $0.0 } }
      .observe(self.reloadDataWithValuesProject.observer)
    self.vm.outputs.reloadDataWithValues.map { $0.map { $0.1 } }
      .observe(self.reloadDataWithValuesRewardOrBacking.observer)
    self.vm.outputs.rewardsCollectionViewFooterIsHidden
      .observe(self.rewardsCollectionViewFooterIsHidden.observer)
    self.vm.outputs.scrollToBackedRewardIndexPath.observe(self.scrollToBackedRewardIndexPath.observer)
    self.vm.outputs.showEditRewardConfirmationPrompt.observe(self.showEditRewardConfirmationPrompt.observer)
    self.vm.outputs.title.observe(self.title.observer)
  }

  func testConfigureWithProject() {
    let project = Project.cosmicSurgery
    let rewardsCount = project.rewards.count

    self.vm.inputs.configure(with: project, refTag: RefTag.category, context: .createPledge)

    self.reloadDataWithValues.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.reloadDataWithValues.assertDidEmitValue()

    let value = self.reloadDataWithValues.values.last

    XCTAssertTrue(value?.count == rewardsCount)
  }

  func testGoToAddOnSelection_NotBacked() {
    withEnvironment(config: .template) {
      var rewards = Project.cosmicSurgery.rewards

      let reward = rewards.first!
        |> Reward.lens.hasAddOns .~ true

      rewards[0] = reward

      let project = Project.cosmicSurgery
        |> Project.lens.rewardData.rewards .~ rewards
      let firstRewardId = reward.id

      self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
      self.vm.inputs.viewDidLoad()

      self.goToAddOnSelection.assertDidNotEmitValue()
      self.goToPledge.assertDidNotEmitValue()
      self.showEditRewardConfirmationPrompt.assertDidNotEmitValue()
      XCTAssertNil(self.vm.outputs.selectedReward())

      self.vm.inputs.rewardSelected(with: firstRewardId)

      let expected = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.goToAddOnSelection.assertValues([expected])
      self.goToPledge.assertDidNotEmitValue()
      self.showEditRewardConfirmationPrompt.assertDidNotEmitValue()
      XCTAssertEqual(self.vm.outputs.selectedReward(), reward)
    }
  }

  func testGoToPledge_DoesNotEmitIfCreatorOfProject() {
    let user = User.template
    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ user

    withEnvironment(config: .template, currentUser: user) {
      self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.rewardSelected(with: project.rewards[0].id)

      self.goToAddOnSelection.assertDidNotEmitValue()
      self.goToPledge.assertDidNotEmitValue()
    }
  }

  func testGoToPledge_NotBacked() {
    withEnvironment(config: .template) {
      let project = Project.cosmicSurgery

      let firstReward = project.rewards[0]
      let secondReward = project.rewards[1]

      self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
      self.vm.inputs.viewDidLoad()

      self.goToPledge.assertDidNotEmitValue()
      XCTAssertNil(self.vm.outputs.selectedReward())

      let expected1 = PledgeViewData(
        project: project,
        rewards: [firstReward],
        selectedQuantities: [firstReward.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.rewardSelected(with: firstReward.id)

      self.goToAddOnSelection.assertDidNotEmitValue()
      self.goToPledge.assertValues([expected1])
      self.showEditRewardConfirmationPrompt.assertDidNotEmitValue()
      XCTAssertEqual(self.vm.outputs.selectedReward(), firstReward)

      let expected2 = PledgeViewData(
        project: project,
        rewards: [secondReward],
        selectedQuantities: [secondReward.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.rewardSelected(with: secondReward.id)

      self.goToAddOnSelection.assertDidNotEmitValue()
      self.goToPledge.assertValues([expected1, expected2])
      self.showEditRewardConfirmationPrompt.assertDidNotEmitValue()
      XCTAssertEqual(self.vm.outputs.selectedReward(), secondReward)
    }
  }

  func testGoToAddOnSelection_IsBackedWithAddOns_RewardUnchanged() {
    withEnvironment(config: .template) {
      let reward = Reward.template
        |> Reward.lens.hasAddOns .~ true

      let project = Project.cosmicSurgery
        |> Project.lens.rewardData.rewards .~ [reward]
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.reward .~ reward
            |> Backing.lens.rewardId .~ reward.id
        )

      self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
      self.vm.inputs.viewDidLoad()

      self.goToAddOnSelection.assertDidNotEmitValue()
      self.goToPledge.assertDidNotEmitValue()
      self.showEditRewardConfirmationPrompt.assertDidNotEmitValue()
      XCTAssertNil(self.vm.outputs.selectedReward())

      let expected1 = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .updateReward
      )

      self.vm.inputs.rewardSelected(with: reward.id)

      self.goToAddOnSelection.assertValues([expected1])
      self.goToPledge.assertDidNotEmitValue()
      self.showEditRewardConfirmationPrompt.assertDidNotEmitValue()
      XCTAssertEqual(self.vm.outputs.selectedReward(), reward)
    }
  }

  func testGoToAddOnSelection_IsBackedWithAddOns_Changed_BackingWithAddOns() {
    withEnvironment(config: .template) {
      let reward = Reward.template
        |> Reward.lens.hasAddOns .~ true

      let backedReward = Reward.template
        |> Reward.lens.id .~ 55

      let project = Project.cosmicSurgery
        |> Project.lens.rewardData.rewards .~ [reward, backedReward]
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.reward .~ backedReward
            |> Backing.lens.rewardId .~ backedReward.id
        )

      self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
      self.vm.inputs.viewDidLoad()

      self.goToAddOnSelection.assertDidNotEmitValue()
      self.goToPledge.assertDidNotEmitValue()
      self.showEditRewardConfirmationPrompt.assertDidNotEmitValue()
      XCTAssertNil(self.vm.outputs.selectedReward())

      let expected1 = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .updateReward
      )

      self.vm.inputs.rewardSelected(with: reward.id)

      self.goToAddOnSelection.assertDidNotEmitValue()
      self.goToPledge.assertDidNotEmitValue()
      self.showEditRewardConfirmationPrompt.assertValues([
        "Continue with this reward? It may not offer some or all of your add-ons."
      ])
      XCTAssertEqual(self.vm.outputs.selectedReward(), reward)

      self.vm.inputs.confirmedEditReward()

      self.goToAddOnSelection.assertValues([expected1])
      self.goToPledge.assertDidNotEmitValue()
      self.showEditRewardConfirmationPrompt.assertValues([
        "Continue with this reward? It may not offer some or all of your add-ons."
      ])
      XCTAssertEqual(self.vm.outputs.selectedReward(), reward)
    }
  }

  func testGoToAddOnSelection_IsBackedWithAddOns_Changed_BackingWithoutAddOns() {
    withEnvironment(config: .template) {
      let reward = Reward.template
        |> Reward.lens.hasAddOns .~ false

      let backedReward = Reward.template
        |> Reward.lens.id .~ 55

      let project = Project.cosmicSurgery
        |> Project.lens.rewardData.rewards .~ [reward, backedReward]
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.reward .~ backedReward
            |> Backing.lens.rewardId .~ backedReward.id
        )

      self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
      self.vm.inputs.viewDidLoad()

      self.goToAddOnSelection.assertDidNotEmitValue()
      self.goToPledge.assertDidNotEmitValue()
      self.showEditRewardConfirmationPrompt.assertDidNotEmitValue()
      XCTAssertNil(self.vm.outputs.selectedReward())

      let expected1 = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .updateReward
      )

      self.vm.inputs.rewardSelected(with: reward.id)

      self.goToAddOnSelection.assertDidNotEmitValue()
      self.goToPledge.assertDidNotEmitValue()
      self.showEditRewardConfirmationPrompt.assertValues([
        "Continue with this reward? It may not offer some or all of your add-ons."
      ])
      XCTAssertEqual(self.vm.outputs.selectedReward(), reward)

      self.vm.inputs.confirmedEditReward()

      self.goToAddOnSelection.assertDidNotEmitValue()
      self.goToPledge.assertValues([expected1])
      self.showEditRewardConfirmationPrompt.assertValues([
        "Continue with this reward? It may not offer some or all of your add-ons."
      ])
      XCTAssertEqual(self.vm.outputs.selectedReward(), reward)
    }
  }

  func testRewardsCollectionViewFooterViewIsHidden() {
    self.vm.inputs.configure(with: Project.cosmicSurgery, refTag: .activity, context: .createPledge)
    self.vm.inputs.viewDidLoad()

    self.rewardsCollectionViewFooterIsHidden.assertDidNotEmitValue()

    self.vm.inputs.traitCollectionDidChange(UITraitCollection.init(verticalSizeClass: .regular))

    self.rewardsCollectionViewFooterIsHidden
      .assertValues([false], "The footer is shown when the vertical size class is .regular")

    self.vm.inputs.traitCollectionDidChange(UITraitCollection.init(verticalSizeClass: .regular))

    self.rewardsCollectionViewFooterIsHidden
      .assertValues([false, false], "The footer is shown when the vertical size class is .regular")

    self.vm.inputs.traitCollectionDidChange(UITraitCollection.init(verticalSizeClass: .compact))

    self.rewardsCollectionViewFooterIsHidden
      .assertValues([false, false, true], "The footer is hidden when the vertical size class is .compact")
  }

  func testConfigureRewardsCollectionViewFooterWithCount() {
    self.vm.inputs.configure(with: Project.cosmicSurgery, refTag: .activity, context: .createPledge)
    self.vm.inputs.viewDidLoad()

    self.configureRewardsCollectionViewFooterWithCount.assertValues([Project.cosmicSurgery.rewards.count])
  }

  func testFlashScrollIndicators() {
    self.vm.inputs.configure(with: Project.cosmicSurgery, refTag: .activity, context: .createPledge)
    self.vm.inputs.viewDidLoad()

    self.flashScrollIndicators.assertDidNotEmitValue()

    self.vm.inputs.viewDidAppear()

    self.flashScrollIndicators.assertDidEmitValue()
  }

  func testNavigationBarShadowImageHidden() {
    self.vm.inputs.configure(with: Project.cosmicSurgery, refTag: .activity, context: .createPledge)
    self.vm.inputs.viewDidLoad()

    self.navigationBarShadowImageHidden.assertDidNotEmitValue()

    self.vm.inputs.rewardCellShouldShowDividerLine(false)

    self.navigationBarShadowImageHidden.assertValues([true])

    self.vm.inputs.viewWillAppear()

    self.navigationBarShadowImageHidden.assertValues([true, true])

    self.vm.inputs.rewardCellShouldShowDividerLine(true)

    self.navigationBarShadowImageHidden.assertValues([true, true, false])

    self.vm.inputs.viewWillAppear()

    self.navigationBarShadowImageHidden.assertValues([true, true, false, false])
  }

  func testRewardSelected_NonBacking_ProjectEnded() {
    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.personalization.isBacking .~ nil

    let reward = project.rewards.first!

    withEnvironment {
      self.goToPledge.assertDidNotEmitValue()

      self.vm.inputs.configure(with: project, refTag: nil, context: .createPledge)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.vm.inputs.rewardSelected(with: reward.id)

      self.goToPledge.assertDidNotEmitValue()
    }
  }

  func testRewardSelected_Backing_WithReward_ProjectEnded() {
    let reward = Project.cosmicSurgery.rewards.first!
    let backing = Backing.template
      |> Backing.lens.reward .~ reward
      |> Backing.lens.rewardId .~ reward.id

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.personalization.isBacking .~ true

    let user = User.template

    withEnvironment(currentUser: user) {
      self.goToPledge.assertDidNotEmitValue()

      self.vm.inputs.configure(with: project, refTag: nil, context: .createPledge)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.vm.inputs.rewardSelected(with: 123)

      self.goToPledge.assertDidNotEmitValue()

      self.vm.inputs.rewardSelected(with: reward.id)

      self.goToPledge.assertDidNotEmitValue()
    }
  }

  func testRewardSelected_Backing_NoReward_ProjectEnded() {
    let backing = Backing.template
      |> Backing.lens.reward .~ .noReward
      |> Backing.lens.rewardId .~ nil

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [Reward.noReward, Reward.template]
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.personalization.isBacking .~ true

    let user = User.template

    withEnvironment(currentUser: user) {
      self.goToPledge.assertDidNotEmitValue()

      self.vm.inputs.configure(with: project, refTag: nil, context: .createPledge)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.vm.inputs.rewardSelected(with: 123)

      self.goToPledge.assertDidNotEmitValue()

      self.vm.inputs.rewardSelected(with: Reward.noReward.id)

      self.goToPledge.assertDidNotEmitValue()
    }
  }

  func testTitle_CreatePledgeContext() {
    self.vm.inputs.configure(with: Project.cosmicSurgery, refTag: .activity, context: .createPledge)
    self.vm.inputs.viewDidLoad()

    self.title.assertValue("Back this project")
  }

  func testTitle_ManagePledgeContext() {
    self.vm.inputs.configure(with: Project.cosmicSurgery, refTag: .activity, context: .managePledge)
    self.vm.inputs.viewDidLoad()

    self.title.assertValue("Edit reward")
  }

  func testTitle_CreatePledgeContext_IsCreator() {
    let creator = User.template
      |> User.lens.id .~ 5

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ creator

    withEnvironment(currentUser: creator) {
      self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
      self.vm.inputs.viewDidLoad()

      self.title.assertValue("View your rewards")
    }
  }

  func testTitle_CreatePledgeContext_IsNotCreator() {
    let user = User.template
      |> User.lens.id .~ 5

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ (
        .template |> User.lens.id .~ 10
      )

    withEnvironment(currentUser: user) {
      self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
      self.vm.inputs.viewDidLoad()

      self.title.assertValue("Back this project")
    }
  }

  func testTitle_ManagePledgeContext_IsCreator() {
    let creator = User.template
      |> User.lens.id .~ 5

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ creator

    withEnvironment(currentUser: creator) {
      self.vm.inputs.configure(with: project, refTag: .activity, context: .managePledge)
      self.vm.inputs.viewDidLoad()

      self.title.assertValue("View your rewards")
    }
  }

  func testTitle_ManagePledgeContext_IsNotCreator() {
    let user = User.template
      |> User.lens.id .~ 5

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ (
        .template |> User.lens.id .~ 10
      )

    withEnvironment(currentUser: user) {
      self.vm.inputs.configure(with: project, refTag: .activity, context: .managePledge)
      self.vm.inputs.viewDidLoad()

      self.title.assertValue("Edit reward")
    }
  }

  func testTitle_Project_NotLive() {
    let project = Project.template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
    self.vm.inputs.viewDidLoad()

    self.title.assertValue("View rewards")
  }

  func testBackedRewardIndexPath() {
    let backedReward = Reward.template
      |> Reward.lens.id .~ 5

    let rewards = [
      .template
        |> Reward.lens.id .~ 1,
      .template
        |> Reward.lens.id .~ 2,
      .template
        |> Reward.lens.id .~ 3,
      .template
        |> Reward.lens.id .~ 4,
      backedReward
    ]

    let backing = Backing.template
      |> Backing.lens.reward .~ backedReward
      |> Backing.lens.rewardId .~ 5

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ rewards
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.personalization.isBacking .~ true

    self.vm.inputs.configure(with: project, refTag: .activity, context: .managePledge)
    self.vm.inputs.viewDidLoad()

    self.scrollToBackedRewardIndexPath.assertDidNotEmitValue()

    self.vm.inputs.viewDidLayoutSubviews()

    let indexPath = IndexPath(row: 4, section: 0)

    self.scrollToBackedRewardIndexPath.assertValue(indexPath)
  }

  func testRewardSelectedTracking_PledgeContext() {
    let rewards = [
      .template
        |> Reward.lens.id .~ 1,
      .template
        |> Reward.lens.id .~ 2,
      .template
        |> Reward.lens.id .~ 3,
      .template
        |> Reward.lens.id .~ 4
    ]

    let project = Project.template
      |> \.rewardData.rewards .~ rewards

    self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.rewardSelected(with: 2)

    XCTAssertEqual(["Select Reward Button Clicked"], self.trackingClient.events)

    XCTAssertEqual([2], self.trackingClient.properties(forKey: "pledge_backer_reward_id", as: Int.self))
    XCTAssertEqual(["new_pledge"], self.trackingClient.properties(forKey: "context_pledge_flow"))
    XCTAssertEqual(["activity"], self.trackingClient.properties(forKey: "session_ref_tag"))
  }
}
