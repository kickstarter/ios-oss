import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude
import Result

// swiftlint:disable type_name
internal final class ProjectActivityNegativeStateChangeCellViewModelTests: TestCase {
  private let vm: ProjectActivityNegativeStateChangeCellViewModel =
    ProjectActivityNegativeStateChangeCellViewModel()

  private let backgroundImage = TestObserver<String?, NoError>()
  private let title = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backgroundImageURL.map { $0?.absoluteString }.observe(self.backgroundImage.observer)
    self.vm.outputs.title.observe(self.title.observer)
  }

  func testBackgroundImage() {
    let project = .template
      |> Project.lens.photo.med .~ "http://coolpic.com/cool.jpg"
      |> Project.lens.state .~ .failed
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.category .~ .failure

    self.vm.inputs.configureWith(activity: activity)
    self.backgroundImage.assertValues(["http://coolpic.com/cool.jpg"], "Emits project's image URL")
  }

  func testTitleForCancelledProject() {
    let projectName = "Sick Skull Graphic Lunchbox"
    let project = .template
      |> Project.lens.name .~ projectName
      |> Project.lens.state .~ .canceled
    let activity = .template
      |> Activity.lens.category .~ .cancellation
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)
    let expected = Strings.activity_project_state_change_project_was_cancelled_by_creator(
      project_name: projectName
    )
    self.title.assertValues([expected], "Emits title indicating the project was cancelled")
  }

  func testTitleForFailedProject() {
    let projectName = "Sick Skull Graphic Lunchbox"
    let project = .template
      |> Project.lens.name .~ projectName
      |> Project.lens.state .~ .failed
    let activity = .template
      |> Activity.lens.category .~ .failure
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)
    let expected = Strings.activity_project_state_change_project_was_not_successfully_funded(
      project_name: projectName
    )
    self.title.assertValues([expected], "Emits title indicating the project was not successfully funded")
  }

  func testTitleForSuspendedProject() {
    let projectName = "Sick Skull Graphic Lunchbox"
    let project = .template
      |> Project.lens.name .~ projectName
      |> Project.lens.state .~ .suspended
    let activity = .template
      |> Activity.lens.category .~ .suspension
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)
    let expected = Strings.activity_project_state_change_project_was_suspended(
      project_name: projectName
    )
    self.title.assertValues([expected], "Emits title indicating the project was suspended")
  }
}
// swiftlint:disable type_name
