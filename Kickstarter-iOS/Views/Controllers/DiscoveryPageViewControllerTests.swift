import KsApi
import Library
import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library

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
      |> Activity.lens.id .~ 1234
      |> Activity.lens.project .~ cosmicSurgeryNoPhoto
      |> Activity.lens.user .~ brandoNoAvatar

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: MockService(fetchActivitiesResponse: [backing]), currentUser: User.template,
        language: language, userDefaults: MockKeyValueStore()) {

          let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          parent.view.frame.size.height = 250

          self.scheduler.run()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_Card_NoMetadata() {
    let project = anomalisaNoPhoto
      |> Project.lens.dates.deadline .~ (self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 6)

    let discoveryResponse = .template
      |> DiscoveryEnvelope.lens.projects .~ [project]

    combos(Language.allLanguages, [Device.phone4inch, Device.phone4_7inch, Device.pad])
      .forEach { language, device in

        withEnvironment(apiService: MockService(fetchActivitiesResponse: [],
          fetchDiscoveryResponse: discoveryResponse), currentUser: User.template, language: language) {

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

  func testView_Card_Project() {
    let projectTemplate = anomalisaNoPhoto
      |> Project.lens.dates.deadline .~ (self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 6)

    let starredParams = .defaults
      |> DiscoveryParams.lens.starred .~ true

    let states = [Project.State.successful, .canceled, .failed, .suspended]
    let devices = [Device.phone4inch, Device.phone4_7inch, Device.pad]

    combos(Language.allLanguages, devices, states )
      .forEach { language, device, state in
        let discoveryResponse = .template
          |> DiscoveryEnvelope.lens.projects .~ [projectTemplate |> Project.lens.state .~ state]

        let apiService =  MockService(fetchActivitiesResponse: [], fetchDiscoveryResponse: discoveryResponse)
        withEnvironment(apiService: apiService, currentUser: User.template, language: language) {

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

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(currentUser: nil, language: language) {

        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 210

        controller.change(filter: magicParams)
        self.scheduler.run()

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(language)_device_\(device)", tolerance: 0.015
        )
      }
    }
  }

  fileprivate let anomalisaNoPhoto = .anomalisa
    |> Project.lens.id .~ 1111
    |> Project.lens.photo.full .~ ""

  fileprivate let brandoNoAvatar = .brando
    |> User.lens.avatar.medium .~ ""

  fileprivate let cosmicSurgeryNoPhoto = .cosmicSurgery
    |> Project.lens.id .~ 2222
    |> Project.lens.photo.full .~ ""

  fileprivate let magicParams = .defaults
    |> DiscoveryParams.lens.sort .~ .magic
}
