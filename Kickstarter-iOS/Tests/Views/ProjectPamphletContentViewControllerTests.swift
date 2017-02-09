// swiftlint:disable type_name
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
@testable import LiveStream

internal final class ProjectPamphletContentViewControllerTests: TestCase {
  fileprivate var cosmicSurgery: Project!

  override func setUp() {
    super.setUp()
    let deadline = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 14.0
    let launchedAt = self.dateType.init().timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 14.0
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar • User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.dates.launchedAt .~ launchedAt

    self.cosmicSurgery = project

    AppEnvironment.pushEnvironment(
      config: .template |> Config.lens.countryCode .~ self.cosmicSurgery.country.countryCode,
      mainBundle: Bundle.framework
    )

    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testAllCategoryGroups() {

    let project = self.cosmicSurgery
      |> Project.lens.rewards .~ [self.cosmicSurgery.rewards.first!]
      |> Project.lens.state .~ .live

    let categories = [Category.art, Category.filmAndVideo, Category.games]
    let devices = [Device.phone4_7inch, Device.pad]

    combos(categories, devices).forEach { category, device in
      let categorizedProject = project |> Project.lens.category .~ category
      let vc = ProjectPamphletViewController.configuredWith(
        projectOrParam: .left(categorizedProject), refTag: nil
      )
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
      parent.view.frame.size.height = device == .pad ? 1_400 : 1_000

      FBSnapshotVerifyView(
        parent.view, identifier: "category_\(category.slug)_device_\(device)", tolerance: 0.0001
      )
    }
  }

  func testNonBacker_LiveProject() {
    let project = self.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3/4)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 2_300 : 2_200

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)", tolerance: 0.0001)
      }
    }
  }

  func testNonBacker_SuccessfulProject() {
    let deadline = self.dateType.init().addingTimeInterval(-100).timeIntervalSince1970

    let project = self.cosmicSurgery
      |> Project.lens.dates.stateChangedAt .~ deadline
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.state .~ .successful

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 1_750

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)", tolerance: 0.0001)
      }
    }
  }

  func testBacker_LiveProject() {
    let endsAt = AppEnvironment.current.dateType.init()
      .addingTimeInterval(60*60*24*3)
      .timeIntervalSince1970

    let project = self.cosmicSurgery
      |> Project.lens.rewards %~ { rewards in
        [
          rewards[0]
            |> Reward.lens.startsAt .~ 0
            |> Reward.lens.endsAt .~ endsAt,
          rewards[2]
            |> Reward.lens.startsAt .~ 0
            |> Reward.lens.endsAt .~ 0
        ]
      }
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3/4)
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing %~~ { _, project in
        .template
          |> Backing.lens.amount .~ (project.rewards.first!.minimum + 5)
          |> Backing.lens.rewardId .~ project.rewards.first?.id
          |> Backing.lens.reward .~ project.rewards.first
    }

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {

        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_600 : 1_350

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)", tolerance: 0.0001)
      }
    }
  }

  func testBacker_LiveProject_NoReward() {
    let project = self.cosmicSurgery
      |> Project.lens.rewards %~ { rewards in [rewards[0]] }
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing %~~ { _, project in
        .template
          |> Backing.lens.amount .~ 5
          |> Backing.lens.rewardId .~ nil
          |> Backing.lens.reward .~ nil
    }

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchProjectResponse: project), language: language) {

        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 1_200

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)", tolerance: 0.0001)
      }
    }
  }

  func testBacker_SuccessfulProject() {
    let deadline = self.dateType.init().addingTimeInterval(-100).timeIntervalSince1970

    let backing = .template
      |> Backing.lens.amount .~ (self.cosmicSurgery.rewards.first!.minimum + 5)
      |> Backing.lens.rewardId .~ self.cosmicSurgery.rewards.first?.id
      |> Backing.lens.reward .~ self.cosmicSurgery.rewards.first

    let project = self.cosmicSurgery
      |> Project.lens.rewards %~ { rewards in [rewards[0], rewards[2]] }
      |> Project.lens.dates.stateChangedAt .~ deadline
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {

        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_600 : 1_350

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)", tolerance: 0.0001)
      }
    }
  }

  func testBackerOfSoldOutReward() {
    let soldOutReward = self.cosmicSurgery.rewards.filter { $0.remaining == 0 }.first!
    let project = self.cosmicSurgery
      |> Project.lens.rewards .~ [soldOutReward]
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3/4)
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing %~~ { _, project in
        .template
          |> Backing.lens.amount .~ (project.rewards.first!.minimum + 5)
          |> Backing.lens.rewardId .~ project.rewards.first?.id
          |> Backing.lens.reward .~ project.rewards.first
    }

    let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
    parent.view.frame.size.height = 1_000

    FBSnapshotVerifyView(vc.view, tolerance: 0.0001)
  }

  func testFailedProject() {
    let project = self.cosmicSurgery
      |> Project.lens.dates.stateChangedAt .~ 1234567890.0
      |> Project.lens.state .~ .failed

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 1_700

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)", tolerance: 0.0001)
      }
    }
  }

  func testMinimalProjectRendering() {
    let project = self.cosmicSurgery!

    [Device.phone4_7inch, Device.pad].forEach { device in
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
      let (parent, _) = traitControllers(
        device: device, orientation: .portrait, child: vc, handleAppearanceTransition: false
      )

      parent.beginAppearanceTransition(true, animated: true)

      FBSnapshotVerifyView(vc.view, identifier: "device_\(device)")
    }
  }

  func testMinimalAndFullProjectOverlap() {
    let project = self.cosmicSurgery!

    withEnvironment(apiService: MockService(fetchProjectResponse: project)) {
      [Device.phone4_7inch, Device.pad].forEach { device in
        let minimal = ProjectPamphletViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )
        let (minimalParent, _) = traitControllers(
          device: device, orientation: .portrait, child: minimal, handleAppearanceTransition: false
        )
        let full = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (fullParent, _) = traitControllers(
          device: device, orientation: .portrait, child: full, handleAppearanceTransition: false
        )

        minimalParent.beginAppearanceTransition(true, animated: true)

        fullParent.beginAppearanceTransition(true, animated: true)
        fullParent.endAppearanceTransition()

        let snapshotView = UIView(frame: fullParent.view.frame)
        fullParent.view.alpha = 0.5
        minimalParent.view.alpha = 0.5
        snapshotView.addSubview(fullParent.view)
        snapshotView.addSubview(minimalParent.view)

        self.scheduler.advance()

        FBSnapshotVerifyView(snapshotView, identifier: "device_\(device)")
      }
    }
  }

  func testNonBacker_LiveProject_WithLiveStreams() {
    let currentlyLiveStream = .template
      |> LiveStreamEvent.lens.id .~ 1
      |> LiveStreamEvent.lens.liveNow .~ true

    let futureLiveStream = .template
      |> LiveStreamEvent.lens.id .~ 2
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(60 * 60 * 24 * 2).date

    let pastLiveStream = .template
      |> LiveStreamEvent.lens.id .~ 3
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60 * 60 * 12).date

    let project = self.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.rewards .~ []

    let envelope = LiveStreamEventsEnvelope(numberOfLiveStreams: 3,
                                            liveStreamEvents: [
                                              currentlyLiveStream,
                                              futureLiveStream,
                                              pastLiveStream])

    let liveService = MockLiveStreamService(fetchEventsForProjectResult: Result(envelope))
    let apiService = MockService(fetchProjectResponse: project)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: apiService, language: language, liveStreamService: liveService) {

        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_044 : 800
        self.scheduler.advance()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)", tolerance: 0.0001)
      }
    }
  }
}
