@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

final class RemoteConfigFeatureFlagToolsViewControllerTests: TestCase {
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

  func testRemoteConfigFeatureFlagToolsViewController() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [
        RemoteConfigFeature.blockUsersEnabled.rawValue: false,
        RemoteConfigFeature.consentManagementDialogEnabled.rawValue: false,
        RemoteConfigFeature.darkModeEnabled.rawValue: false,
        RemoteConfigFeature.facebookLoginInterstitialEnabled
          .rawValue: false,
        RemoteConfigFeature.postCampaignPledgeEnabled.rawValue: false,
        RemoteConfigFeature.reportThisProjectEnabled.rawValue: false
      ]

    withEnvironment(language: .en, mainBundle: MockBundle(), remoteConfigClient: mockRemoteConfigClient) {
      let controller = RemoteConfigFeatureFlagToolsViewController.instantiate()
      let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
      self.scheduler.run()

      assertSnapshot(matching: parent.view, as: .image(perceptualPrecision: 0.98))
    }
  }
}
