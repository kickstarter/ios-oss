@testable import KDS
import SnapshotTesting
import SwiftUI
import XCTest

final class ColorsViewTests: XCTestCase {
  func testView() {
    let colorsView = ColorsView()
    let height = colorsView.snapshotTestHeight

    assertSnapshot(
      of: colorsView.frame(width: 500, height: height),
      as: .image,
      named: "colorsView_testView"
    )
  }
}
