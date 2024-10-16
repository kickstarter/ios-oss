@testable import Kickstarter_Framework
import SnapshotTesting
import SwiftUI
import XCTest

final class PPOEmptyStateViewTests: TestCase {
  func testEmptyStateView() {
    let view = PPOEmptyStateView().frame(width: 320, height: 500)
    // TODO: Record multiple snapshots once translations are available (MBL-1558)
    assertSnapshot(matching: view, as: .image, named: "lang_en")
  }
}
