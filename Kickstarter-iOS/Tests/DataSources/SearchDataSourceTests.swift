import XCTest
@testable import Kickstarter_iOS
@testable import Library
@testable import KsApi
import Prelude

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
      Project.template |> Project.lens.id .~ 1,
      Project.template |> Project.lens.id .~ 2,
      Project.template |> Project.lens.id .~ 3
    ])

    XCTAssertEqual(2, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(3, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
  }
}
