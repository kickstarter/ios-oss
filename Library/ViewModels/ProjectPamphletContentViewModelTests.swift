import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import LiveStream
@testable import ReactiveExtensions_TestHelpers

final class ProjectPamphletContentViewModelTests: TestCase {
  fileprivate let vm: ProjectPamphletContentViewModelType = ProjectPamphletContentViewModel()

  fileprivate let goToBacking = TestObserver<Project, NoError>()
  fileprivate let goToComments = TestObserver<Project, NoError>()
  fileprivate let goToLiveStreamProject = TestObserver<Project, NoError>()
  fileprivate let goToLiveStreamEvent = TestObserver<LiveStreamEvent, NoError>()
  fileprivate let goToLiveStreamCountdownProject = TestObserver<Project, NoError>()
  fileprivate let goToLiveStreamCountdownEvent = TestObserver<LiveStreamEvent, NoError>()
  fileprivate let goToRewardPledgeProject = TestObserver<Project, NoError>()
  fileprivate let goToRewardPledgeReward = TestObserver<Reward, NoError>()
  fileprivate let goToUpdates = TestObserver<Project, NoError>()
  fileprivate let loadProjectAndLiveStreamsIntoDataSourceProject = TestObserver<Project, NoError>()
  fileprivate let loadProjectAndLiveStreamsIntoDataSourceLiveStreamEvents =
    TestObserver<[LiveStreamEvent], NoError>()
  fileprivate let loadMinimalProjectIntoDataSource = TestObserver<Project, NoError>()
  fileprivate let rewardTitleCellVisible = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToBacking.observe(self.goToBacking.observer)
    self.vm.outputs.goToComments.observe(self.goToComments.observer)
    self.vm.outputs.goToLiveStream.map(first).observe(self.goToLiveStreamProject.observer)
    self.vm.outputs.goToLiveStream.map(second).observe(self.goToLiveStreamEvent.observer)
    self.vm.outputs.goToLiveStreamCountdown.map(first).observe(self.goToLiveStreamCountdownProject.observer)
    self.vm.outputs.goToLiveStreamCountdown.map(second).observe(self.goToLiveStreamCountdownEvent.observer)
    self.vm.outputs.goToRewardPledge.map(first).observe(self.goToRewardPledgeProject.observer)
    self.vm.outputs.goToRewardPledge.map(second).observe(self.goToRewardPledgeReward.observer)
    self.vm.outputs.goToUpdates.observe(self.goToUpdates.observer)
    self.vm.outputs.loadProjectAndLiveStreamsIntoDataSource.map(first).observe(
      self.loadProjectAndLiveStreamsIntoDataSourceProject.observer)
    self.vm.outputs.loadProjectAndLiveStreamsIntoDataSource.map(second).observe(
      self.loadProjectAndLiveStreamsIntoDataSourceLiveStreamEvents.observer)
    self.vm.outputs.loadMinimalProjectIntoDataSource.observe(self.loadMinimalProjectIntoDataSource.observer)
    self.vm.outputs.rewardTitleCellVisible.observe(self.rewardTitleCellVisible.observer)
  }

  func testGoToBacking() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.template
    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToBacking.assertValues([project])
  }

  func testGoToComments() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tappedComments()

    self.goToComments.assertValues([project])
  }

  func testGoToLiveStream_StreamIsLive() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.goToLiveStreamProject.assertValueCount(0)
    self.goToLiveStreamEvent.assertValueCount(0)
    self.goToLiveStreamCountdownProject.assertValueCount(0)
    self.goToLiveStreamCountdownEvent.assertValueCount(0)

    self.vm.inputs.tapped(liveStreamEvent: liveStreamEvent)

    self.goToLiveStreamProject.assertValues([project])
    self.goToLiveStreamEvent.assertValues([liveStreamEvent])
    self.goToLiveStreamCountdownProject.assertValueCount(0)
    self.goToLiveStreamCountdownEvent.assertValueCount(0)
  }

  func testGoToLiveStream_StreamIsReplay() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.startDate .~ self.scheduler.currentDate
        .addingTimeInterval(-60)

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.goToLiveStreamProject.assertValueCount(0)
    self.goToLiveStreamEvent.assertValueCount(0)
    self.goToLiveStreamCountdownProject.assertValueCount(0)
    self.goToLiveStreamCountdownEvent.assertValueCount(0)

    self.vm.inputs.tapped(liveStreamEvent: liveStreamEvent)

    self.goToLiveStreamProject.assertValues([project])
    self.goToLiveStreamEvent.assertValues([liveStreamEvent])
    self.goToLiveStreamCountdownProject.assertValueCount(0)
    self.goToLiveStreamCountdownEvent.assertValueCount(0)
  }

  func testGoToLiveStreamCountdown() {
    let project = Project.template
    let liveStreamEvent = LiveStreamEvent.template
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ self.scheduler.currentDate
        .addingTimeInterval(60)

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.goToLiveStreamProject.assertValueCount(0)
    self.goToLiveStreamEvent.assertValueCount(0)
    self.goToLiveStreamCountdownProject.assertValueCount(0)
    self.goToLiveStreamCountdownEvent.assertValueCount(0)

    self.vm.inputs.tapped(liveStreamEvent: liveStreamEvent)

    self.goToLiveStreamProject.assertValueCount(0)
    self.goToLiveStreamEvent.assertValueCount(0)
    self.goToLiveStreamCountdownProject.assertValues([project])
    self.goToLiveStreamCountdownEvent.assertValues([liveStreamEvent])
  }

  func testGoToRewardPledge_LiveProject_NoReward() {
    let project = Project.template
    let reward = Reward.noReward

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
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

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
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

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
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

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
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

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
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

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
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

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
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

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
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

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
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

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
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

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
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

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToUpdates() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tappedUpdates()

    self.goToUpdates.assertValues([project])
  }

  func testLoadProjectIntoDataSource_WhenPresentingProject() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
    self.vm.inputs.viewDidLoad()

    self.loadProjectAndLiveStreamsIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

    // Begin presentation. When presenting the project `animated` will be false since it is embedded in the
    // navigator controller.
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.loadProjectAndLiveStreamsIntoDataSourceProject
      .assertValues([project], "Load the full project into the data source.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Do not load the minimal version of the project.")

    // End presentation.
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.loadProjectAndLiveStreamsIntoDataSourceProject
      .assertValues([project], "Nothing new emits when the view is done.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

    // Simulate a new version of the project coming through
    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])

    self.loadProjectAndLiveStreamsIntoDataSourceProject.assertValues(
      [project, project, project], "The new project is loaded into data source"
    )
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")
  }

  func testLoadProjectIntoDataSource_Swiping() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
    self.vm.inputs.viewDidLoad()

    self.loadProjectAndLiveStreamsIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

    // When swiping the project `animated` will be true.
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    self.loadProjectAndLiveStreamsIntoDataSourceProject
      .assertValues([project], "The skeleton of the full project loads into the data source.")

    self.loadMinimalProjectIntoDataSource.assertValues(
      [project], "The minimal version of the project loads into the data source."
    )

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])

    self.loadProjectAndLiveStreamsIntoDataSourceProject
      .assertValues([project, project, project], "Full project emits.")
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Nothing new emits when the view is done.")

    // Swipe the project again
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.loadProjectAndLiveStreamsIntoDataSourceProject.assertValues(
      [project, project, project], "Nothing new emits."
    )
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Nothing new emits.")

    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.loadProjectAndLiveStreamsIntoDataSourceProject.assertValues(
      [project, project, project], "Nothing new emits."
    )
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Nothing new emits.")
  }

  func testRewardTitleCellVisible_WhenProjectIsLive() {
    let project = Project.template
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
    self.vm.inputs.viewDidLoad()

    self.rewardTitleCellVisible.assertValues([true])
  }

  func testRewardTitleCellVisible_WhenProjectNotLive() {
    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ true

    self.vm.inputs.configureWith(project: project, liveStreamEvents: [])
    self.vm.inputs.viewDidLoad()

    self.rewardTitleCellVisible.assertValues([false])
  }



}
