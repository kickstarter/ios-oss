@testable import Kickstarter_Framework
import SnapshotTesting
import UIKit
import XCTest

internal final class AlertBannerTests: TestCase {
  func testView() {
    let banner = AlertBanner(frame: CGRectZero)
    banner.configureWith(
      title: "Fake title",
      subtitle: "Oh no! Here's the details of what went wrong :(",
      buttonTitle: "Do something",
      buttonAction: {
        // no action.
      }
    )

    forEachScreenshotType { type in
      assertSnapshot(
        forView: banner,
        withType: type,
        useIntrinsicSize: true,
        perceptualPrecision: 0.98,
        record: false,
        testName: "testView"
      )
    }
  }
}
