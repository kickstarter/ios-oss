import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import SnapshotTesting
import XCTest

internal final class BackerDashboardProjectsViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testProjects() {
    let deadline = Int(self.dateType.init().timeIntervalSince1970) + 60 * 60 * 24 * 14
    let deadlineSaved = Int(self.dateType.init().timeIntervalSince1970) + 60 * 60 * 2

    let mock = GraphAPI.ProjectCardFragment.mockProjectsConnectionQuery(numberOfProjects: 4)

    mock.projects?.nodes?[0]?.name = "A Saved Project, Very Nice Isn't It?"
    mock.projects?.nodes?[0]?.deadlineAt = "\(deadlineSaved)"
    mock.projects?.nodes?[0]?.percentFunded = 80
    mock.projects?.nodes?[0]?.isWatched = true

    mock.projects?.nodes?[1]?.name = "Cosmic Surgery"
    mock.projects?.nodes?[1]?.percentFunded = 50
    mock.projects?.nodes?[1]?.deadlineAt = "\(deadline)"

    mock.projects?.nodes?[2]?.name = "Charlie Kaufman's Anomalisa"
    mock.projects?.nodes?[2]?.percentFunded = 202
    mock.projects?.nodes?[2]?.state = .case(.successful)

    mock.projects?.nodes?[3]?
      .name = "A Failed Project about Mittens and Let's Just Go to the Next Line Shall We"
    mock.projects?.nodes?[3]?.percentFunded = 45
    mock.projects?.nodes?[3]?.state = .case(.failed)

    let response = GraphAPI.FetchMyBackedProjectsQuery.Data.from(mock)

    orthogonalCombos(
      Language.allLanguages,
      [Device.phone4_7inch, Device.phone5_8inch, Device.pad],
      [UIUserInterfaceStyle.light, UIUserInterfaceStyle.dark]
    ).forEach {
      language, device, style in
      withEnvironment(
        apiService: MockService(fetchBackerBackedProjectsResponse: response),
        currentUser: User.template,
        language: language
      ) {
        let controller = BackerDashboardProjectsViewController
          .configuredWith(projectsType: .backed)
        controller.overrideUserInterfaceStyle = style
        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )
        self.scheduler.run()

        let styleDescription = style == .light ? "light" : "dark"

        assertSnapshot(
          matching: parent.view,
          as: .image,
          named: "lang_\(language)_device_\(device)_\(styleDescription)"
        )
      }
    }
  }

  func testEmpty_BackedProjects() {
    let mock = GraphAPI.ProjectCardFragment.mockProjectsConnectionQuery(numberOfProjects: 0)
    let response = GraphAPI.FetchMyBackedProjectsQuery.Data.from(mock)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: MockService(fetchBackerBackedProjectsResponse: response),
        currentUser: User.template,
        language: language
      ) {
        let controller = BackerDashboardProjectsViewController
          .configuredWith(projectsType: .backed)
        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )
        self.scheduler.run()

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testEmpty_SavedProjects() {
    let mock = GraphAPI.ProjectCardFragment.mockProjectsConnectionQuery(numberOfProjects: 0)
    let response = GraphAPI.FetchMySavedProjectsQuery.Data.from(mock)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: MockService(fetchBackerSavedProjectsResponse: response),
        currentUser: User.template,
        language: language
      ) {
        let controller = BackerDashboardProjectsViewController
          .configuredWith(projectsType: .saved)
        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )
        self.scheduler.run()

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }
}
