@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

/** FIXME: There is a problem with testing the payment sheet. Somehow SPM is incorrectly linking the SDK resources explained here:
 https://kickstarter.atlassian.net/browse/NTV-589
 When that issue is resolved, we can include this file back into `Kickstarter-Framework-iOSTests`
 */

final class AddNewCardViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  func testAddNewCard() {
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(language: language) {
        let controller = AddNewCardViewController.instantiate()
        controller.configure(with: .settings)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testAddNewCard_PledgeViewIntent() {
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(language: language) {
        let controller = AddNewCardViewController.instantiate()
        controller.configure(with: .pledge)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testAddNewCard_EnglishRegions() {
    let locales: [Locale] = [
      Locale(identifier: "en_US"),
      Locale(identifier: "en_CA"),
      Locale(identifier: "en_GB")
    ]

    combos(locales, Device.allCases).forEach { locale, device in
      withEnvironment(locale: locale) {
        let controller = AddNewCardViewController.instantiate()
        controller.configure(with: .settings)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        FBSnapshotVerifyView(parent.view, identifier: "locale_\(locale)_device_\(device)")
      }
    }
  }
}
