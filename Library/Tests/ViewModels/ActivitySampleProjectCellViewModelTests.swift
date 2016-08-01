import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class ActivitySampleProjectCellViewModelTests: TestCase {
  internal let vm = ActivitySampleProjectCellViewModel()
  internal let goToActivity = TestObserver<Void, NoError>()
  internal let projectSubtitleText = TestObserver<String, NoError>()
  internal let projectTitleText = TestObserver<String, NoError>()
  internal let projectImage = TestObserver<String?, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToActivity.observe(self.goToActivity.observer)
    self.vm.outputs.projectImageURL.map { $0?.absoluteString }.observe(self.projectImage.observer)
    self.vm.outputs.projectSubtitleText.observe(self.projectSubtitleText.observer)
    self.vm.outputs.projectTitleText.observe(self.projectTitleText.observer)
  }

  func testGoToActivity() {
    let activity = Activity.template

    self.vm.inputs.configureWith(activity: activity)
    self.vm.inputs.seeAllActivityTapped()

    self.goToActivity.assertValueCount(1)
  }

  func testProjectCancellationActivity() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .cancellation
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)

    self.projectImage.assertValues([project.photo.med])
    self.projectSubtitleText.assertValues([Strings.activity_funding_canceled()])
    self.projectTitleText.assertValues([project.name])
  }

  func testProjectFailureActivity() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .failure
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)

    self.projectImage.assertValues([project.photo.med])
    self.projectSubtitleText.assertValues([Strings.activity_project_was_not_successfully_funded()])
    self.projectTitleText.assertValues([project.name])
  }

  func testProjectLaunchActivity() {
    let user = User.template
    let project = Project.template |> Project.lens.creator .~ user
    let activity = .template
      |> Activity.lens.category .~ .launch
      |> Activity.lens.user .~ user
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)

    self.projectImage.assertValues([project.photo.med])
    self.projectSubtitleText.assertValues(
      [Strings.activity_user_name_launched_project(user_name: user.name)]
    )
    self.projectTitleText.assertValues([project.name])
  }

  func testProjectSuccessActivity() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .success
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)

    self.projectImage.assertValues([project.photo.med])
    self.projectSubtitleText.assertValues([Strings.activity_successfully_funded()])
    self.projectTitleText.assertValues([project.name])
  }

  func testProjectUpdateActivity() {
    let project = .template
      |> Project.lens.name .~ "Socks for Goats"
      |> Project.lens.photo.med .~ "http://goats.jpg"

    let update = .template
      |> Update.lens.sequence .~ 42
      |> Update.lens.title .~ "In production!"

    let activity = .template
      |> Activity.lens.category .~ .update
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity)
    self.projectImage.assertValues([project.photo.med])
    self.projectTitleText.assertValues([project.name])
    self.projectSubtitleText.assertValues(
      [Strings.activity_posted_update_number_title(update_number: Format.wholeNumber(update.sequence),
                                                   update_title: update.title)]
    )
  }
}
