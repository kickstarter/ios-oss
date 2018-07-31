import XCTest
@testable import Kickstarter_Framework
@testable import Library

final class HelpDataSourceTests: XCTestCase {
  private let dataSource = HelpDataSource()
  private let tableView = UITableView(frame: .zero)

  func testConfigureRows() {
    dataSource.configureRows()

    XCTAssertEqual(2, dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(3, dataSource.tableView(tableView, numberOfRowsInSection: 1))
  }

  func testCellTypeForIndexPath_validIndexPath() {
    dataSource.configureRows()

    let indexPath0 = IndexPath(item: 0, section: 0)
    let indexPath1 = IndexPath(item: 1, section: 0)
    let indexPath2 = IndexPath(item: 0, section: 1)
    let indexPath3 = IndexPath(item: 1, section: 1)
    let indexPath4 = IndexPath(item: 2, section: 1)

    XCTAssertEqual(HelpType.helpCenter, dataSource.cellTypeForIndexPath(indexPath: indexPath0))
    XCTAssertEqual(HelpType.contact, dataSource.cellTypeForIndexPath(indexPath: indexPath1))
    XCTAssertEqual(HelpType.terms, dataSource.cellTypeForIndexPath(indexPath: indexPath2))
    XCTAssertEqual(HelpType.privacy, dataSource.cellTypeForIndexPath(indexPath: indexPath3))
    XCTAssertEqual(HelpType.cookie, dataSource.cellTypeForIndexPath(indexPath: indexPath4))
  }
}
