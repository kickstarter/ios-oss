@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class ProjectPageViewControllerTests: TestCase {
  private var project: Project = .cosmicSurgery
  private let extendedProjectProperties = ExtendedProjectProperties(
    environmentalCommitments: [ProjectEnvironmentalCommitment(
      description: "Environmental Commitment",
      category: .environmentallyFriendlyFactories,
      id: 0
    )],
    faqs: [ProjectFAQ(
      answer: "Answer",
      question: "Question",
      id: 0,
      createdAt: MockDate().timeIntervalSince1970
    )],
    risks: "These are the risks",
    story: ProjectStoryElements(htmlViewElements:
      [
        TextViewElement(components: [
          TextComponent(
            text: "bold and emphasis",
            link: nil,
            styles: [.bold, .emphasis]
          ),
          TextComponent(
            text: "link",
            link: "https://ksr.com",
            styles: [.link]
          )
        ]),
        ImageViewElement(
          src: "bad-url",
          href: "https://ksr.com",
          caption: "camera"
        ),
        AudioVideoViewElement(
          sourceURLString: "https://source.com",
          thumbnailURLString: nil,
          seekPosition: .zero
        ),
        ExternalSourceViewElement(
          embeddedURLString: "https://source.com",
          embeddedURLContentHeight: 123
        )
      ]),
    minimumPledgeAmount: 1
  )
  private let emptyProjectProperties = ExtendedProjectProperties(
    environmentalCommitments: [],
    faqs: [],
    risks: "",
    story: ProjectStoryElements(htmlViewElements: []),
    minimumPledgeAmount: 1
  )
  private let user = User.brando

  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  // MARK: - Logged In

  func testLoggedIn_Backer_LiveProject_ShowEnvironmentalCommitments_Success() {
    let config = Config.template
    let reward = Reward.template
      |> Reward.lens.title .~ "Magic Lamp"
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .live
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: 1)
    let projectAndEnvelope = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndEnvelope),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success([reward])
    )

    combos([Language.en], [Device.phone4inch]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_Backer_LiveProject_ShowCampaignTab_Success() {
    let config = Config.template
    let reward = Reward.template
      |> Reward.lens.title .~ "Magic Lamp"
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .live
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: 1)
    let projectAndEnvelope = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndEnvelope),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success([reward])
    )

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
        OptimizelyFeature.projectPageStoryTabEnabled.rawValue: true
      ]

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config,
        currentUser: .template,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_Backer_LiveProject_NotShowingCampaign_Success() {
    let config = Config.template
    let reward = Reward.template
      |> Reward.lens.title .~ "Magic Lamp"
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .live
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: 1)
    let projectAndEnvelope = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndEnvelope),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success([reward])
    )

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
        OptimizelyFeature.projectPageStoryTabEnabled.rawValue: false
      ]

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config,
        currentUser: .template,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_Backer_LiveProject_ShowNoEnvironmentalCommitments_Success() {
    let config = Config.template
    let reward = Reward.template
      |> Reward.lens.title .~ "Magic Lamp"
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .live
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.emptyProjectProperties

    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: 1)
    let projectAndEnvelope = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndEnvelope),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success([reward])
    )

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_Backer_LiveProject_Error() {
    let config = Config.template
    let currentUser = User.template
    let backing = Backing.template
      |> Backing.lens.status .~ .errored
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: 1)
    let projectAndEnvelope = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndEnvelope),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success(Project.cosmicSurgery.rewardData.rewards)
    )

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: currentUser, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
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
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .successful
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: 1)
    let projectAndEnvelope = ProjectAndBackingEnvelope(project: project, backing: .template)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndEnvelope),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success(Project.cosmicSurgery.rewardData.rewards)
    )

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
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
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .successful
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: 1)
    let projectAndEnvelope = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndEnvelope),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success(Project.cosmicSurgery.rewardData.rewards)
    )

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: currentUser, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_NonBacker_LiveProject() {
    let config = Config.template
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success(Project.cosmicSurgery.rewards)
    )

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  // MARK: - Logged Out

  func testLoggedIn_NonBacker_NonLiveProject() {
    let config = Config.template
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .successful
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success(Project.cosmicSurgery.rewards)
    )

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_Backer_LiveProject_NonUS_ProjectCurrency_US_ProjectCountry_US_UserChosenCurrency_Success() {
    let config = Config.template
    let reward = Reward.template
      |> Reward.lens.title .~ "Magic Lamp"
    let project = Project.cosmicSurgery
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .live
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: 1)
    let projectAndEnvelope = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndEnvelope),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success([reward])
    )

    combos(Language.allLanguages, [Device.phone5_8inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_Backer_LiveProject_US_ProjectCurrency_US_ProjectCountry_US_UserChosenCurrency_OmittingCurrencyCode_Success() {
    let config = Config.template
    let reward = Reward.template
      |> Reward.lens.title .~ "Magic Lamp"
    let project = Project.cosmicSurgery
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.currentCurrency .~ Project.Country.us.currencyCode
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .live
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: 1)
    let projectAndEnvelope = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndEnvelope),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success([reward])
    )

    combos(Language.allLanguages, [Device.phone5_8inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_Backer_LiveProject_NonUS_ProjectCurrency_US_ProjectCountry_NonUS_UserChosenCurrency_NotOmittingCurrencyCode_Success() {
    let config = Config.template
    let reward = Reward.template
      |> Reward.lens.title .~ "Magic Lamp"
    let project = Project.cosmicSurgery
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.currentCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .live
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: 1)
    let projectAndEnvelope = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndEnvelope),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success([reward])
    )

    combos(Language.allLanguages, [Device.phone5_8inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_Backer_LiveProject_US_ProjectCurrency_US_ProjectCountry_NonUS_UserChosenCurrency_Success() {
    let config = Config.template
    let reward = Reward.template
      |> Reward.lens.title .~ "Magic Lamp"
    let project = Project.cosmicSurgery
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.currentCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .live
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: 1)
    let projectAndEnvelope = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndEnvelope),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success([reward])
    )

    combos(Language.allLanguages, [Device.phone5_8inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: .template, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  // MARK: - Logged Out

  func testLoggedOut_NonBacker_LiveProject_ShowEnvironmentalCommitments_Success() {
    let config = Config.template

    let liveProject = self.project
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.stats.convertedPledgedAmount .~ 1_964
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let projectPamphletData = Project.ProjectPamphletData(project: liveProject, backingId: nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success(self.project.rewards)
    )

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: nil, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(projectOrParam: .left(liveProject), refTag: nil)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedOut_NonBacker_LiveProject_ShowNoEnvironmentalCommitments_Success() {
    let config = Config.template

    let liveProject = self.project
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.stats.convertedPledgedAmount .~ 1_964
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.emptyProjectProperties

    let projectPamphletData = Project.ProjectPamphletData(project: liveProject, backingId: nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success(self.project.rewards)
    )

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: nil, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(projectOrParam: .left(liveProject), refTag: nil)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedOut_NonBacker_NonLiveProject() {
    let config = Config.template
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .successful
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let projectPamphletData = Project.ProjectPamphletData(project: project, backingId: nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectPamphletResult: .success(projectPamphletData),
      fetchProjectRewardsResult: .success(Project.cosmicSurgery.rewards)
    )

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config, currentUser: nil, language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  // MARK: - Error fetching project

  func testErrorFetchingProject() {
    let config = Config.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectPamphletResult: .failure(.couldNotParseJSON)
    )

    // This test was previously flakey on CI because it relied on Alamofire to download an image url to populate the user image, which may/may not be ready in time.
    let projectWithNoUserImageURL = self.project
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config,
        language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(projectWithNoUserImageURL),
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

  // MARK: - Tab Content Tests

  func testLoggedOut_NonBacker_LiveProjectSwitchedToCampaignTab_Success() {
    let config = Config.template
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
        OptimizelyFeature.projectPageStoryTabEnabled.rawValue: true
      ]

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        config: config,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.advance()

        // INFO: We are not testing that the navigation selector view changed, simply the content of the view controller.
        vc.projectNavigationSelectorViewDidSelect(ProjectNavigationSelectorView(), index: 1)

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedOut_NonBacker_LiveProjectSwitchedToRisksTab_Success() {
    let config = Config.template
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
        OptimizelyFeature.projectPageStoryTabEnabled.rawValue: true
      ]

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        config: config,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.advance()

        // INFO: We are not testing that the navigation selector view changed, simply the content of the view controller.
        vc.projectNavigationSelectorViewDidSelect(ProjectNavigationSelectorView(), index: 3)

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedIn_NonBacker_LiveProjectSwitchedToFaqsTab_Success() {
    let config = Config.template
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
        OptimizelyFeature.projectPageStoryTabEnabled.rawValue: true
      ]

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        config: config,
        currentUser: .template,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.advance()

        // INFO: We are not testing that the navigation selector view, just the content of the view controller after the tab selection occurs.
        vc.projectNavigationSelectorViewDidSelect(ProjectNavigationSelectorView(), index: 2)

        scheduler.advance()

        let faqSelectionIndexPath = IndexPath(
          row: 0,
          section: ProjectPageViewControllerDataSource.Section.faqs.rawValue
        )

        vc.tableView(UITableView(), didSelectRowAt: faqSelectionIndexPath)

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testLoggedOut_NonBacker_LiveProjectSwitchedToEnvironmentalCommitmentsTab_Success() {
    let config = Config.template
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.extendedProjectProperties

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
        OptimizelyFeature.projectPageStoryTabEnabled.rawValue: true
      ]

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        config: config,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: .left(project), refTag: nil
        )

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        scheduler.advance()

        // INFO: We are not testing that the navigation selector view, just the content of the view controller after the tab selection occurs.
        vc.projectNavigationSelectorViewDidSelect(ProjectNavigationSelectorView(), index: 4)

        scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
