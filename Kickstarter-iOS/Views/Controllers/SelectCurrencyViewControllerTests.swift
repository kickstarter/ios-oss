@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import XCTest

internal final class SelectCurrencyViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {
    combos(Language.allLanguages, Device.allCases)
      .forEach { language, device in
        withEnvironment(language: language) {
          let vc = SelectCurrencyViewController.instantiate()
          vc.configure(with: .USD)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
        }
      }
  }
}
