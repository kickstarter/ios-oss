import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library
import Prelude
import Result

internal final class ProjectActivityUpdateCellViewModelTests: TestCase {
  fileprivate let vm: ProjectActivityUpdateCellViewModelType = ProjectActivityUpdateCellViewModel()

  fileprivate let activityTitle = TestObserver<String, NoError>()
  fileprivate let body = TestObserver<String, NoError>()
  fileprivate let cellAccessibilityLabel = TestObserver<String, NoError>()
  fileprivate let cellAccessibilityValue = TestObserver<String, NoError>()
  fileprivate let commentsCount = TestObserver<String, NoError>()
  fileprivate let defaultUser = .template |> User.lens.name .~ "Christopher"
  fileprivate let likesCount = TestObserver<String, NoError>()
  fileprivate let updateTitle = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityTitle.observe(self.activityTitle.observer)
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.cellAccessibilityLabel.observe(self.cellAccessibilityLabel.observer)
    self.vm.outputs.cellAccessibilityValue.observe(self.cellAccessibilityValue.observer)
    self.vm.outputs.commentsCount.observe(self.commentsCount.observer)
    self.vm.outputs.likesCount.observe(self.likesCount.observer)
    self.vm.outputs.updateTitle.observe(self.updateTitle.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: self.defaultUser))
  }

  func testActivityTitle() {
    let project = Project.template
    let publishedAt = Date().timeIntervalSince1970
    let update = .template
      |> Update.lens.publishedAt .~ publishedAt
      |> Update.lens.sequence .~ 9
      |> Update.lens.user .~ self.defaultUser
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_update_number_posted_time_count_days_ago(
      space: "\u{00a0}",
      update_number: "9",
      time_count_days_ago: Format.relative(secondsInUTC: publishedAt)
    )
    self.activityTitle.assertValues([expected], "Emits activity's title")
  }

  func testBody() {
    let body = "We've reached our funding goal, thanks y'all!"
    let project = Project.template
    let update = .template
      |> Update.lens.body .~ body
    let activity = .template
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.body.assertValues([body], "Emits update's body")
  }

  func testBodyIsStrippedOfHtml() {
    let project = Project.template
    let update = .template
      |> Update.lens.body .~ "<b>Oh yeah!</b>"
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.body.assertValues(["Oh yeah!"], "Emits update's body, with HTML stripped")
  }

  func testCellAccessibilityLabel() {
    let project = Project.template
    let publishedAt = Date().timeIntervalSince1970
    let update = .template
      |> Update.lens.publishedAt .~ publishedAt
      |> Update.lens.sequence .~ 9
      |> Update.lens.user .~ self.defaultUser
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = (Strings.dashboard_activity_update_number_posted_time_count_days_ago(
        space: "\u{00a0}",
        update_number: "9",
        time_count_days_ago: Format.relative(secondsInUTC: publishedAt)
      )
      .htmlStripped() ?? "")
    self.cellAccessibilityLabel.assertValues([expected], "Emits accessibility label")
  }

  func testCellAccessibilityValue() {
    let title = "Spirit animals!"
    let project = Project.template
    let update = .template
      |> Update.lens.title .~ title
    let activity = .template
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.cellAccessibilityValue.assertValues([title], "Emits accessibility value")
  }

  func testCommentsCount() {
    let project = Project.template
    let update = .template
      |> Update.lens.commentsCount .~ 50
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.commentsCount.assertValues([Format.wholeNumber(50)], "Emits number of comments")
  }

  func testLikesCount() {
    let project = Project.template
    let update = .template
      |> Update.lens.likesCount .~ 25
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.likesCount.assertValues([Format.wholeNumber(25)], "Emits number of likes")
  }

  func testUpdateTitle() {
    let project = Project.template
    let update = .template
      |> Update.lens.title .~ "Great news!"
    let activity = .template
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.updateTitle.assertValues(["Great news!"], "Emits update's title")
  }
}
