@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class ProjectPamphletViewControllerTests: TestCase {
  private let user = User.brando
  private var project: Project = .cosmicSurgery

  override func setUp() {
    super.setUp()

    self.project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ "" // prevents flaky tests caused by async photo download
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.rewards %~ { rewards in
        [
          rewards[0]
            |> Reward.lens.startsAt .~ 0,
          rewards[2]
            |> Reward.lens.startsAt .~ 0
        ]
      }
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.stats.pledged .~ (Project.template.stats.goal * 3 / 4)

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  // MARK: - Logged In

  func testLoggedIn_Backer_LiveProject() {
    let config = Config.template
    let reward = Reward.template
      |> Reward.lens.title .~ "Magic Lamp"
    let backing = Backing.template
      |> Backing.lens.reward .~ reward
    let backedProject = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.state .~ .live
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchProjectResponse: backedProject),
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPamphletViewController.configuredWith(
          projectOrParam: .left(backedProject), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_Backer_NonLiveProject() {
    let config = Config.template
    let backedProject = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ .template
      |> Project.lens.state .~ .successful
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchProjectResponse: backedProject),
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPamphletViewController.configuredWith(
          projectOrParam: .left(backedProject), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_Backer_LiveProject_Error() {
    let config = Config.template
    let currentUser = User.template
    let backing = Backing.template
      |> Backing.lens.status .~ .errored
    let backedProject = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.state .~ .live

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchProjectResponse: backedProject),
        config: config, currentUser: currentUser, language: language
      ) {
        let vc = ProjectPamphletViewController.configuredWith(
          projectOrParam: .left(backedProject), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_Backer_NonLiveProject_Error() {
    let config = Config.template
    let currentUser = User.template
    let backing = Backing.template
      |> Backing.lens.status .~ .errored
    let backedProject = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.state .~ .successful

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchProjectResponse: backedProject),
        config: config, currentUser: currentUser, language: language
      ) {
        let vc = ProjectPamphletViewController.configuredWith(
          projectOrParam: .left(backedProject), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_NonBacker_NonLiveProject() {
    let config = Config.template
    let backedProject = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .successful
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchProjectResponse: backedProject),
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPamphletViewController.configuredWith(
          projectOrParam: .left(backedProject), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  // MARK: - Logged Out

  func testLoggedOut_NonBacker_LiveProject() {
    let config = Config.template

    let liveProject = self.project
      |> Project.lens.stats.convertedPledgedAmount .~ 1_964

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchProjectResponse: liveProject),
        config: config, currentUser: nil, language: language
      ) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(liveProject), refTag: nil)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedOut_NonBacker_NonLiveProject() {
    let config = Config.template
    let backedProject = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .successful
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchProjectResponse: backedProject),
        config: config, currentUser: nil, language: language
      ) {
        let vc = ProjectPamphletViewController.configuredWith(
          projectOrParam: .left(backedProject), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  // MARK: - Error fetching project

  func testProjectPamphletViewController_ErrorFetchingProject() {
    let config = Config.template

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchProjectError: .couldNotParseJSON),
        config: config,
        language: language
      ) {
        let vc = ProjectPamphletViewController.configuredWith(
          projectOrParam: .left(self.project),
          refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        if device == .pad {
          parent.view.frame.size.height = 2_300
        }

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
