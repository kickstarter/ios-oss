import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude
import Result

internal final class ProjectActivityCommentCellViewModelTests: TestCase {
  private let vm: ProjectActivityCommentCellViewModelType = ProjectActivityCommentCellViewModel()

  private let authorImage = TestObserver<String?, NoError>()
  private let body = TestObserver<String, NoError>()
  private let defaultUser = .template |> User.lens.id .~ 9
  private let notifyDelegateGoToBacking = TestObserver<(Project, User), NoError>()
  private let notifyDelegateGoToSendReplyOnProject = TestObserver<(Project, Comment), NoError>()
  private let notifyDelegateGoToSendReplyOnUpdate = TestObserver<(Update, Comment), NoError>()
  private let title = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.authorImageURL.map { $0?.absoluteString }.observe(self.authorImage.observer)
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.notifyDelegateGoToBacking.observe(self.notifyDelegateGoToBacking.observer)
    self.vm.outputs.notifyDelegateGoToSendReplyOnProject
      .observe(self.notifyDelegateGoToSendReplyOnProject.observer)
    self.vm.outputs.notifyDelegateGoToSendReplyOnUpdate
      .observe(self.notifyDelegateGoToSendReplyOnUpdate.observer)
    self.vm.outputs.title.observe(self.title.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: self.defaultUser))
  }

  func testAuthorImage() {
    let project = Project.template
    let user = .template
      |> User.lens.avatar.medium .~ "http://coolpic.com/cool.jpg"
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.authorImage.assertValues(["http://coolpic.com/cool.jpg"], "Emits author's image URL")
  }

  func testBody() {
    let project = Project.template
    let body1 = "Thanks for the update!"
    let commentPostActivity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.comment .~ (.template |> Comment.lens.body .~ body1)
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: commentPostActivity, project: project)
    self.body.assertValues([body1], "Emits post comment's body")

    let body2 = "Aw, the limited bundle is all gone!"
    let commentProjectActivity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.comment .~ (.template |> Comment.lens.body .~ body2)
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: commentProjectActivity, project: project)
    self.body.assertValues([body1, body2], "Emits project comment's body")
  }

  func testNotifyDelegateGoToBacking() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.project .~ project

      self.vm.inputs.configureWith(activity: activity, project: project)
      self.vm.inputs.backingButtonPressed()
      self.notifyDelegateGoToBacking.assertValueCount(1, "Should go to backing")
  }

  func testNotifyDelegateGoToSendReplyOnProject() {
    let project = Project.template
    let user = User.template |> User.lens.name .~ "Christopher"
    let activity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.comment .~ .template
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.vm.inputs.replyButtonPressed()
    self.notifyDelegateGoToSendReplyOnProject.assertValueCount(1, "Should go to send reply on project")
  }

  func testNotifyDelegateGoToSendReplyOnUpdate() {
    let project = Project.template
    let update = Update.template
    let user = User.template |> User.lens.name .~ "Christopher"
    let activity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.comment .~ .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.vm.inputs.replyButtonPressed()
    self.notifyDelegateGoToSendReplyOnUpdate.assertValueCount(1, "Should go to send reply on update")
  }

  func testTitleProject() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.comment .~ (.template |> Comment.lens.body .~ "Love this project!")
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ (.template |> User.lens.name .~ "Christopher")

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_user_name_commented_on_your_project(user_name: "Christopher")
    self.title.assertValues([expected], "Should emit that author commented on project")
  }

  func testTitleProjectAsCurrentUser() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .commentProject
      |> Activity.lens.comment .~ (.template |> Comment.lens.body .~ "Love this project!")
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ self.defaultUser

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_you_commented_on_your_project()
    self.title.assertValues([expected], "Should emit 'you' commented on project")
  }

  func testTitleUpdate() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.comment .~ (.template |> Comment.lens.body .~ "Good update!")
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ (.template |> Update.lens.sequence .~ 5)
      |> Activity.lens.user .~ (.template |> User.lens.name .~ "Christopher")

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_user_name_commented_on_update_number(
      user_name: "Christopher",
      space: "\u{00a0}",
      update_number: "5"
    )
    self.title.assertValues([expected], "Should emit that author commented on update")
  }

  func testTitleUpdateAsCurrentUser() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .commentPost
      |> Activity.lens.comment .~ (.template |> Comment.lens.body .~ "Good update!")
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ (.template |> Update.lens.sequence .~ 5)
      |> Activity.lens.user .~ self.defaultUser

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_you_commented_on_update_number(
      space: "\u{00a0}",
      update_number: "5"
    )
    self.title.assertValues([expected], "Should emit 'you' commented on update")
  }
}
