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
  private let goToDeprecatedPledgeProject = TestObserver<Project, Never>()
  private let goToDeprecatedPledgeRefTag = TestObserver<RefTag?, Never>()
  private let goToDeprecatedPledgeReward = TestObserver<Reward, Never>()
  private let goToPledgeProject = TestObserver<Project, Never>()
  private let goToPledgeRefTag = TestObserver<RefTag?, Never>()
  private let goToPledgeReward = TestObserver<Reward, Never>()
  private let goToViewBackingProject = TestObserver<Project, Never>()
  private let goToViewBackingUser = TestObserver<User?, Never>()
  private let navigationBarShadowImageHidden = TestObserver<Bool, Never>()
  private let reloadDataWithValues = TestObserver<[(Project, Either<Reward, Backing>)], Never>()
  private let reloadDataWithValuesProject = TestObserver<[Project], Never>()
  private let reloadDataWithValuesRewardOrBacking = TestObserver<[Either<Reward, Backing>], Never>()
  private let rewardsCollectionViewFooterIsHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureRewardsCollectionViewFooterWithCount
      .observe(self.configureRewardsCollectionViewFooterWithCount.observer)
    self.vm.outputs.flashScrollIndicators.observe(self.flashScrollIndicators.observer)
    self.vm.outputs.goToDeprecatedPledge.map { $0.project }.observe(self.goToDeprecatedPledgeProject.observer)
    self.vm.outputs.goToDeprecatedPledge.map { $0.reward }.observe(self.goToDeprecatedPledgeReward.observer)
    self.vm.outputs.goToDeprecatedPledge.map { $0.refTag }.observe(self.goToDeprecatedPledgeRefTag.observer)
    self.vm.outputs.goToPledge.map { $0.project }.observe(self.goToPledgeProject.observer)
    self.vm.outputs.goToPledge.map { $0.reward }.observe(self.goToPledgeReward.observer)
    self.vm.outputs.goToPledge.map { $0.refTag }.observe(self.goToPledgeRefTag.observer)
    self.vm.outputs.goToViewBacking.map(first).observe(self.goToViewBackingProject.observer)
    self.vm.outputs.goToViewBacking.map(second).observe(self.goToViewBackingUser.observer)
    self.vm.outputs.navigationBarShadowImageHidden.observe(self.navigationBarShadowImageHidden.observer)
    self.vm.outputs.reloadDataWithValues.observe(self.reloadDataWithValues.observer)
    self.vm.outputs.reloadDataWithValues.map { $0.map { $0.0 } }
      .observe(self.reloadDataWithValuesProject.observer)
    self.vm.outputs.reloadDataWithValues.map { $0.map { $0.1 } }
      .observe(self.reloadDataWithValuesRewardOrBacking.observer)
    self.vm.outputs.rewardsCollectionViewFooterIsHidden
      .observe(self.rewardsCollectionViewFooterIsHidden.observer)
  }

  func testConfigureWithProject() {
    let project = Project.cosmicSurgery
    let rewardsCount = project.rewards.count

    self.vm.inputs.configure(with: project, refTag: RefTag.category)

    self.reloadDataWithValues.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.reloadDataWithValues.assertDidEmitValue()

    let value = self.reloadDataWithValues.values.last

    XCTAssertTrue(value?.count == rewardsCount)
  }

  func testGoToPledge() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckoutPledgeView.rawValue: true]

    withEnvironment(config: config) {
      let project = Project.cosmicSurgery
      let firstRewardId = project.rewards.first!.id

      self.vm.inputs.configure(with: project, refTag: .activity)
      self.vm.inputs.viewDidLoad()

      self.goToDeprecatedPledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedPledgeReward.assertDidNotEmitValue()
      self.goToDeprecatedPledgeRefTag.assertDidNotEmitValue()
      self.goToPledgeProject.assertDidNotEmitValue()
      self.goToPledgeReward.assertDidNotEmitValue()
      self.goToPledgeRefTag.assertDidNotEmitValue()
      XCTAssertNil(self.vm.outputs.selectedReward())

      self.vm.inputs.rewardSelected(with: firstRewardId)

      self.goToDeprecatedPledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedPledgeReward.assertDidNotEmitValue()
      self.goToDeprecatedPledgeRefTag.assertDidNotEmitValue()
      self.goToPledgeProject.assertValues([project])
      self.goToPledgeReward.assertValues([project.rewards[0]])
      self.goToPledgeRefTag.assertValues([.activity])
      self.goToViewBackingUser.assertDidNotEmitValue()
      self.goToViewBackingProject.assertDidNotEmitValue()
      XCTAssertEqual(self.vm.outputs.selectedReward(), project.rewards[0])

      let lastCardRewardId = project.rewards.last!.id
      let endIndex = project.rewards.endIndex

      self.vm.inputs.rewardSelected(with: lastCardRewardId)

      self.goToDeprecatedPledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedPledgeReward.assertDidNotEmitValue()
      self.goToDeprecatedPledgeRefTag.assertDidNotEmitValue()
      self.goToPledgeProject.assertValues([project, project])
      self.goToPledgeReward.assertValues([project.rewards[0], project.rewards[endIndex - 1]])
      self.goToPledgeRefTag.assertValues([.activity, .activity])
      self.goToViewBackingUser.assertDidNotEmitValue()
      self.goToViewBackingProject.assertDidNotEmitValue()
      XCTAssertEqual(self.vm.outputs.selectedReward(), project.rewards[endIndex - 1])
    }
  }

  func testGoToDeprecatedPledge() {
    let project = Project.cosmicSurgery
    let firstRewardId = project.rewards.first!.id

    self.vm.inputs.configure(with: project, refTag: .activity)
    self.vm.inputs.viewDidLoad()

    self.goToDeprecatedPledgeProject.assertDidNotEmitValue()
    self.goToDeprecatedPledgeReward.assertDidNotEmitValue()
    self.goToDeprecatedPledgeRefTag.assertDidNotEmitValue()
    self.goToPledgeProject.assertDidNotEmitValue()
    self.goToPledgeReward.assertDidNotEmitValue()
    self.goToPledgeRefTag.assertDidNotEmitValue()
    XCTAssertNil(self.vm.outputs.selectedReward())

    self.vm.inputs.rewardSelected(with: firstRewardId)

    self.goToDeprecatedPledgeProject.assertValues([project])
    self.goToDeprecatedPledgeReward.assertValues([project.rewards[0]])
    self.goToDeprecatedPledgeRefTag.assertValues([.activity])
    self.goToPledgeProject.assertDidNotEmitValue()
    self.goToPledgeReward.assertDidNotEmitValue()
    self.goToPledgeRefTag.assertDidNotEmitValue()
    self.goToViewBackingUser.assertDidNotEmitValue()
    self.goToViewBackingProject.assertDidNotEmitValue()
    XCTAssertEqual(self.vm.outputs.selectedReward(), project.rewards[0])

    let lastCardRewardId = project.rewards.last!.id
    let endIndex = project.rewards.endIndex

    self.vm.inputs.rewardSelected(with: lastCardRewardId)

    self.goToDeprecatedPledgeProject.assertValues([project, project])
    self.goToDeprecatedPledgeReward.assertValues([project.rewards[0], project.rewards[endIndex - 1]])
    self.goToDeprecatedPledgeRefTag.assertValues([.activity, .activity])
    self.goToPledgeProject.assertDidNotEmitValue()
    self.goToPledgeReward.assertDidNotEmitValue()
    self.goToPledgeRefTag.assertDidNotEmitValue()
    self.goToViewBackingUser.assertDidNotEmitValue()
    self.goToViewBackingProject.assertDidNotEmitValue()
    XCTAssertEqual(self.vm.outputs.selectedReward(), project.rewards[endIndex - 1])
  }

  func testRewardsCollectionViewFooterViewIsHidden() {
    self.vm.inputs.configure(with: Project.cosmicSurgery, refTag: .activity)
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
    self.vm.inputs.configure(with: Project.cosmicSurgery, refTag: .activity)
    self.vm.inputs.viewDidLoad()

    self.configureRewardsCollectionViewFooterWithCount.assertValues([Project.cosmicSurgery.rewards.count])
  }

  func testFlashScrollIndicators() {
    self.vm.inputs.configure(with: Project.cosmicSurgery, refTag: .activity)
    self.vm.inputs.viewDidLoad()

    self.flashScrollIndicators.assertDidNotEmitValue()

    self.vm.inputs.viewDidAppear()

    self.flashScrollIndicators.assertDidEmitValue()
  }

  func testNavigationBarShadowImageHidden() {
    self.vm.inputs.configure(with: Project.cosmicSurgery, refTag: .activity)
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
      self.goToDeprecatedPledgeProject.assertDidNotEmitValue()
      self.goToViewBackingProject.assertDidNotEmitValue()

      self.vm.inputs.configure(with: project, refTag: nil)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.vm.inputs.rewardSelected(with: reward.id)

      self.goToPledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedPledgeProject.assertDidNotEmitValue()
      self.goToViewBackingProject.assertDidNotEmitValue()
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
      self.goToDeprecatedPledgeProject.assertDidNotEmitValue()
      self.goToViewBackingProject.assertDidNotEmitValue()

      self.vm.inputs.configure(with: project, refTag: nil)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.vm.inputs.rewardSelected(with: 123)

      self.goToPledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedPledgeProject.assertDidNotEmitValue()
      self.goToViewBackingProject.assertDidNotEmitValue()

      self.vm.inputs.rewardSelected(with: reward.id)

      self.goToPledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedPledgeProject.assertDidNotEmitValue()

      self.goToViewBackingProject.assertValues([project])
      self.goToViewBackingUser.assertValues([user])
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
      self.goToDeprecatedPledgeProject.assertDidNotEmitValue()
      self.goToViewBackingProject.assertDidNotEmitValue()

      self.vm.inputs.configure(with: project, refTag: nil)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.vm.inputs.rewardSelected(with: 123)

      self.goToPledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedPledgeProject.assertDidNotEmitValue()
      self.goToViewBackingProject.assertDidNotEmitValue()

      self.vm.inputs.rewardSelected(with: Reward.noReward.id)

      self.goToPledgeProject.assertDidNotEmitValue()
      self.goToDeprecatedPledgeProject.assertDidNotEmitValue()

      self.goToViewBackingProject.assertValues([project])
      self.goToViewBackingUser.assertValues([user])
    }
  }
}
