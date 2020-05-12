import Foundation
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import XCTest

final class CancelPledgeViewControllerTests: TestCase {
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

  func testCancelPledge() {
    let project = Project.cosmicSurgery

    let data = CancelPledgeViewData(
      project: project,
      projectCountry: project.country,
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

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
