@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class ProjectActivitySuccessViewModelTests: TestCase {
  fileprivate let vm: ProjectActivitySuccessCellViewModelType = ProjectActivitySuccessCellViewModel()

  fileprivate let backgroundImage = TestObserver<String?, Never>()
  fileprivate let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backgroundImageURL.map { $0?.absoluteString }.observe(self.backgroundImage.observer)
    self.vm.outputs.title.observe(self.title.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
  }

  func testBackgroundImage() {
    let project = .template
      |> Project.lens.photo.med .~ "http://coolpic.com/cool.jpg"
      |> Project.lens.state .~ .successful
    let activity = .template
      |> Activity.lens.category .~ .success
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.backgroundImage.assertValues(["http://coolpic.com/cool.jpg"], "Emits project's image URL")
  }

  func testTitle() {
    let country = Project.Country.us
    let backersCount = 12_345
    let deadline = Date().timeIntervalSince1970
    let pledged = 5_000

    let project = .template
      |> Project.lens.country .~ country
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.state .~ .successful
      |> Project.lens.stats.backersCount .~ backersCount
      |> Project.lens.stats.pledged .~ pledged
    let activity = .template
      |> Activity.lens.category .~ .success
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity, project: project)

    let expected = Strings.dashboard_activity_successfully_raised_pledged(
      pledged: Format.currency(pledged, country: country).nonBreakingSpaced(),
      backers: Strings.general_backer_count_backers(backer_count: project.stats.backersCount)
        .nonBreakingSpaced(),
      deadline: Format.date(secondsInUTC: deadline, dateStyle: .long, timeStyle: .none)
        .nonBreakingSpaced()
    )

    self.title.assertValues([expected], "Emits title with the pledged amount, backers, date of success")
  }
}
