@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ProjectPamphletContentViewModelTests: TestCase {
  fileprivate let vm: ProjectPamphletContentViewModelType = ProjectPamphletContentViewModel()

  fileprivate let goToBackingProjectParam = TestObserver<Param, Never>()
  fileprivate let goToBackingBackingParam = TestObserver<Param?, Never>()
  fileprivate let goToComments = TestObserver<Project, Never>()
  fileprivate let goToDashboard = TestObserver<Param, Never>()
  fileprivate let goToRewardPledgeProject = TestObserver<Project, Never>()
  fileprivate let goToRewardPledgeReward = TestObserver<Reward, Never>()
  fileprivate let goToUpdates = TestObserver<Project, Never>()
  fileprivate let loadProjectIntoDataSourceProject = TestObserver<Project, Never>()
  fileprivate let loadProjectIntoDataSourceRefTag = TestObserver<RefTag?, Never>()
  fileprivate let loadMinimalProjectIntoDataSource = TestObserver<Project, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToBacking.map(first).observe(self.goToBackingProjectParam.observer)
    self.vm.outputs.goToBacking.map(second).observe(self.goToBackingBackingParam.observer)
    self.vm.outputs.goToComments.observe(self.goToComments.observer)
    self.vm.outputs.goToDashboard.observe(self.goToDashboard.observer)
    self.vm.outputs.goToRewardPledge.map(first).observe(self.goToRewardPledgeProject.observer)
    self.vm.outputs.goToRewardPledge.map(second).observe(self.goToRewardPledgeReward.observer)
    self.vm.outputs.goToUpdates.observe(self.goToUpdates.observer)
    self.vm.outputs.loadProjectPamphletContentDataIntoDataSource.map(first)
      .observe(self.loadProjectIntoDataSourceProject.observer)
    self.vm.outputs.loadProjectPamphletContentDataIntoDataSource.map(second)
      .observe(self.loadProjectIntoDataSourceRefTag.observer)
    self.vm.outputs.loadMinimalProjectIntoDataSource.observe(self.loadMinimalProjectIntoDataSource.observer)
  }

  func testGoToBacking() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.template
    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    self.goToBackingProjectParam.assertDidNotEmitValue()
    self.goToBackingBackingParam.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToBackingProjectParam.assertValues([.slug(project.slug)])
    self.goToBackingBackingParam.assertValues([.id(backing.id)])
  }

  func testGoToComments() {
    let project = Project.template

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tappedComments()

    self.goToComments.assertValues([project])
  }

  func testGoToDashboard() {
    let project = Project.template
    let param: Param = .id(project.id)

    self.vm.inputs.tappedViewProgress(of: project)

    self.goToDashboard.assertValue(param)
  }

  func testGoToRewardPledge_LiveProject_NoReward() {
    let project = Project.template
    let reward = Reward.noReward

    self.vm.inputs.configureWith(value: (project, nil))
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

    self.vm.inputs.configureWith(value: (project, nil))
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

    self.vm.inputs.configureWith(value: (project, nil))
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

    self.vm.inputs.configureWith(value: (project, nil))
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

    self.vm.inputs.configureWith(value: (project, nil))
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

    self.vm.inputs.configureWith(value: (project, nil))
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

    self.vm.inputs.configureWith(value: (project, nil))
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

    self.vm.inputs.configureWith(value: (project, nil))
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

    self.vm.inputs.configureWith(value: (project, nil))
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

    self.vm.inputs.configureWith(value: (project, nil))
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

    self.vm.inputs.configureWith(value: (project, nil))
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

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToUpdates() {
    let project = Project.template

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tappedUpdates()

    self.goToUpdates.assertValues([project])
  }

  func testLoadProjectIntoDataSource_WhenPresentingProject() {
    let project = Project.template

    self.vm.inputs.configureWith(value: (project, .discovery))
    self.vm.inputs.viewDidLoad()

    self.loadProjectIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
    self.loadProjectIntoDataSourceRefTag.assertValues([], "Nothing emits immediately.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

    // Begin presentation. When presenting the project `animated` will be false since it is embedded in the
    // navigator controller.
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.loadProjectIntoDataSourceProject
      .assertValues([project], "Load the full project into the data source.")
    self.loadProjectIntoDataSourceRefTag.assertValues([.discovery], "Load the refTag into the data source.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Do not load the minimal version of the project.")

    // End presentation.
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.loadProjectIntoDataSourceProject
      .assertValues([project], "Nothing new emits when the view is done.")
    self.loadProjectIntoDataSourceRefTag.assertValues(
      [.discovery], "Nothing new emits when the view is done."
    )
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

    // Simulate a new version of the project coming through
    self.vm.inputs.configureWith(value: (project, .discovery))

    self.loadProjectIntoDataSourceProject.assertValues(
      [project, project], "The new project is loaded into data source"
    )
    self.loadProjectIntoDataSourceRefTag.assertValues(
      [.discovery, .discovery], "The new refTag is loaded into data source"
    )
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")
  }

  func testLoadProjectIntoDataSource_Swiping() {
    let project = Project.template

    self.vm.inputs.configureWith(value: (project, .discovery))
    self.vm.inputs.viewDidLoad()

    self.loadProjectIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
    self.loadProjectIntoDataSourceRefTag.assertValues([], "Nothing emits immediately.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

    // When swiping the project `animated` will be true.
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    self.loadProjectIntoDataSourceProject
      .assertValues([project], "The skeleton of the full project loads into the data source.")
    self.loadProjectIntoDataSourceRefTag.assertValues([.discovery], "RefTag is loaded.")
    self.loadMinimalProjectIntoDataSource.assertValues(
      [project], "The minimal version of the project loads into the data source."
    )

    self.vm.inputs.configureWith(value: (project, .discovery))

    self.loadProjectIntoDataSourceProject
      .assertValues([project, project], "Full project emits.")
    self.loadProjectIntoDataSourceRefTag.assertValues(
      [.discovery, .discovery], "RefTag emits with full project."
    )
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Nothing new emits when the view is done.")

    // Swipe the project again
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.loadProjectIntoDataSourceProject.assertValues(
      [project, project], "Nothing new emits."
    )
    self.loadProjectIntoDataSourceRefTag.assertValues(
      [.discovery, .discovery], "Nothing new emits."
    )
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Nothing new emits.")

    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.loadProjectIntoDataSourceProject.assertValues(
      [project, project], "Nothing new emits."
    )
    self.loadProjectIntoDataSourceRefTag.assertValues(
      [.discovery, .discovery], "Nothing new emits."
    )
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Nothing new emits.")
  }
}
