@testable import Kickstarter_Framework
import Library
import SnapshotTesting
import SwiftUI

final class ColorsViewTests: TestCase {
  func testView() {
    let colorsView = ColorsView()
    let height: CGFloat =
      CGFloat(150 + (colorsView.semanticColors.count + colorsView.legacyColors.count) * 104)

    assertSnapshot(
      matching: colorsView.frame(width: 500, height: height),
      as: .image,
      named: "colorsView_testView"
    )
  }
}
