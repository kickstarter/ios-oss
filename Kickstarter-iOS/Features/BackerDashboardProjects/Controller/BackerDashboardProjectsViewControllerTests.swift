@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
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
    let deadline = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 14.0
    let deadline2 = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 2.0

    let liveProject = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.stats.fundingProgress .~ 0.5

    let deadProject = Project.anomalisa
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ self.dateType.init().timeIntervalSince1970
      |> Project.lens.state .~ .successful

    let failed = Project.cosmicSurgery
      |> Project.lens.name .~ "A Failed Project about Mittens and Let's Just Go to the Next Line Shall We"
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ self.dateType.init().timeIntervalSince1970
      |> Project.lens.stats.fundingProgress .~ 0.45
      |> Project.lens.state .~ .failed

    let saved = Project.cosmicSurgery
      |> Project.lens.name .~ "A Saved Project, Very Nice Isn't It?"
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ deadline2
      |> Project.lens.stats.fundingProgress .~ 0.8
      |> Project.lens.personalization.isStarred .~ true

    let env = FetchProjectsEnvelope(
      type: .backed,
      projects: [saved, liveProject, deadProject, failed],
      hasNextPage: true,
      totalCount: 5
    )

    let darkModeOn = MockRemoteConfigClient()
    darkModeOn.features = [
      RemoteConfigFeature.darkModeEnabled.rawValue: true,
      RemoteConfigFeature.newDesignSystem.rawValue: true
    ]

    orthogonalCombos(
      Language.allLanguages,
      [Device.phone4_7inch, Device.phone5_8inch, Device.pad],
      [UIUserInterfaceStyle.light, UIUserInterfaceStyle.dark]
    ).forEach {
      language, device, style in
      withEnvironment(
        apiService: MockService(fetchBackerBackedProjectsResponse: env),
        colorResolver: AppColorResolver(),
        currentUser: User.template,
        language: language,
        remoteConfigClient: darkModeOn
      ) {
        let controller = BackerDashboardProjectsViewController
          .configuredWith(projectsType: .backed, sort: .endingSoon)
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
    let env = FetchProjectsEnvelope(type: .backed, projects: [], hasNextPage: false, totalCount: 0)
    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: MockService(fetchBackerBackedProjectsResponse: env),
        currentUser: User.template,
        language: language
      ) {
        let controller = BackerDashboardProjectsViewController
          .configuredWith(projectsType: .backed, sort: .endingSoon)
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
    let env = FetchProjectsEnvelope(type: .saved, projects: [], hasNextPage: false, totalCount: 0)
    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: MockService(fetchBackerSavedProjectsResponse: env),
        currentUser: User.template,
        language: language
      ) {
        let controller = BackerDashboardProjectsViewController
          .configuredWith(projectsType: .saved, sort: .endingSoon)
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
