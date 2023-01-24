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

  /** FIXME: Once agnostic snapshot tests pr https://github.com/kickstarter/ios-oss/pull/1757 is merged, comment back in.
   func testOptimizelyFeatureFlagToolsViewController() {
     let mockOptimizelyClient = MockOptimizelyClient()
       |> \.features .~ [
         OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
         OptimizelyFeature.projectPageStoryTabEnabled.rawValue: false,
         OptimizelyFeature.paymentSheetEnabled.rawValue: false,
         OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: false,
         OptimizelyFeature.facebookLoginDeprecationEnabled.rawValue: false,
         OptimizelyFeature.consentManagementDialogEnabled.rawValue: false
       ]
   */
}
