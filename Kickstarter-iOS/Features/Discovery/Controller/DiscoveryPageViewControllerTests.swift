@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

internal final class DiscoveryPageViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView_Activity_Backing() {
    let backing = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.id .~ 1_234
      |> Activity.lens.project .~ self.cosmicSurgeryNoPhoto
      |> Activity.lens.user .~ self.brandoNoAvatar

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
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

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_Card_Project_HasSocial() {
    let project = self.anomalisaNoPhoto
      |> Project.lens.personalization.friends .~ [self.brandoNoAvatar]

    let discoveryResponse = .template
      |> DiscoveryEnvelope.lens.projects .~ [project]

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
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

        controller.change(filter: self.magicParams)

        self.scheduler.run()

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_Card_NoMetadata() {
    let project = self.anomalisaNoPhoto
      |> Project.lens.dates.deadline .~ (self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 6)

    let discoveryResponse = .template
      |> DiscoveryEnvelope.lens.projects .~ [project]

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
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

          controller.change(filter: self.magicParams)

          self.scheduler.run()

          controller.tableView.layoutIfNeeded()
          controller.tableView.reloadData()

          assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
        }
      }
  }

  func testView_Card_Project_IsBacked() {
    let backedProject = self.anomalisaNoPhoto
      |> Project.lens.personalization.backing .~ Backing.template

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
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

        controller.change(filter: self.magicParams)

        self.scheduler.run()

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        assertSnapshot(matching: parent.view, as: .image, named: "backed_lang_\(language)_device_\(device)")
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

    orthogonalCombos(Language.allLanguages, devices, [("featured", featuredProj)])
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

          controller.change(filter: self.magicParams)

          self.scheduler.run()

          controller.tableView.layoutIfNeeded()
          controller.tableView.reloadData()

          assertSnapshot(
            matching: parent.view,
            as: .image,
            named: "\(labeledProj.0)_lang_\(language)_device_\(device)"
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

    orthogonalCombos(Language.allLanguages, devices, states)
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

          assertSnapshot(
            matching: parent.view,
            as: .image,
            named: "state_\(state)_lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_Onboarding() {
    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(currentUser: nil, language: language) {
        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 210

        controller.change(filter: self.magicParams)
        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
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
