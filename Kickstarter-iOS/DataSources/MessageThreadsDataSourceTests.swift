@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import XCTest

final class MessageThreadsDataSourceTests: XCTestCase {
  let dataSource = MessageThreadsDataSource()
  let tableView = UITableView()

  func testDataSource_WithMessages() {
    self.dataSource.load(messageThreads: [.template])
    self.dataSource.emptyState(isVisible: false)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: tableView))

    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(String(describing: MessageThreadCell.self),
                   self.dataSource.reusableId(item: 0, section: 1))
  }

  func testDataSource_WithoutMessages() {
    self.dataSource.emptyState(isVisible: true)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: tableView))

    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(self.dataSource.emptyStateCellIdentifier, self.dataSource.reusableId(item: 0, section: 0))
  }
}
