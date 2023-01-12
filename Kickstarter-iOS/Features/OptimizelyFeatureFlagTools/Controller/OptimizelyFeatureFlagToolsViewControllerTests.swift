@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class OptimizelyFeatureFlagToolsViewControllerTests: TestCase {
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

  func testOptimizelyFeatureFlagToolsViewController() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
        OptimizelyFeature.projectPageStoryTabEnabled.rawValue: false,
        OptimizelyFeature.rewardLocalPickupEnabled.rawValue: false,
        OptimizelyFeature.paymentSheetEnabled.rawValue: false,
        OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: false,
        OptimizelyFeature.facebookLoginDeprecationEnabled.rawValue: false
      ]

    withEnvironment(language: .en, mainBundle: MockBundle(), optimizelyClient: mockOptimizelyClient) {
      let controller = OptimizelyFeatureFlagToolsViewController.instantiate()
      let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

      self.scheduler.run()

      FBSnapshotVerifyView(parent.view)
    }
  }
}
