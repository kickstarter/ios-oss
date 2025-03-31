@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

final class RemoteConfigFeatureFlagToolsViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testRemoteConfigFeatureFlagToolsViewController() {
    let mockRemoteConfigClient = MockRemoteConfigClient()

    for feature in RemoteConfigFeature.allCases {
      mockRemoteConfigClient.features[feature.rawValue] = false
    }

    withEnvironment(language: .en, mainBundle: MockBundle(), remoteConfigClient: mockRemoteConfigClient) {
      let controller = RemoteConfigFeatureFlagToolsViewController.instantiate()
      let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
      self.scheduler.run()

      assertSnapshot(matching: parent.view, as: .image(perceptualPrecision: 0.98))
    }
  }
}
