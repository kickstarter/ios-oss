import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import LiveStream
@testable import KsApi
import Prelude

private let pages: [LiveStreamContainerPage] = [
  .info(project: .template, liveStreamEvent: .template, refTag: .projectPage, presentedFromProject: false),
  .chat(project: .template, liveStreamEvent: .template)
]

internal final class LiveStreamContainerPagesDataSourceTests: XCTestCase {
  fileprivate let dataSource = LiveStreamContainerPagesDataSource()
  fileprivate let pageViewController = UIPageViewController()

  override func setUp() {
    super.setUp()

    self.dataSource.load(pages: pages)
  }

  func testIndex() {
    for page in pages {
      XCTAssertEqual(page,
                     self.dataSource.controller(forPage: page).flatMap(self.dataSource.page(forController:)),
                     "controller(forPage:) and page(forController:) are inverses.")
    }

    for idx in pages.indices {
      XCTAssertEqual(idx,
                     self.dataSource.controller(forIndex: idx).flatMap(self.dataSource.index(forController:)),
                     "controller(forIndex:) and index(forController:) are inverses.")
    }
  }

  func testViewControllerAfterViewController() {
    for idx in pages.indices.dropLast() {
      let controller = self.dataSource.controller(forIndex: idx)
      let next = controller.flatMap {
        self.dataSource.pageViewController(
          self.pageViewController,
          viewControllerAfter: $0
        )
      }

      XCTAssertEqual(next, self.dataSource.controller(forIndex: idx + 1))
    }
  }

  func testViewControllerAfterLastViewController() {
    let lastController = self.dataSource.controller(forIndex: pages.count - 1)
    let afterLastController = lastController.flatMap {
      self.dataSource.pageViewController(self.pageViewController, viewControllerAfter: $0)
    }

    XCTAssertNil(afterLastController)
  }

  func testViewControllerBeforeViewController() {
    for idx in pages.indices.dropFirst() {
      let controller = self.dataSource.controller(forIndex: idx)
      let previous = controller.flatMap {
        self.dataSource.pageViewController(
          self.pageViewController,
          viewControllerBefore: $0
        )
      }

      XCTAssertEqual(previous, self.dataSource.controller(forIndex: idx - 1))
    }
  }

  func testViewControllerBeforeLastViewController() {
    let firstController = self.dataSource.controller(forIndex: 0)
    let beforeFirstController = firstController.flatMap {
      self.dataSource.pageViewController(self.pageViewController, viewControllerBefore: $0)
    }

    XCTAssertNil(beforeFirstController)
  }
}
