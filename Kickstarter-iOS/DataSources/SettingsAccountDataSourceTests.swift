import Prelude
import XCTest
import Library

@testable import Kickstarter_Framework

final class SettingsAccountDataSourceTests: XCTestCase {
  private let dataSource = SettingsAccountDataSource()
  private let tableView = UITableView()

  func testConfigureRows_EmailPasswordRows_Shown() {
    self.dataSource.configureRows(currency: Currency.USD,
                                  shouldHideEmailWarning: true,
                                  shouldHideEmailPasswordSection: false)

    XCTAssertEqual(3, dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 2))
  }

  func testConfigureRows_EmailPasswordRows_Hidden() {
    self.dataSource.configureRows(currency: Currency.USD,
                                  shouldHideEmailWarning: true,
                                  shouldHideEmailPasswordSection: true)

    XCTAssertEqual(3, dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(0, dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 2))
  }

  func testInsertRemoveCurrencyPickerRow() {
    self.dataSource.configureRows(currency: Currency.USD,
                                  shouldHideEmailWarning: true,
                                  shouldHideEmailPasswordSection: false)

    _ = self.dataSource.insertCurrencyPickerRow()

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

    self.dataSource.configureRows(currency: nil,
                                  shouldHideEmailWarning: true,
                                  shouldHideEmailPasswordSection: false)

    //swiftlint:disable line_length
    XCTAssertEqual(SettingsAccountCellType.changeEmail, dataSource.cellTypeForIndexPath(indexPath: indexPath1))
    XCTAssertEqual(SettingsAccountCellType.changePassword, dataSource.cellTypeForIndexPath(indexPath: indexPath2))
    XCTAssertEqual(SettingsAccountCellType.currency, dataSource.cellTypeForIndexPath(indexPath: indexPath3))
  }
}
