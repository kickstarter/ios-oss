import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library

internal final class BackerDashboardProjectsViewControllerTests: TestCase {
  fileprivate var project1: Project!
  fileprivate var project2: Project!
  fileprivate var project3: Project!
  fileprivate var project4: Project!

  override func setUp() {
    super.setUp()

    let deadline = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 14.0
    let deadline2 = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 2.0

    let liveProject = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar • User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.stats.fundingProgress .~ 0.5

    let deadProject = Project.anomalisa
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar • User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ self.dateType.init().timeIntervalSince1970
      |> Project.lens.state .~ .successful

    let failed = Project.cosmicSurgery
      |> Project.lens.name .~ "A Failed Project about Mittens and Let's Just Go to the Next Line Shall We"
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar • User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ self.dateType.init().timeIntervalSince1970
      |> Project.lens.state .~ .failed

    let saved = Project.cosmicSurgery
      |> Project.lens.name .~ "A Saved Project, Very Nice Isn't It?"
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar • User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ deadline2
      |> Project.lens.stats.fundingProgress .~ 0.8
      |> Project.lens.personalization.isStarred .~ true

    self.project1 = liveProject
    self.project2 = deadProject
    self.project3 = failed
    self.project4 = saved

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testProjects() {
    let env = .template |> DiscoveryEnvelope.lens.projects .~ [self.project4, self.project1, self.project2,
                                                               self.project3]
    
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: MockService(fetchDiscoveryResponse: env),
                      currentUser: User.template,
                      language: language) {
        let controller = BackerDashboardProjectsViewController()
        controller.configureWith(delegate: BackerDashboardViewController(),
                                 projectsType: .backed,
                                 sort: .endingSoon)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()
        
        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
