// swiftlint:disable line_length
import Prelude
import XCTest
import Library

@testable import Kickstarter_Framework

final class SettingsAccountDataSourceTests: XCTestCase {
  private let dataSource = SettingsAccountDataSource()
  private let tableView = UITableView()

  func testConfigureRows_EmailPasswordRows_Shown() {
    self.self.dataSource.configureRows(currency: Currency.USD,
                                  shouldHideEmailWarning: true,
                                  shouldHideEmailPasswordSection: false)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
  }

  func testConfigureRows_EmailPasswordRows_Hidden() {
    self.dataSource.configureRows(currency: Currency.USD,
                                  shouldHideEmailWarning: true,
                                  shouldHideEmailPasswordSection: true)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
  }

  func testCellTypeForIndexPath() {
    let indexPath1 = IndexPath(item: 0, section: 0)
    let indexPath2 = IndexPath(item: 1, section: 0)
    let indexPath3 = IndexPath(item: 0, section: 1)
    let indexPath4 = IndexPath(item: 0, section: 2)
    let indexPath5 = IndexPath(item: 1, section: 2)

    self.dataSource.configureRows(currency: .USD,
                                  shouldHideEmailWarning: true,
                                  shouldHideEmailPasswordSection: false)

    XCTAssertEqual(SettingsAccountCellType.changeEmail, self.dataSource.cellTypeForIndexPath(indexPath: indexPath1))
    XCTAssertEqual(SettingsAccountCellType.changePassword, self.dataSource.cellTypeForIndexPath(indexPath: indexPath2))
    XCTAssertEqual(SettingsAccountCellType.privacy, self.dataSource.cellTypeForIndexPath(indexPath: indexPath3))
    XCTAssertEqual(SettingsAccountCellType.paymentMethods, self.dataSource.cellTypeForIndexPath(indexPath: indexPath4))

    let currencyCellType = SettingsAccountCellType.currency(.USD)
    XCTAssertEqual(currencyCellType, self.dataSource.cellTypeForIndexPath(indexPath: indexPath5))
  }

  func testCellTypeForIndexPath_HideEmailPassword() {
    let indexPath1 = IndexPath(item: 0, section: 0)
    let indexPath2 = IndexPath(item: 0, section: 1)
    let indexPath3 = IndexPath(item: 0, section: 2)
    let indexPath4 = IndexPath(item: 1, section: 2)

    self.dataSource.configureRows(currency: .USD,
                                  shouldHideEmailWarning: true,
                                  shouldHideEmailPasswordSection: true)

    XCTAssertEqual(SettingsAccountCellType.createPassword, self.dataSource.cellTypeForIndexPath(indexPath: indexPath1))
    XCTAssertEqual(SettingsAccountCellType.privacy, self.dataSource.cellTypeForIndexPath(indexPath: indexPath2))
    XCTAssertEqual(SettingsAccountCellType.paymentMethods, self.dataSource.cellTypeForIndexPath(indexPath: indexPath3))

    let currencyCellType = SettingsAccountCellType.currency(.USD)
    XCTAssertEqual(currencyCellType, self.dataSource.cellTypeForIndexPath(indexPath: indexPath4))
  }
}
