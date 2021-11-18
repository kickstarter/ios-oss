@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class ProjectPageViewControllerTests: TestCase {
  private var project: Project = .cosmicSurgery
  private let projectProperties = ExtendedProjectProperties(
    environmentalCommitments: [ProjectEnvironmentalCommitment(
      description: "Environmental Commitment",
      category: .environmentallyFriendlyFactories,
      id: 0
    )],
    faqs: [ProjectFAQ(answer: "Answer", question: "Question", id: 0, createdAt: nil)],
    risks: "These are the risks",
    story: "",
    minimumPledgeAmount: 1
  )
  private let emptyProjectProperties = ExtendedProjectProperties(
    environmentalCommitments: [],
    faqs: [],
    risks: "",
    story: "",
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

  func testLoggedIn_Backer_LiveProject() {
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
      |> \.extendedProjectProperties .~ self.projectProperties

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

  func testLoggedIn_Backer_LiveProject_EmptyProjectProperties_RenderedEnvironmentalCommitments_Success() {
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
      |> \.extendedProjectProperties .~ self.projectProperties

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
      |> \.extendedProjectProperties .~ self.projectProperties

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
      |> \.extendedProjectProperties .~ self.projectProperties

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

  func testLoggedIn_NonBacker_NonLiveProject() {
    let config = Config.template
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .successful
      |> Project.lens.stats.convertedPledgedAmount .~ 29_236
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.projectProperties

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

  func testLoggedOut_NonBacker_LiveProject() {
    let config = Config.template

    let liveProject = self.project
      |> Project.lens.stats.convertedPledgedAmount .~ 1_964
      |> Project.lens.rewardData.rewards .~ []
      |> \.extendedProjectProperties .~ self.projectProperties

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

  func testLoggedOut_NonBacker_LiveProject_EmptyProjectProperties_RenderedEnvironmentalCommitments_Success() {
    let config = Config.template

    let liveProject = self.project
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
      |> \.extendedProjectProperties .~ self.projectProperties

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

    combos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        config: config,
        language: language
      ) {
        let vc = ProjectPageViewController.configuredWith(
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
