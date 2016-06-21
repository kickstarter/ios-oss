import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library
import Prelude
import Result

internal final class ProjectActivityUpdateCellViewModelTests: TestCase {
  private let vm: ProjectActivityUpdateCellViewModelType = ProjectActivityUpdateCellViewModel()

  private let activityTitle = TestObserver<String?, NoError>()
  private let authorImage = TestObserver<String?, NoError>()
  private let authorIsHidden = TestObserver<Bool, NoError>()
  private let authorName = TestObserver<String?, NoError>()
  private let defaultUser = .template |> User.lens.name .~ "Christopher"
  private let updateTitle = TestObserver<String?, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityTitle.observe(self.activityTitle.observer)
    self.vm.outputs.authorImageURL.map { $0?.absoluteString }.observe(self.authorImage.observer)
    self.vm.outputs.authorIsHidden.observe(self.authorIsHidden.observer)
    self.vm.outputs.authorName.observe(self.authorName.observer)
    self.vm.outputs.updateTitle.observe(self.updateTitle.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: self.defaultUser))
  }

  func testActivityTitle() {
    let update = .template
      |> Update.lens.sequence .~ 9
      |> Update.lens.user .~ self.defaultUser
    let activity = .template
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity)
    self.activityTitle.assertValues(
      [
        Strings.activity_creator_actions_user_name_posted_update_number(
          user_name: Strings.activity_creator_you(),
          update_number: "9"
        )
      ], "Emits activity's title")
  }

  func testAuthorImage() {
    let user = .template
      |> User.lens.avatar.medium .~ "http://coolpic.com/cool.jpg"

    let activity = .template
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity)
    self.authorImage.assertValues(["http://coolpic.com/cool.jpg"], "Emits author's image URL")
  }

  func testAuthorWhenAuthorIsCurrentUser() {

    let update = .template
      |> Update.lens.user .~ self.defaultUser
    let activity = .template
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity)
    self.authorName.assertValues([Strings.activity_creator_you()], "Emits 'You' if current user is author.")
    self.authorIsHidden.assertValues([false], "Show author if same as current user")
  }

  func testAuthorWhenAuthorIsNotCurrentUser() {
    let user = .template
      |> User.lens.id .~ 9
      |> User.lens.name .~ "Tiegz"

    let update = .template
      |> Update.lens.user .~ user
    let activity = .template
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity)
    self.authorName.assertValues(["Tiegz"], "Emits author's name if not current user")
    self.authorIsHidden.assertValues([true], "Hide author if not current user")
  }

  func testAuthorWhenCellIsReused() {

    let user = User.template
    withEnvironment(currentUser: user) {
      let tiegz = .template
        |> User.lens.id .~ 9
        |> User.lens.name .~ "Tiegz"

      let update = .template
        |> Update.lens.user .~ user
      let activity = .template
        |> Activity.lens.update .~ update

      self.vm.inputs.configureWith(activity: activity)
      self.authorName.assertValues([Strings.activity_creator_you()], "Emits 'You' if current user is author.")
      self.authorIsHidden.assertValues([false], "Show author if same as current user")

      let otherUpdate = .template
        |> Update.lens.user .~ (tiegz)
      let otherActivity = .template
        |> Activity.lens.update .~ otherUpdate

      self.vm.inputs.configureWith(activity: otherActivity)

      self.authorName.assertValues(
        [Strings.activity_creator_you(), "Tiegz"],
        "Emits author's name if not current user.")
      self.authorIsHidden.assertValues([false, true], "Hide author if not current user")

      self.vm.inputs.configureWith(activity: activity)

      self.authorName.assertValues([
        Strings.activity_creator_you(), "Tiegz", Strings.activity_creator_you()],
        "Emits 'You' if current user is author")
      self.authorIsHidden.assertValues([false, true, false], "Show author if same as current user")
    }
  }

  func testUpdateTitle() {
    let update = .template
      |> Update.lens.title .~ "Great news!"

    let activity = .template
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity)
    self.updateTitle.assertValues(["Great news!"], "Emits update's title")
  }
}
