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
  private let goToPledgeProject = TestObserver<Project, Never>()
  private let goToPledgeRefTag = TestObserver<RefTag?, Never>()
  private let goToPledgeReward = TestObserver<Reward, Never>()
  private let goToPledgeContext = TestObserver<PledgeViewContext, Never>()
  private let navigationBarShadowImageHidden = TestObserver<Bool, Never>()
  private let reloadDataWithValues = TestObserver<[(Project, Either<Reward, Backing>)], Never>()
  private let reloadDataWithValuesProject = TestObserver<[Project], Never>()
  private let reloadDataWithValuesRewardOrBacking = TestObserver<[Either<Reward, Backing>], Never>()
  private let rewardsCollectionViewFooterIsHidden = TestObserver<Bool, Never>()
  private let scrollToBackedRewardIndexPath = TestObserver<IndexPath, Never>()
  private let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureRewardsCollectionViewFooterWithCount
      .observe(self.configureRewardsCollectionViewFooterWithCount.observer)
    self.vm.outputs.flashScrollIndicators.observe(self.flashScrollIndicators.observer)
    self.vm.outputs.goToPledge.map(first).map { $0.project }.observe(self.goToPledgeProject.observer)
    self.vm.outputs.goToPledge.map(first).map { $0.reward }.observe(self.goToPledgeReward.observer)
    self.vm.outputs.goToPledge.map(first).map { $0.refTag }.observe(self.goToPledgeRefTag.observer)
    self.vm.outputs.goToPledge.map(second).observe(self.goToPledgeContext.observer)
    self.vm.outputs.navigationBarShadowImageHidden.observe(self.navigationBarShadowImageHidden.observer)
    self.vm.outputs.reloadDataWithValues.observe(self.reloadDataWithValues.observer)
    self.vm.outputs.reloadDataWithValues.map { $0.map { $0.0 } }
      .observe(self.reloadDataWithValuesProject.observer)
    self.vm.outputs.reloadDataWithValues.map { $0.map { $0.1 } }
      .observe(self.reloadDataWithValuesRewardOrBacking.observer)
    self.vm.outputs.rewardsCollectionViewFooterIsHidden
      .observe(self.rewardsCollectionViewFooterIsHidden.observer)
    self.vm.outputs.scrollToBackedRewardIndexPath.observe(self.scrollToBackedRewardIndexPath.observer)
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

  func testGoToPledge() {
    withEnvironment(config: .template) {
      let project = Project.cosmicSurgery
      let firstRewardId = project.rewards.first!.id

      self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
      self.vm.inputs.viewDidLoad()

      self.goToPledgeProject.assertDidNotEmitValue()
      self.goToPledgeReward.assertDidNotEmitValue()
      self.goToPledgeContext.assertDidNotEmitValue()
      self.goToPledgeRefTag.assertDidNotEmitValue()
      XCTAssertNil(self.vm.outputs.selectedReward())

      self.vm.inputs.rewardSelected(with: firstRewardId)

      self.goToPledgeProject.assertValues([project])
      self.goToPledgeReward.assertValues([project.rewards[0]])
      self.goToPledgeContext.assertValues([.pledge])
      self.goToPledgeRefTag.assertValues([.activity])
      XCTAssertEqual(self.vm.outputs.selectedReward(), project.rewards[0])

      let lastCardRewardId = project.rewards.last!.id
      let endIndex = project.rewards.endIndex

      self.vm.inputs.rewardSelected(with: lastCardRewardId)

      self.goToPledgeProject.assertValues([project, project])
      self.goToPledgeReward.assertValues([project.rewards[0], project.rewards[endIndex - 1]])
      self.goToPledgeContext.assertValues([.pledge, .pledge])
      self.goToPledgeRefTag.assertValues([.activity, .activity])
      XCTAssertEqual(self.vm.outputs.selectedReward(), project.rewards[endIndex - 1])
    }
  }

  func testGoToUpdatePledge() {
    withEnvironment(config: .template) {
      let project = Project.cosmicSurgery
      let firstRewardId = project.rewards.first!.id

      self.vm.inputs.configure(with: project, refTag: .activity, context: .managePledge)
      self.vm.inputs.viewDidLoad()

      self.goToPledgeProject.assertDidNotEmitValue()
      self.goToPledgeReward.assertDidNotEmitValue()
      self.goToPledgeContext.assertDidNotEmitValue()
      self.goToPledgeRefTag.assertDidNotEmitValue()
      XCTAssertNil(self.vm.outputs.selectedReward())

      self.vm.inputs.rewardSelected(with: firstRewardId)

      self.goToPledgeProject.assertValues([project])
      self.goToPledgeReward.assertValues([project.rewards[0]])
      self.goToPledgeContext.assertValues([.pledge])
      self.goToPledgeRefTag.assertValues([.activity])
      XCTAssertEqual(self.vm.outputs.selectedReward(), project.rewards[0])

      let lastCardRewardId = project.rewards.last!.id
      let endIndex = project.rewards.endIndex

      self.vm.inputs.rewardSelected(with: lastCardRewardId)

      self.goToPledgeProject.assertValues([project, project])
      self.goToPledgeReward.assertValues([project.rewards[0], project.rewards[endIndex - 1]])
      self.goToPledgeContext.assertValues([.pledge, .pledge])
      self.goToPledgeRefTag.assertValues([.activity, .activity])
      XCTAssertEqual(self.vm.outputs.selectedReward(), project.rewards[endIndex - 1])
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
      self.goToPledgeProject.assertDidNotEmitValue()

      self.vm.inputs.configure(with: project, refTag: nil, context: .createPledge)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.vm.inputs.rewardSelected(with: reward.id)

      self.goToPledgeProject.assertDidNotEmitValue()
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
      self.goToPledgeProject.assertDidNotEmitValue()

      self.vm.inputs.configure(with: project, refTag: nil, context: .createPledge)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.vm.inputs.rewardSelected(with: 123)

      self.goToPledgeProject.assertDidNotEmitValue()

      self.vm.inputs.rewardSelected(with: reward.id)

      self.goToPledgeProject.assertDidNotEmitValue()
    }
  }

  func testRewardSelected_Backing_NoReward_ProjectEnded() {
    let backing = Backing.template
      |> Backing.lens.reward .~ .noReward
      |> Backing.lens.rewardId .~ nil

    let project = Project.template
      |> Project.lens.rewards .~ [Reward.noReward, Reward.template]
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.personalization.isBacking .~ true

    let user = User.template

    withEnvironment(currentUser: user) {
      self.goToPledgeProject.assertDidNotEmitValue()

      self.vm.inputs.configure(with: project, refTag: nil, context: .createPledge)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.vm.inputs.rewardSelected(with: 123)

      self.goToPledgeProject.assertDidNotEmitValue()

      self.vm.inputs.rewardSelected(with: Reward.noReward.id)

      self.goToPledgeProject.assertDidNotEmitValue()
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

    self.title.assertValue("Choose another reward")
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

      self.title.assertValue("Choose another reward")
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
      |> Project.lens.rewards .~ rewards
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
      |> \.rewards .~ rewards

    self.vm.inputs.configure(with: project, refTag: .activity, context: .createPledge)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.rewardSelected(with: 2)

    XCTAssertEqual(["Select Reward Button Clicked"], self.trackingClient.events)

    XCTAssertEqual([2], self.trackingClient.properties(forKey: "pledge_backer_reward_id", as: Int.self))
    XCTAssertEqual(["new_pledge"], self.trackingClient.properties(forKey: "context_pledge_flow"))
    XCTAssertEqual(["activity"], self.trackingClient.properties(forKey: "session_ref_tag"))
  }
}
