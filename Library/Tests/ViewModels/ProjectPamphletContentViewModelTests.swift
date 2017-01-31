import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectPamphletContentViewModelTests: TestCase {
  fileprivate let vm: ProjectPamphletContentViewModelType = ProjectPamphletContentViewModel()

  fileprivate let goToBacking = TestObserver<Project, NoError>()
  fileprivate let goToComments = TestObserver<Project, NoError>()
  fileprivate let goToLiveStreamProject = TestObserver<Project, NoError>()
  fileprivate let goToLiveStreamProjectLiveStream = TestObserver<Project.LiveStream, NoError>()
  fileprivate let goToLiveStreamCountdownProject = TestObserver<Project, NoError>()
  fileprivate let goToLiveStreamCountdownProjectLiveStream = TestObserver<Project.LiveStream, NoError>()
  fileprivate let goToRewardPledgeProject = TestObserver<Project, NoError>()
  fileprivate let goToRewardPledgeReward = TestObserver<Reward, NoError>()
  fileprivate let goToUpdates = TestObserver<Project, NoError>()
  fileprivate let loadProjectIntoDataSource = TestObserver<Project, NoError>()
  fileprivate let loadMinimalProjectIntoDataSource = TestObserver<Project, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToBacking.observe(self.goToBacking.observer)
    self.vm.outputs.goToComments.observe(self.goToComments.observer)
    self.vm.outputs.goToLiveStream.map(first).observe(self.goToLiveStreamProject.observer)
    self.vm.outputs.goToLiveStream.map(second).observe(self.goToLiveStreamProjectLiveStream.observer)
    self.vm.outputs.goToLiveStreamCountdown.map(first).observe(self.goToLiveStreamCountdownProject.observer)
    self.vm.outputs.goToLiveStreamCountdown.map(second).observe(self.goToLiveStreamCountdownProjectLiveStream
      .observer)
    self.vm.outputs.goToRewardPledge.map(first).observe(self.goToRewardPledgeProject.observer)
    self.vm.outputs.goToRewardPledge.map(second).observe(self.goToRewardPledgeReward.observer)
    self.vm.outputs.goToUpdates.observe(self.goToUpdates.observer)
    self.vm.outputs.loadProjectIntoDataSource.observe(self.loadProjectIntoDataSource.observer)
    self.vm.outputs.loadMinimalProjectIntoDataSource.observe(self.loadMinimalProjectIntoDataSource.observer)
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

  func testGoToLiveStream_StreamIsLive() {
    let liveStream = Project.LiveStream.template
      |> Project.LiveStream.lens.isLiveNow .~ true
    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.goToLiveStreamProject.assertValueCount(0)
    self.goToLiveStreamProjectLiveStream.assertValueCount(0)
    self.goToLiveStreamCountdownProject.assertValueCount(0)
    self.goToLiveStreamCountdownProjectLiveStream.assertValueCount(0)

    self.vm.inputs.tapped(liveStream: liveStream)

    self.goToLiveStreamProject.assertValues([project])
    self.goToLiveStreamProjectLiveStream.assertValues([liveStream])
    self.goToLiveStreamCountdownProject.assertValueCount(0)
    self.goToLiveStreamCountdownProjectLiveStream.assertValueCount(0)
  }

  func testGoToLiveStream_StreamIsReplay() {
    let liveStream = Project.LiveStream.template
      |> Project.LiveStream.lens.isLiveNow .~ false
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 - 60)
    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.goToLiveStreamProject.assertValueCount(0)
    self.goToLiveStreamProjectLiveStream.assertValueCount(0)
    self.goToLiveStreamCountdownProject.assertValueCount(0)
    self.goToLiveStreamCountdownProjectLiveStream.assertValueCount(0)

    self.vm.inputs.tapped(liveStream: liveStream)

    self.goToLiveStreamProject.assertValues([project])
    self.goToLiveStreamProjectLiveStream.assertValues([liveStream])
    self.goToLiveStreamCountdownProject.assertValueCount(0)
    self.goToLiveStreamCountdownProjectLiveStream.assertValueCount(0)
  }

  func testGoToLiveStreamCountdown() {
    let liveStream = Project.LiveStream.template
      |> Project.LiveStream.lens.isLiveNow .~ false
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 + 60)
    let project = Project.template
      |> Project.lens.liveStreams .~ [liveStream]

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.goToLiveStreamProject.assertValueCount(0)
    self.goToLiveStreamProjectLiveStream.assertValueCount(0)
    self.goToLiveStreamCountdownProject.assertValueCount(0)
    self.goToLiveStreamCountdownProjectLiveStream.assertValueCount(0)

    self.vm.inputs.tapped(liveStream: liveStream)

    self.goToLiveStreamProject.assertValueCount(0)
    self.goToLiveStreamProjectLiveStream.assertValueCount(0)
    self.goToLiveStreamCountdownProject.assertValues([project])
    self.goToLiveStreamCountdownProjectLiveStream.assertValues([liveStream])
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

  func testLoadProjectIntoDataSource_WhenPresentingProject() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.loadProjectIntoDataSource.assertValues([], "Nothing emits immediately.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

    // Begin presentation. When presenting the project `animated` will be false since it is embedded in the
    // navigator controller.
    self.vm.inputs.viewWillAppear(animated: false)

    self.loadProjectIntoDataSource.assertValues([project], "Load the full project into the data source.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Do not load the minimal version of the project.")

    // End presentation.
    self.vm.inputs.viewDidAppear(animated: false)

    self.loadProjectIntoDataSource.assertValues([project], "Nothing new emits when the view is done.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

    // Simulate a new version of the project coming through
    self.vm.inputs.configureWith(project: project)

    self.loadProjectIntoDataSource.assertValues(
      [project, project], "The new project is loaded into data source"
    )
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")
  }

  func testLoadProjectIntoDataSource_Swiping() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.loadProjectIntoDataSource.assertValues([], "Nothing emits immediately.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

    // When swiping the project `animated` will be true.
    self.vm.inputs.viewWillAppear(animated: true)

    self.loadProjectIntoDataSource.assertValues(
      [project], "The skeleton of the full project loads into the data source."
    )

    self.loadMinimalProjectIntoDataSource.assertValues(
      [project], "The minimal version of the project loads into the data source."
    )

    self.vm.inputs.configureWith(project: project)

    self.loadProjectIntoDataSource.assertValues([project, project], "Full project emits.")
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Minimal project does not emit again.")

    // Swipe the project again
    self.vm.inputs.viewWillAppear(animated: true)

    self.loadProjectIntoDataSource.assertValues([project, project], "Nothing new emits.")
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Nothing new emits.")

    self.vm.inputs.viewDidAppear(animated: true)

    self.loadProjectIntoDataSource.assertValues([project, project], "Nothing new emits.")
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Nothing new emits.")
  }
}
