import XCTest
@testable import Kickstarter_Framework
@testable import Library
import KsApi
import Prelude

private let sorts: [DiscoveryParams.Sort] = [.Magic, .Popular, .Newest]

internal final class DiscoveryPagesDataSourceTests: XCTestCase {
  private let dataSource = DiscoveryPagesDataSource(sorts: sorts)
  private let pageViewController = UIPageViewController()

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
          viewControllerAfterViewController: $0
        )
      }

      XCTAssertEqual(next, self.dataSource.controllerFor(index: idx + 1))
    }
  }

  func testViewControllerAfterLastViewController() {
    let lastController = self.dataSource.controllerFor(index: sorts.count - 1)
    let afterLastController = lastController.flatMap {
      self.dataSource.pageViewController(self.pageViewController, viewControllerAfterViewController: $0)
    }

    XCTAssertNil(afterLastController)
  }

  func testViewControllerBeforeViewController() {
    for idx in sorts.indices.dropFirst() {
      let controller = self.dataSource.controllerFor(index: idx)
      let previous = controller.flatMap {
        self.dataSource.pageViewController(
          self.pageViewController,
          viewControllerBeforeViewController: $0
        )
      }

      XCTAssertEqual(previous, self.dataSource.controllerFor(index: idx - 1))
    }
  }

  func testViewControllerBeforeLastViewController() {
    let firstController = self.dataSource.controllerFor(index: 0)
    let beforeFirstController = firstController.flatMap {
      self.dataSource.pageViewController(self.pageViewController, viewControllerBeforeViewController: $0)
    }

    XCTAssertNil(beforeFirstController)
  }

}
