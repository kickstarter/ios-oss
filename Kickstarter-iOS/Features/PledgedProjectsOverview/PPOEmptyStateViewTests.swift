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
    orthogonalCombos(
      Language.allLanguages,
      Device.allCases,
      Orientation.allCases,
      [UIUserInterfaceStyle.dark, UIUserInterfaceStyle.light]
    ).forEach {
      language, device, orientation, interfaceStyle in

      let mockConfigClient = MockRemoteConfigClient()
      mockConfigClient.features = [
        RemoteConfigFeature.pledgedProjectsOverviewV4Enabled.rawValue: true,
        RemoteConfigFeature.pledgedProjectsOverviewV2Enabled.rawValue: true
      ]

      withEnvironment(language: language, remoteConfigClient: mockConfigClient) {
        let size = device.deviceSize(in: orientation)
        let view = PPOEmptyStateView().frame(width: size.width, height: size.height)
        let traits = UITraitCollection.init(userInterfaceStyle: interfaceStyle)

        assertSnapshot(
          of: view,
          as: .image(traits: traits),
          named: "lang_\(language.rawValue)_\(device)_\(orientation)"
        )
      }
    }
  }

  func testEmptyStateView_PPOV2() {
    let language = Language.en
    let device = Device.phone4_7inch
    let orientation = Orientation.landscape

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgedProjectsOverviewV2Enabled.rawValue: true,
      RemoteConfigFeature.pledgedProjectsOverviewV4Enabled.rawValue: false
    ]

    withEnvironment(language: language, remoteConfigClient: mockConfigClient) {
      let size = device.deviceSize(in: orientation)
      let view = PPOEmptyStateView().frame(width: size.width, height: size.height)
      assertSnapshot(
        of: view,
        as: .image,
        named: "lang_\(language.rawValue)"
      )
    }
  }

  // The only difference between v1 and v2 is a strings change. Test v1 in english only.
  func testEmptyStateView_PPOV1() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgedProjectsOverviewV2Enabled.rawValue: false,
      RemoteConfigFeature.pledgedProjectsOverviewV4Enabled.rawValue: false
    ]

    withEnvironment(language: Language.en, remoteConfigClient: mockConfigClient) {
      let size = Device.phone5_8inch.deviceSize
      let view = PPOEmptyStateView().frame(width: size.width, height: size.height)
      assertSnapshot(
        of: view,
        as: .image,
        named: "lang_en"
      )
    }
  }
}
