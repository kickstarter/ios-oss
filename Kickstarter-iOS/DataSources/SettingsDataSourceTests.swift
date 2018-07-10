import XCTest
@testable import Kickstarter_Framework

final class SettingsDataSourceTests: XCTestCase {
  private let dataSource = SettingsDataSource()
  private let tableView = UITableView(frame: .zero)

  func testConfigureRows() {
    dataSource.configureRows()

    XCTAssertEqual(4, dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 3))

  }

  func testCellTypeForIndexPath_validIndexPath() {
    dataSource.configureRows()

    let indexPath0 = IndexPath(item: 0, section: 0)
    let indexPath1 = IndexPath(item: 1, section: 0)

    XCTAssertEqual(SettingsCellType.notifications, dataSource.cellTypeForIndexPath(indexPath: indexPath0))
    XCTAssertEqual(SettingsCellType.newsletters, dataSource.cellTypeForIndexPath(indexPath: indexPath1))
  }

  func testCellTypeForIndexPath_invalidIndexPath() {
    dataSource.configureRows()

    let indexPath = IndexPath(item: 0, section: 5)

    XCTAssertEqual(nil, dataSource.cellTypeForIndexPath(indexPath: indexPath))
  }
}
