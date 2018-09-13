import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi

final class SettingsDataSourceTests: XCTestCase {
  private let dataSource = SettingsDataSource()
  private let tableView = UITableView(frame: .zero)

  func testConfigureRows() {
    dataSource.configureRows(with: User.template)

    XCTAssertEqual(6, dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 3))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 4))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 5))
  }

  func testCellTypeForIndexPath_validIndexPath() {
    dataSource.configureRows(with: User.template)

    let indexPath1 = IndexPath(item: 0, section: 1)
    let indexPath2 = IndexPath(item: 1, section: 1)

    XCTAssertEqual(SettingsCellType.notifications, dataSource.cellTypeForIndexPath(indexPath: indexPath1))
    XCTAssertEqual(SettingsCellType.newsletters, dataSource.cellTypeForIndexPath(indexPath: indexPath2))
  }
}
