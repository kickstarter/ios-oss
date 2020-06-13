@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude

internal final class DiscoveryPageViewControllerTests: TestCase {
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

  func testView_Activity_Backing() {
    let backing = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.id .~ 1_234
      |> Activity.lens.project .~ self.cosmicSurgeryNoPhoto
      |> Activity.lens.user .~ self.brandoNoAvatar

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: MockService(fetchActivitiesResponse: [backing]),
        currentUser: User.template,
        language: language,
        userDefaults: MockKeyValueStore()
      ) {
        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        controller.tableView.refreshControl = nil
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 250

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_Card_Project_HasSocial() {
    let project = self.anomalisaNoPhoto
      |> Project.lens.personalization.friends .~ [self.brandoNoAvatar]

    let discoveryResponse = .template
      |> DiscoveryEnvelope.lens.projects .~ [project]

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: MockService(
          fetchActivitiesResponse: [],
          fetchDiscoveryResponse: discoveryResponse
        ),
        config: Config.template,
        currentUser: User.template,
        language: language
      ) {
        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = device == .pad ? 700 : 550

        controller.change(filter: magicParams)

        self.scheduler.run()

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_Card_NoMetadata() {
    let project = self.anomalisaNoPhoto
      |> Project.lens.dates.deadline .~ (self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 6)

    let discoveryResponse = .template
      |> DiscoveryEnvelope.lens.projects .~ [project]

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: MockService(
            fetchActivitiesResponse: [],
            fetchDiscoveryResponse: discoveryResponse
          ),
          config: Config.template,
          currentUser: User.template, language: language
        ) {
          let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          parent.view.frame.size.height = device == .pad ? 500 : 450

          controller.change(filter: magicParams)

          self.scheduler.run()

          controller.tableView.layoutIfNeeded()
          controller.tableView.reloadData()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
        }
      }
  }

  func testView_Card_Project_IsBacked() {
    let backedProject = self.anomalisaNoPhoto
      |> Project.lens.personalization.backing .~ Backing.template

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      let discoveryResponse = .template
        |> DiscoveryEnvelope.lens.projects .~ [backedProject]

      let apiService = MockService(fetchActivitiesResponse: [], fetchDiscoveryResponse: discoveryResponse)
      withEnvironment(
        apiService: apiService,
        config: config,
        currentUser: User.template,
        language: language
      ) {
        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = device == .pad ? 500 : 450

        controller.change(filter: magicParams)

        self.scheduler.run()

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        FBSnapshotVerifyView(
          parent.view,
          identifier: "backed_lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_Card_Project_TodaySpecial() {
    let mockDate = MockDate()
    let featuredProj = self.anomalisaNoPhoto
      |> Project.lens.category .~ Project.Category.illustration
      |> Project.lens.dates.featuredAt .~ mockDate.timeIntervalSince1970

    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    let config = Config.template

    combos(Language.allLanguages, devices, [("featured", featuredProj)])
      .forEach { language, device, labeledProj in
        let discoveryResponse = .template
          |> DiscoveryEnvelope.lens.projects .~ [labeledProj.1]

        let apiService = MockService(fetchActivitiesResponse: [], fetchDiscoveryResponse: discoveryResponse)
        withEnvironment(
          apiService: apiService,
          config: config,
          currentUser: User.template,
          dateType: MockDate.self,
          language: language
        ) {
          let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          parent.view.frame.size.height = device == .pad ? 500 : 450

          controller.change(filter: magicParams)

          self.scheduler.run()

          controller.tableView.layoutIfNeeded()
          controller.tableView.reloadData()

          FBSnapshotVerifyView(
            parent.view,
            identifier: "\(labeledProj.0)_lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_Card_Project() {
    let projectTemplate = self.anomalisaNoPhoto

    let starredParams = .defaults
      |> DiscoveryParams.lens.starred .~ true

    let states = [Project.State.successful, .canceled, .failed, .suspended]
    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    let config = Config.template

    combos(Language.allLanguages, devices, states)
      .forEach { language, device, state in
        let discoveryResponse = .template
          |> DiscoveryEnvelope.lens.projects .~ [projectTemplate |> Project.lens.state .~ state]

        let apiService = MockService(fetchActivitiesResponse: [], fetchDiscoveryResponse: discoveryResponse)
        withEnvironment(
          apiService: apiService,
          config: config,
          currentUser: User.template, language: language
        ) {
          let controller = DiscoveryPageViewController.configuredWith(sort: .endingSoon)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          parent.view.frame.size.height = device == .pad ? 500 : 450

          controller.change(filter: starredParams)

          self.scheduler.run()

          controller.tableView.layoutIfNeeded()
          controller.tableView.reloadData()

          FBSnapshotVerifyView(parent.view, identifier: "state_\(state)_lang_\(language)_device_\(device)")
        }
      }
  }

  func testView_Onboarding() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(currentUser: nil, language: language) {
        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 210

        controller.change(filter: magicParams)
        self.scheduler.run()

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_Editorial() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.lightsOn.rawValue: true]

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        controller.tableView.refreshControl = nil

        controller.change(filter: DiscoveryParams.defaults)

        NotificationCenter.default.post(Notification(name: .ksr_configUpdated))

        self.scheduler.advance(by: .seconds(1))

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_Editorial_WithActivity() {
    let backing = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.id .~ 1_234
      |> Activity.lens.project .~ self.cosmicSurgeryNoPhoto
      |> Activity.lens.user .~ self.brandoNoAvatar

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.lightsOn.rawValue: true]

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchActivitiesResponse: [backing]),
        currentUser: .template,
        language: language,
        optimizelyClient: mockOptimizelyClient,
        userDefaults: MockKeyValueStore()
      ) {
        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        controller.tableView.refreshControl = nil

        self.scheduler.run()

        NotificationCenter.default.post(Notification(name: .ksr_configUpdated))

        self.scheduler.advance(by: .seconds(1))

        controller.change(filter: DiscoveryParams.recommendedDefaults)

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testProjectCard_Experimental() {
    let project = self.cosmicSurgeryNoPhoto
      |> \.state .~ .live
      |> \.staffPick .~ true

    let states: [Project.State] = [.live, .successful, .failed, .canceled]

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectCards.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    combos(Language.allLanguages, Device.allCases, states).forEach { language, device, state in
      let discoveryResponse = .template
        |> DiscoveryEnvelope.lens.projects .~ [project |> Project.lens.state .~ state]
      let apiService = MockService(fetchActivitiesResponse: [], fetchDiscoveryResponse: discoveryResponse)

      withEnvironment(apiService: apiService, language: language, optimizelyClient: mockOptimizelyClient) {
        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        controller.change(filter: .defaults)

        self.scheduler.run()

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        FBSnapshotVerifyView(parent.view, identifier: "state_\(state)_lang_\(language)_device_\(device)")
      }
    }
  }

  func testProjectCard_Experimental_Backer() {
    let project = self.cosmicSurgeryNoPhoto
      |> \.personalization.backing .~ Backing.template
      |> \.staffPick .~ true

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectCards.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      let discoveryResponse = .template
        |> DiscoveryEnvelope.lens.projects .~ [project]
      let apiService = MockService(fetchActivitiesResponse: [], fetchDiscoveryResponse: discoveryResponse)

      withEnvironment(apiService: apiService, language: language, optimizelyClient: mockOptimizelyClient) {
        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        controller.change(filter: .defaults)

        self.scheduler.run()

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testProjectCard_Experimental_Social() {
    let friend1 = User.brando
      |> \.avatar.small .~ ""

    let friend2 = User.template
      |> \.name .~ "Alfie"
      |> \.avatar.small .~ ""

    let project = self.cosmicSurgeryNoPhoto
      |> \.personalization.friends .~ [friend1, friend2]

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectCards.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      let discoveryResponse = .template
        |> DiscoveryEnvelope.lens.projects .~ [project]
      let apiService = MockService(fetchActivitiesResponse: [], fetchDiscoveryResponse: discoveryResponse)

      withEnvironment(apiService: apiService, language: language, optimizelyClient: mockOptimizelyClient) {
        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        controller.change(filter: .defaults)

        self.scheduler.run()

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  fileprivate let anomalisaNoPhoto = .anomalisa
    |> Project.lens.id .~ 1_111
    |> Project.lens.photo.full .~ ""

  fileprivate let brandoNoAvatar = User.brando
    |> \.avatar.medium .~ ""

  fileprivate let cosmicSurgeryNoPhoto = .cosmicSurgery
    |> Project.lens.id .~ 2_222
    |> Project.lens.photo.full .~ ""

  fileprivate let magicParams = .defaults
    |> DiscoveryParams.lens.sort .~ .magic
}
