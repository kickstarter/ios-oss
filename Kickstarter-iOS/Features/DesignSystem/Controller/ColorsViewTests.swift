@testable import Kickstarter_Framework
import Library
import SnapshotTesting
import SwiftUI

final class ColorsViewTests: TestCase {
  func testView() {
    let colorsView = ColorsView()
    let height: CGFloat =
      CGFloat(150 + (colorsView.semanticColors.count + colorsView.legacyColors.count) * 104)

    // Most tests use `MockColorResolver` to get a static light mode color,
    // but this test actually needs dynamic colors to get the correct screenshot image.

    withEnvironment(colorResolver: AppColorResolver()) {
      assertSnapshot(
        matching: colorsView.frame(width: 500, height: height),
        as: .image,
        named: "colorsView_testView"
      )
    }
  }
}
