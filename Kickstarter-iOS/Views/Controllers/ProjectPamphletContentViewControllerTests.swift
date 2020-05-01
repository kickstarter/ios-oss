@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class ProjectPamphletContentViewControllerTests: TestCase {
  fileprivate var cosmicSurgery: Project!

  override func setUp() {
    super.setUp()
    let deadline = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 14.0
    let launchedAt = self.dateType.init().timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 14.0
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.dates.launchedAt .~ launchedAt
      |> Project.lens.stats.convertedPledgedAmount .~ 21_615

    self.cosmicSurgery = project

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)

    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testNonBacker_LiveProject() {
    let project = self.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3 / 4)

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: mockService, language: language, locale: .init(identifier: language.rawValue)
      ) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : 900

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testNonBacker_LiveProject_CreatorDetailsExperiment() {
    let project = self.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3 / 4)

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageConversionCreatorDetails.rawValue: OptimizelyExperiment
          .Variant.variant1.rawValue
      ]

    combos(Language.allLanguages, [Device.phone4_7inch]).forEach {
      language, device in
      withEnvironment(
        apiService: mockService,
        language: language,
        locale: .init(identifier: language.rawValue),
        optimizelyClient: optimizelyClient
      ) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : 900

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)", overallTolerance: 0.01)
      }
    }
  }

  func testNonBacker_SuccessfulProject() {
    let deadline = self.dateType.init().addingTimeInterval(-100).timeIntervalSince1970

    let project = self.cosmicSurgery
      |> Project.lens.dates.stateChangedAt .~ deadline
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.state .~ .successful
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    Language.allLanguages.forEach { language in
      withEnvironment(
        apiService: mockService, language: language, locale: .init(identifier: language.rawValue)
      ) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 900

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")
      }
    }
  }

  func testBacker_LiveProject() {
    let endsAt = AppEnvironment.current.dateType.init()
      .addingTimeInterval(60 * 60 * 24 * 3)
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
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3 / 4)
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing %~~ { _, project in
        .template
          |> Backing.lens.amount .~ (project.rewards.first!.minimum + 5.00)
          |> Backing.lens.rewardId .~ project.rewards.first?.id
          |> Backing.lens.reward .~ project.rewards.first
      }

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: mockService, language: language, locale: .init(identifier: language.rawValue)
      ) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : 900

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testBacker_LiveProject_NoReward() {
    let project = self.cosmicSurgery
      |> Project.lens.rewards %~ { rewards in [rewards[0]] }
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.personalization.backing %~~ { _, _ in
        .template
          |> Backing.lens.amount .~ 5.0
          |> Backing.lens.rewardId .~ nil
          |> Backing.lens.reward .~ nil
      }

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    Language.allLanguages.forEach { language in
      withEnvironment(
        apiService: mockService,
        language: language,
        locale: .init(identifier: language.rawValue)
      ) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 900

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")
      }
    }
  }

  func testBacker_SuccessfulProject() {
    let deadline = self.dateType.init().addingTimeInterval(-100).timeIntervalSince1970

    let backing = .template
      |> Backing.lens.amount .~ (self.cosmicSurgery.rewards.first!.minimum + 5.00)
      |> Backing.lens.rewardId .~ self.cosmicSurgery.rewards.first?.id
      |> Backing.lens.reward .~ self.cosmicSurgery.rewards.first

    let project = self.cosmicSurgery
      |> Project.lens.rewards %~ { rewards in [rewards[0], rewards[2]] }
      |> Project.lens.dates.stateChangedAt .~ deadline
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: mockService, language: language, locale: .init(identifier: language.rawValue)
      ) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : 900

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testBackerOfSoldOutReward() {
    guard let soldOutReward = self.cosmicSurgery.rewards.first(where: { $0.remaining == 0 }) else {
      XCTFail("Should have a sold out reward")
      return
    }
    let project = self.cosmicSurgery
      |> Project.lens.rewards .~ [soldOutReward]
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3 / 4)
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing %~~ { _, project in
        .template
          |> Backing.lens.amount .~ (project.rewards.first!.minimum + 5.00)
          |> Backing.lens.rewardId .~ project.rewards.first?.id
          |> Backing.lens.reward .~ project.rewards.first
      }

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    withEnvironment(apiService: mockService) {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
      let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height = 900

      self.scheduler.run()

      FBSnapshotVerifyView(vc.view)
    }
  }

  func testCreator_LiveProject() {
    let user = User.template
    let project = self.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.creator .~ user

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: user,
        language: language,
        locale: .init(identifier: language.rawValue)
      ) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : 900

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testCreator_NonLiveProject() {
    let user = User.template
    let project = self.cosmicSurgery
      |> Project.lens.state .~ .successful
      |> Project.lens.creator .~ user

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: user,
        language: language,
        locale: .init(identifier: language.rawValue)
      ) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : 900

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testFailedProject() {
    let project = self.cosmicSurgery
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3 / 4)
      |> Project.lens.dates.stateChangedAt .~ 1_234_567_890.0
      |> Project.lens.state .~ .failed

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    Language.allLanguages.forEach { language in
      withEnvironment(
        apiService: mockService, language: language, locale: .init(identifier: language.rawValue)
      ) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 900

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")
      }
    }
  }

  func testMinimalProjectRendering() {
    let project = self.cosmicSurgery!

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    [Device.phone4_7inch, Device.phone5_8inch, Device.pad].forEach { device in
      withEnvironment(apiService: mockService) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(
          device: device, orientation: .portrait, child: vc, handleAppearanceTransition: false
        )

        parent.beginAppearanceTransition(true, animated: true)

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "device_\(device)")
      }
    }
  }

  func testMinimalAndFullProjectOverlap() {
    let project = self.cosmicSurgery
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectCreatorDetailsResult: .success(.template)
    )

    withEnvironment(apiService: mockService) {
      [Device.phone4_7inch, Device.phone5_8inch, Device.pad].forEach { device in
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

        self.scheduler.run()

        FBSnapshotVerifyView(snapshotView, identifier: "device_\(device)")
      }
    }
  }

  func testNonBacker_LiveProject_ProjectSummaryExperiment() {
    let project = self.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3 / 4)

    let items = [
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whatIsTheProject,
        response: "Short copy words words words words words words words words words"
      ),
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whatWillYouDoWithTheMoney,
        response: "Long copy " + Array(0...50).map { _ in "words" }.joined(separator: " ")
      )
    ]

    let mockService = MockService(
      fetchProjectResponse: project,
      fetchProjectSummaryResult: .success(ProjectSummaryEnvelope(projectSummary: items))
    )

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeMeProjectSummary.rawValue: OptimizelyExperiment.Variant.variant1
          .rawValue
      ]

    combos([Language.en], [Device.phone4_7inch]).forEach {
      language, device in
      withEnvironment(
        apiService: mockService,
        language: language,
        locale: .init(identifier: language.rawValue),
        optimizelyClient: optimizelyClient
      ) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : 900

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
