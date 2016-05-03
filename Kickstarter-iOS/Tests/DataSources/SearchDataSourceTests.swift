import XCTest
@testable import Kickstarter_iOS
@testable import Library
@testable import Models_TestHelpers
import Models

final class SearchDataSourceTests: XCTestCase {
  let dataSource = SearchDataSource()
  let tableView = UITableView()

  func testPopularTitle() {
    dataSource.popularTitle(isVisible: false)
    XCTAssertEqual(1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))

    dataSource.popularTitle(isVisible: true)
    XCTAssertEqual(1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
  }

  func testProjects() {
    dataSource.load(projects: [
      ProjectFactory.live(id: 1),
      ProjectFactory.live(id: 2),
      ProjectFactory.live(id: 3),
    ])

    XCTAssertEqual(2, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(3, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
  }
}
