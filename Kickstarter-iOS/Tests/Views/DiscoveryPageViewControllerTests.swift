import KsApi
import Library
import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library

internal final class DiscoveryPageViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: NSBundle.framework)
    UIView.setAnimationsEnabled(false)
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

          controller.viewWillAppear(false)

          self.scheduler.run()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_Onboarding() {
    let magicParams = .defaults
      |> DiscoveryParams.lens.sort .~ .magic

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language, currentUser: nil) {

        let controller = DiscoveryPageViewController.configuredWith(sort: .magic)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 210

        controller.change(filter: magicParams)
        controller.viewWillAppear(false)
        controller.viewDidAppear(false)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    super.tearDown()
  }

  private let brandoNoAvatar = .brando
    |> User.lens.avatar.medium .~ ""

  private let cosmicSurgeryNoPhoto = .cosmicSurgery
    |> Project.lens.photo.full .~ ""
}
