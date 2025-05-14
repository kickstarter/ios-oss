@testable import Kickstarter_Framework
import Library
import SnapshotTesting
import SwiftUI

final class ColorsViewTests: TestCase {
  override func setUp() {
    super.setUp()

    let remoteConfig = MockRemoteConfigClient()
    remoteConfig.features[RemoteConfigFeature.darkModeEnabled.rawValue] = true
    AppEnvironment.pushEnvironment(remoteConfigClient: remoteConfig)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()

    super.tearDown()
  }

  func testView() {
    let colorsView = ColorsView()
    let height: CGFloat = CGFloat(150 + colorsView.semanticColors.count * 104)

    assertSnapshot(
      matching: colorsView.frame(width: 500, height: height),
      as: .image,
      named: "colorsView_testView"
    )
  }
}
