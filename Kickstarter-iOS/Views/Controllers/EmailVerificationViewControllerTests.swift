import Foundation
@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude

internal final class EmailVerificationViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  func testView() {
    let config = .template
      |> Config.lens.features .~ [Feature.emailVerificationSkip.rawValue: true]

    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(config: config, language: language) {
        let controller = EmailVerificationViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    super.tearDown()
  }
}
