import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectPamphletContentViewModelTests: TestCase {
  private let vm: ProjectPamphletContentViewModelType = ProjectPamphletContentViewModel()

  private let goToBacking = TestObserver<Project, NoError>()
  private let goToComments = TestObserver<Project, NoError>()
  private let goToRewardPledgeProject = TestObserver<Project, NoError>()
  private let goToRewardPledgeReward = TestObserver<Reward, NoError>()
  private let goToUpdates = TestObserver<Project, NoError>()
  private let loadProjectIntoDataSource = TestObserver<Project, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToBacking.observe(self.goToBacking.observer)
    self.vm.outputs.goToComments.observe(self.goToComments.observer)
    self.vm.outputs.goToRewardPledge.map(first).observe(self.goToRewardPledgeProject.observer)
    self.vm.outputs.goToRewardPledge.map(second).observe(self.goToRewardPledgeReward.observer)
    self.vm.outputs.goToUpdates.observe(self.goToUpdates.observer)
    self.vm.outputs.loadProjectIntoDataSource.observe(self.loadProjectIntoDataSource.observer)
  }

  func testGoToBacking() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.template
    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToBacking.assertValues([project])
  }

  func testGoToComments() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tappedComments()

    self.goToComments.assertValues([project])
  }

  func testGoToRewardPledge_LiveProject_NoReward() {
    let project = Project.template
    let reward = Reward.noReward

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_Reward() {
    let project = Project.template
    let reward = Reward.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_SoldOutReward() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 0

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToRewardPledge_LiveProject_BackingNoReward() {
    let project = Project.template
    let reward = Reward.noReward
    let backing = .template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_BackingReward() {
    let project = Project.template
    let reward = Reward.template
    let backing = .template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_BackingSoldOutReward() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 0
    let backing = .template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_BackingNoReward_TapAnotherReward() {
    let reward = Reward.template
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ .noReward
    )

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_BackingReward_TapNoReward() {
    let reward = Reward.noReward
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ .template
    )

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_NonLiveProject_NoReward() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.noReward

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToRewardPledge_NonLiveProject_Reward() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToRewardPledge_NonLiveProject_BackingNoReward() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.noReward
    let backing = .template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToRewardPledge_NonLiveProject_BackingReward() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.template
    let backing = .template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToUpdates() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tappedUpdates()

    self.goToUpdates.assertValues([project])
  }

  func testLoadProjectIntoDataSource() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.loadProjectIntoDataSource.assertValues([project])
  }
}
