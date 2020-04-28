@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import XCTest

final class SettingsDataSourceTests: XCTestCase {
  private let dataSource = SettingsDataSource()
  private let tableView = UITableView(frame: .zero)

  func testConfigureRows() {
    self.dataSource.configureRows(with: User.template)

    XCTAssertEqual(6, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 3))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 4))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 5))
  }

  func testCellTypeForIndexPath_validIndexPath() {
    self.dataSource.configureRows(with: User.template)

    let indexPath1 = IndexPath(item: 0, section: 1)
    let indexPath2 = IndexPath(item: 1, section: 1)

    XCTAssertEqual(
      SettingsCellType.notifications,
      self.dataSource.cellTypeForIndexPath(indexPath: indexPath1)
    )
    XCTAssertEqual(SettingsCellType.newsletters, self.dataSource.cellTypeForIndexPath(indexPath: indexPath2))
  }
}
