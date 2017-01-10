import XCTest
@testable import Kickstarter_Framework
@testable import Library
import KsApi
import Prelude

private let sorts: [DiscoveryParams.Sort] = [.magic, .popular, .newest]

internal final class DiscoveryPagesDataSourceTests: XCTestCase {
  fileprivate let dataSource = DiscoveryPagesDataSource(sorts: sorts)
  fileprivate let pageViewController = UIPageViewController()

  func testIndex() {
    for sort in sorts {
      XCTAssertEqual(sort,
                     self.dataSource.controllerFor(sort: sort).flatMap(self.dataSource.sortFor(controller:)),
                     "controllerFor(sort:) and sortFor(controller:) are inverses.")
    }

    for idx in sorts.indices {
      XCTAssertEqual(idx,
                     self.dataSource.controllerFor(index: idx).flatMap(self.dataSource.indexFor(controller:)),
                     "controllerFor(index:) and indexFor(controller:) are inverses.")
    }
  }

  func testViewControllerAfterViewController() {
    for idx in sorts.indices.dropLast() {
      let controller = self.dataSource.controllerFor(index: idx)
      let next = controller.flatMap {
        self.dataSource.pageViewController(
          self.pageViewController,
          viewControllerAfter: $0
        )
      }

      XCTAssertEqual(next, self.dataSource.controllerFor(index: idx + 1))
    }
  }

  func testViewControllerAfterLastViewController() {
    let lastController = self.dataSource.controllerFor(index: sorts.count - 1)
    let afterLastController = lastController.flatMap {
      self.dataSource.pageViewController(self.pageViewController, viewControllerAfter: $0)
    }

    XCTAssertNil(afterLastController)
  }

  func testViewControllerBeforeViewController() {
    for idx in sorts.indices.dropFirst() {
      let controller = self.dataSource.controllerFor(index: idx)
      let previous = controller.flatMap {
        self.dataSource.pageViewController(
          self.pageViewController,
          viewControllerBefore: $0
        )
      }

      XCTAssertEqual(previous, self.dataSource.controllerFor(index: idx - 1))
    }
  }

  func testViewControllerBeforeLastViewController() {
    let firstController = self.dataSource.controllerFor(index: 0)
    let beforeFirstController = firstController.flatMap {
      self.dataSource.pageViewController(self.pageViewController, viewControllerBefore: $0)
    }

    XCTAssertNil(beforeFirstController)
  }

}
