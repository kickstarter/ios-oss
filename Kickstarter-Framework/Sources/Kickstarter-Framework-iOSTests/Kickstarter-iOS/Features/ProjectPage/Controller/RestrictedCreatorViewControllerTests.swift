@testable import Kickstarter_Framework
@testable import Library
import SnapshotTesting
import UIKit
import XCTest

internal final class RestrictedCreatorViewControllerTests: TestCase {
  func testView() {
    orthogonalCombos(Language.allLanguages, [Device.phone4inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {
        let message = "Sample creator restricted reason: Kickstarter’s Trust & Safety team has "
          + "investigated user reports associated with this project and/or its creator. We have "
          + "reached out to the creator multiple times requesting project updates and "
          + "communication with backers. As the creator has not responded or provided updates in "
          + "over 90 days, we have restricted the creator’s account from launching future "
          + "projects on Kickstarter. Thank you to everyone who sent in reports."
        let vc = RestrictedCreatorViewController.configuredWith(message: message)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height
        parent.navigationController?.isNavigationBarHidden = true

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
