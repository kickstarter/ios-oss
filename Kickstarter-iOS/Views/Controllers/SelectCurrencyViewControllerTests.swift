import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

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
    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
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
