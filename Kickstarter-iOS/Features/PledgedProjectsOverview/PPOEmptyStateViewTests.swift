@testable import Kickstarter_Framework
import Library
import SnapshotTesting
import SwiftUI
import XCTest

final class PPOEmptyStateViewTests: TestCase {
  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testEmptyStateView() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgedProjectsOverviewV2Enabled.rawValue: true
    ]

    forEachScreenshotType { type in
      withEnvironment(language: type.language, remoteConfigClient: mockConfigClient) {
        let size = type.device.deviceSize(in: type.orientation)
        let view = PPOEmptyStateView().frame(width: size.width, height: size.height)
        assertSnapshot(
          forSwiftUIView: view,
          withType: type,
          size: size,
          testName: "testEmptyStateView"
        )
      }
    }
  }

  // The only difference between v1 and v2 is a strings change. Test v1 across
  // the standard screenshot types.
  func testEmptyStateView_PPOV1() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgedProjectsOverviewV2Enabled.rawValue: false
    ]

    forEachScreenshotType { type in
      withEnvironment(language: type.language, remoteConfigClient: mockConfigClient) {
        let size = type.device.deviceSize(in: type.orientation)
        let view = PPOEmptyStateView().frame(width: size.width, height: size.height)
        assertSnapshot(
          forSwiftUIView: view,
          withType: type,
          size: size,
          testName: "testEmptyStateView_PPOV1"
        )
      }
    }
  }
}
