import Prelude
import XCTest
import Library

@testable import Kickstarter_Framework

final class SettingsAccountDataSourceTests: XCTestCase {
  private let dataSource = SettingsAccountDataSource()
  private let tableView = UITableView()

  func testConfigureRows() {
    self.dataSource.configureRows(currency: Currency.USD, shouldHideEmailWarning: true)

    XCTAssertEqual(3, dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 2))
  }

  func testInsertRemoveCurrencyPickerRow() {
    let currency = Currency.USD

    self.dataSource.configureRows(currency: currency, shouldHideEmailWarning: true)

    _ = self.dataSource.insertCurrencyPickerRow(currency: currency)

    // swiftlint:disable line_length
    XCTAssertEqual(3, dataSource.tableView(tableView,
                                           numberOfRowsInSection: SettingsAccountSectionType.payment.rawValue))

    _ = self.dataSource.removeCurrencyPickerRow()

    //swiftlint:disable line_length
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: SettingsAccountSectionType.payment.rawValue))
  }

  func testCellTypeForIndexPath() {
    let indexPath1 = IndexPath(item: 0, section: 0)
    let indexPath2 = IndexPath(item: 1, section: 0)
    let indexPath3 = IndexPath(item: 1, section: 2)

    self.dataSource.configureRows(currency: nil, shouldHideEmailWarning: true)

    //swiftlint:disable line_length
    XCTAssertEqual(SettingsAccountCellType.changeEmail, dataSource.cellTypeForIndexPath(indexPath: indexPath1))
    XCTAssertEqual(SettingsAccountCellType.changePassword, dataSource.cellTypeForIndexPath(indexPath: indexPath2))
    XCTAssertEqual(SettingsAccountCellType.currency, dataSource.cellTypeForIndexPath(indexPath: indexPath3))
  }
}
