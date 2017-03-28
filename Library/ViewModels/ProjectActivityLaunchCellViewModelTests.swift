import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library
import Prelude
import Result

internal final class ProjectActivityLaunchCellViewModelTests: TestCase {
  fileprivate let vm: ProjectActivityLaunchCellViewModelType = ProjectActivityLaunchCellViewModel()

  fileprivate let title = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.title.observe(self.title.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
  }

  func testTitle() {
    let country = Project.Country.US
    let goal = 5000
    let projectName = "Sick Skull Graphic Watch"
    let launchedAt = Date().timeIntervalSince1970

    let project = .template
      |> Project.lens.country .~ country
      |> Project.lens.dates.launchedAt .~ launchedAt
      |> Project.lens.name .~ projectName
      |> Project.lens.stats.goal .~ goal
    let activity = .template
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity, project: project)

    let expected = Strings.dashboard_activity_project_name_launched(
      project_name: projectName,
      launch_date: Format.date(secondsInUTC: launchedAt, dateStyle: .long, timeStyle: .none)
        .nonBreakingSpaced(),
      goal: Format.currency(goal, country: country).nonBreakingSpaced()
    )

    self.title.assertValues([expected], "Emits project's name, launch date, and goal")
  }
}
