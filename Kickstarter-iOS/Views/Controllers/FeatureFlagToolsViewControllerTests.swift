import Foundation
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class FeatureFlagToolsViewControllerTests: TestCase {
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

  func testViewFeatureFlags_WithFlags() {
    let mockConfig = Config.template
      |> \.features .~ [
        "ios_native_checkout": true,
        "other_unknown_flag": false
      ]

    withEnvironment(config: mockConfig) {
      let device = Device.phone5_8inch
      let controller = FeatureFlagToolsViewController.instantiate()
      let (parent, _) = traitControllers(
        device: device, orientation: .portrait,
        child: controller
      )

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }
  }

  func testViewFeatureFlags_WithoutValidFlags() {
    let mockConfig = Config.template
      |> \.features .~ ["other_unknown_flag": false]

    withEnvironment(config: mockConfig) {
      let device = Device.phone5_8inch
      let controller = FeatureFlagToolsViewController.instantiate()
      let (parent, _) = traitControllers(
        device: device, orientation: .portrait,
        child: controller
      )

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }
  }
}
