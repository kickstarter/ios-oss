import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library

internal final class ProfileViewControllerTests: TestCase {
  private var project1: Project!
  private var project2: Project!
  private var project3: Project!

  override func setUp() {
    super.setUp()
    let deadline = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 14.0
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
      |> Project.lens.name .~ "A Failed Project About Mittens"
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar • User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ self.dateType.init().timeIntervalSince1970
      |> Project.lens.state .~ .failed

    self.project1 = liveProject
    self.project2 = deadProject
    self.project3 = failed

    AppEnvironment.pushEnvironment(mainBundle: NSBundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testBackedProjects() {
    let env = .template |> DiscoveryEnvelope.lens.projects .~ [self.project1, self.project2, self.project3]

    let user = .template
      |> User.lens.name .~ "Chuck Berry"
      |> User.lens.avatar.large .~ ""
      |> User.lens.stats.backedProjectsCount .~ 3
      |> User.lens.stats.createdProjectsCount .~ 1

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: MockService(fetchDiscoveryResponse: env, fetchUserSelfResponse: user),
        currentUser: user,
        language: language) {
          let controller = ProfileViewController.instantiate()
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.run()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}

