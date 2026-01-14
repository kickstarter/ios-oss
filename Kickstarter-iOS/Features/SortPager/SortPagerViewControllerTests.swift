@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import ReactiveSwift
import SnapshotTesting
import XCTest

internal final class SortPagerViewControllerTests: TestCase {
  fileprivate let sorts: [DiscoveryParams.Sort] = [.magic, .popular, .newest, .endingSoon]

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testSortView() {
    forEachScreenshotType { type in
      let scheduler = TestScheduler()

      withEnvironment(language: type.language, scheduler: scheduler) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: self.sorts)

        scheduler.advance(by: .milliseconds(100))

        let size = type.device.deviceSize(in: type.orientation)
        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: CGSize(width: size.width, height: 50),
          testName: "testSortView"
        )
      }
    }
  }

  func testSortView_iPad() {
    forEachScreenshotType(devices: [.pad]) { type in
      let scheduler = TestScheduler()

      withEnvironment(language: type.language, scheduler: scheduler) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: self.sorts)

        scheduler.advance(by: .milliseconds(100))

        let size = type.device.deviceSize(in: type.orientation)
        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: CGSize(width: size.width, height: 50),
          testName: "testSortView_iPad"
        )
      }
    }
  }

  func testSortView_iPad_Landscape() {
    forEachScreenshotType(devices: [.pad], orientation: .landscape) { type in
      let scheduler = TestScheduler()

      withEnvironment(language: type.language, scheduler: scheduler) {
        let controller = SortPagerViewController.instantiate()
        controller.configureWith(sorts: self.sorts)

        scheduler.advance(by: .milliseconds(100))

        let size = type.device.deviceSize(in: type.orientation)
        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: CGSize(width: size.width, height: 50),
          testName: "testSortView_iPad_Landscape"
        )
      }
    }
  }
}
