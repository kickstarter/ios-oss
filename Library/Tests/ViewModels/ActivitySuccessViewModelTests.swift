import Prelude
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class ActivitySuccessViewModelTests: TestCase {
  private let vm: ActivitySuccessViewModelType = ActivitySuccessViewModel()
  private let fundingDate = TestObserver<String, NoError>()
  private let projectImageURL = TestObserver<String?, NoError>()
  private let projectName = TestObserver<String, NoError>()
  private let pledgedSubtitle = TestObserver<String, NoError>()
  private let pledgedTitle = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.fundingDate.observe(self.fundingDate.observer)
    self.vm.outputs.projectImageURL.map { $0?.absoluteString }.observe(self.projectImageURL.observer)
    self.vm.outputs.projectName.observe(self.projectName.observer)
    self.vm.outputs.pledgedSubtitle.observe(self.pledgedSubtitle.observer)
    self.vm.outputs.pledgedTitle.observe(self.pledgedTitle.observer)
  }

  func testProjectDataEmits() {
    let project = Project.template

    let activity = .template
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)

    self.fundingDate.assertValues([Format.date(secondsInUTC: project.dates.stateChangedAt,
      dateStyle: .MediumStyle, timeStyle: .NoStyle)])
    self.projectImageURL.assertValues([project.photo.full])
    self.projectName.assertValues([Strings.activity_project_state_change_project_was_successfully_funded(
      project_name: project.name)])
    self.pledgedSubtitle.assertValues([Strings.activity_project_state_change_pledged_of_goal(
      goal: Format.currency(project.stats.goal, country: project.country))])
    self.pledgedTitle.assertValues([Format.currency(project.stats.pledged, country: project.country)])
  }
}
