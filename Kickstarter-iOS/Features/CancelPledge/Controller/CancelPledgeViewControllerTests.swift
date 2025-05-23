import Foundation
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import SnapshotTesting
import XCTest

final class CancelPledgeViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testCancelPledge() {
    let project = Project.cosmicSurgery

    let data = CancelPledgeViewData(
      project: project,
      projectName: project.name,
      omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
      backingId: String(project.personalization.backing?.id ?? 0),
      pledgeAmount: 10
    )

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(language: language) {
        let controller = CancelPledgeViewController.instantiate()
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
