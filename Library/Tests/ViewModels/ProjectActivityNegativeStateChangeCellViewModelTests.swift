import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude
import Result

// swiftlint:disable type_name
internal final class ProjectActivityNegativeStateChangeCellViewModelTests: TestCase {
  fileprivate let vm: ProjectActivityNegativeStateChangeCellViewModel =
    ProjectActivityNegativeStateChangeCellViewModel()

  fileprivate let title = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.title.observe(self.title.observer)
  }

  func testTitleForCancelledProject() {
    let canceledAt = Date().timeIntervalSince1970
    let projectName = "Sick Skull Graphic Lunchbox"

    let project = .template
      |> Project.lens.name .~ projectName
      |> Project.lens.state .~ .canceled
    let activity = .template
      |> Activity.lens.category .~ .cancellation
      |> Activity.lens.createdAt .~ canceledAt
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_project_name_was_canceled(
      project_name: projectName,
      cancellation_date: Format.date(secondsInUTC: canceledAt, dateStyle: .long, timeStyle: .none)
        .nonBreakingSpaced()
    )
    self.title.assertValues([expected], "Emits title indicating the project was cancelled")
  }

  func testTitleForFailedProject() {
    let failedAt = Date().timeIntervalSince1970
    let projectName = "Sick Skull Graphic Lunchbox"

    let project = .template
      |> Project.lens.name .~ projectName
      |> Project.lens.state .~ .failed
    let activity = .template
      |> Activity.lens.category .~ .failure
      |> Activity.lens.createdAt .~ failedAt
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_project_name_was_unsuccessful(
      project_name: projectName,
      unsuccessful_date: Format.date(secondsInUTC: failedAt, dateStyle: .long, timeStyle: .none)
        .nonBreakingSpaced()
    )
    self.title.assertValues([expected], "Emits title indicating the project was unsuccessful")
  }

  func testTitleForSuspendedProject() {
    let suspendedAt = Date().timeIntervalSince1970
    let projectName = "Sick Skull Graphic Lunchbox"

    let project = .template
      |> Project.lens.name .~ projectName
      |> Project.lens.state .~ .suspended
    let activity = .template
      |> Activity.lens.category .~ .suspension
      |> Activity.lens.createdAt .~ suspendedAt
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.dashboard_activity_project_name_was_suspended(
      project_name: projectName,
      suspension_date: Format.date(secondsInUTC: suspendedAt, dateStyle: .long, timeStyle: .none)
        .nonBreakingSpaced()
    )
    self.title.assertValues([expected], "Emits title indicating the project was suspended")
  }
}
// swiftlint:disable type_name
