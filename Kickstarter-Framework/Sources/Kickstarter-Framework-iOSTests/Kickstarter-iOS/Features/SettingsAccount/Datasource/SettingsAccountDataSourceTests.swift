import Library
@testable import LibraryTestHelpers
import Prelude
import XCTest

@testable import Kickstarter_Framework

final class SettingsAccountDataSourceTests: XCTestCase {
  private let dataSource = SettingsAccountDataSource()
  private let tableView = UITableView()

  func testConfigureRows() {
    self.dataSource.configureRows(
      currency: Currency.USD,
      isAppleConnected: false
    )

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
  }

  func testConfigureRows_appleConnected() {
    self.dataSource.configureRows(
      currency: Currency.USD,
      isAppleConnected: true
    )

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
  }

  func testCellTypeForIndexPath() {
    let indexPath1 = IndexPath(item: 0, section: 0)
    let indexPath2 = IndexPath(item: 0, section: 1)
    let indexPath3 = IndexPath(item: 1, section: 1)

    self.dataSource.configureRows(
      currency: .USD,
      isAppleConnected: false
    )

    XCTAssertEqual(
      SettingsAccountCellType.privacy, self.dataSource.cellTypeForIndexPath(indexPath: indexPath1)
    )
    XCTAssertEqual(
      SettingsAccountCellType.paymentMethods, self.dataSource.cellTypeForIndexPath(indexPath: indexPath2)
    )

    let currencyCellType = SettingsAccountCellType.currency(.USD)
    XCTAssertEqual(currencyCellType, self.dataSource.cellTypeForIndexPath(indexPath: indexPath3))
  }
}
