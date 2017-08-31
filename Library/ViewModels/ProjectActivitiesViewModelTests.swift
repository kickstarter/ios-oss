import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Result
import KsApi
import Prelude

final class ProjectActivitiesViewModelTests: TestCase {
  fileprivate let vm: ProjectActivitiesViewModelType = ProjectActivitiesViewModel()

  fileprivate let activitiesPresent = TestObserver<Bool, NoError>()
  fileprivate let goTo = TestObserver<ProjectActivitiesGoTo, NoError>()
  fileprivate let groupedDates = TestObserver<Bool, NoError>()
  fileprivate let isRefreshing = TestObserver<Bool, NoError>()
  fileprivate let project = TestObserver<Project, NoError>()
  fileprivate let showEmptyState = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.projectActivityData
      .map { !$0.activities.isEmpty }
      .observe(self.activitiesPresent.observer)
    self.vm.outputs.goTo.observe(self.goTo.observer)
    self.vm.outputs.isRefreshing.observe(self.isRefreshing.observer)
    self.vm.outputs.projectActivityData
      .map { $0.project }
      .observe(self.project.observer)
    self.vm.outputs.projectActivityData
      .map { $0.groupedDates }
      .observe(self.groupedDates.observer)
    self.vm.outputs.showEmptyState.observe(self.showEmptyState.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
  }

  func testFlow() {
    let project = Project.template

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse:
      [.template |> Activity.lens.id .~ 1])) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.activitiesPresent.assertDidNotEmitValue("No activities")
      self.scheduler.advance()

      self.activitiesPresent.assertValues([true], "Show activities after scheduler advances")
      self.groupedDates.assertValues([true], "Group dates by default")
      self.project.assertValues([project], "Emits project")
      XCTAssertEqual(["Viewed Project Activity", "Creator Activity View"],
                     self.trackingClient.events, "View event and its deprecated version are tracked")
    }

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse:
      [.template |> Activity.lens.id .~ 2])) {
      self.vm.inputs.refresh()
      self.scheduler.advance()

      self.activitiesPresent.assertValues([true, true], "Activities refreshed")
      self.groupedDates.assertValues([true, true], "Group dates by default")
      self.project.assertValues([project, project], "Emits project")
      XCTAssertEqual(["Viewed Project Activity", "Creator Activity View", "Loaded Newer Project Activity",
        "Creator Activity View Load Newer"],
                     self.trackingClient.events, "Load newer event and its deprecated version are tracked")
    }

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse:
      [.template |> Activity.lens.id .~ 3])) {
      self.vm.inputs.willDisplayRow(9, outOf: 10)
      self.scheduler.advance()

      self.activitiesPresent.assertValues([true, true, true], "Activities paginate")
      self.groupedDates.assertValues([true, true, true], "Group dates by default")
      self.project.assertValues([project, project, project], "Emits project")
      XCTAssertEqual(["Viewed Project Activity", "Creator Activity View", "Loaded Newer Project Activity",
        "Creator Activity View Load Newer", "Loaded Older Project Activity",
        "Creator Activity View Load Older"],
                     self.trackingClient.events, "Load older event and its deprecated version are tracked")
    }

    self.showEmptyState.assertValues([false],
                                     "Don't show, because each activity emission was a non-empty array")
  }

  func testEmptyState() {
    let project = Project.template

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse: [])) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.activitiesPresent.assertValues([false], "No activities")
      self.showEmptyState.assertValues([true], "Activities not present, show empty state")
      self.project.assertValues([project], "Emits project")
    }
  }

  func testGoTo() {
    let project = Project.template
    let comment = Comment.template
    let backing = Backing.template |> Backing.lens.projectId .~ project.id
    let update = Update.template
    let user = User.template

    let backingActivity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.backing .~ backing
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    let commentPostActivity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.comment .~ comment
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update
      |> Activity.lens.user .~ user

    let commentProjectActivity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.comment .~ comment
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    let successActivity = .template
      |> Activity.lens.category .~ .failure
      |> Activity.lens.project .~ (project |> Project.lens.state .~ .successful)
      |> Activity.lens.user .~ user

    let updateActivity = .template
      |> Activity.lens.category .~ .update
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update
      |> Activity.lens.user .~ user

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse:
    [backingActivity, commentPostActivity, commentProjectActivity, successActivity, updateActivity])) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      // Testing when cells are tapped for different categories of activity

      self.vm.inputs.activityAndProjectCellTapped(activity: backingActivity, project: project)
      self.goTo.assertValueCount(1, "Should go to backing")

      self.vm.inputs.activityAndProjectCellTapped(activity: commentPostActivity, project: project)
      self.goTo.assertValueCount(2, "Should go to comments for update")

      self.vm.inputs.activityAndProjectCellTapped(activity: commentProjectActivity, project: project)
      self.goTo.assertValueCount(3, "Should go to comments for project")

      self.vm.inputs.activityAndProjectCellTapped(activity: successActivity, project: project)
      self.goTo.assertValueCount(4, "Should go to project")

      self.vm.inputs.activityAndProjectCellTapped(activity: updateActivity, project: project)
      self.goTo.assertValueCount(5, "Should go to update")

      // Testing delegate methods

      self.vm.inputs.projectActivityBackingCellGoToBacking(project: project, user: user)
      self.goTo.assertValueCount(6, "Should go to backing")

      self.vm.inputs.projectActivityBackingCellGoToSendMessage(project: project, backing: backing)
      self.goTo.assertValueCount(7, "Should go to send message")

      self.vm.inputs.projectActivityCommentCellGoToBacking(project: project, user: user)
      self.goTo.assertValueCount(8, "Should go to backing")

      self.vm.inputs.projectActivityCommentCellGoToSendReply(project: project, update: nil, comment: comment)
      self.goTo.assertValueCount(9, "Should go to comments for project")

      self.vm.inputs.projectActivityCommentCellGoToSendReply(project: project,
                                                             update: update,
                                                             comment: comment)
      self.goTo.assertValueCount(10, "Should go to comments for update")
    }
  }

  func testGroupedDatesWhenVoiceOverIsNotRunning() {
    let project = Project.template
    let activities = [.template |> Activity.lens.project .~ project]

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse: activities),
                    isVoiceOverRunning: const(false)) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()
      self.groupedDates.assertValues([true], "Group dates when voice over is not running")
    }
  }

  func testGroupedDatesWhenVoiceOverIsRunning() {
    let project = Project.template
    let activities = [.template |> Activity.lens.project .~ project]

    withEnvironment(apiService: MockService(fetchProjectActivitiesResponse: activities),
                    isVoiceOverRunning: const(true)) {
      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()
      self.groupedDates.assertValues([false], "Don't group dates when voice over is running")
    }
  }
}
