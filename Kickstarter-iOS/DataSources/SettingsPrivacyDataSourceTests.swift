import XCTest
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude

final class SettingsPrivacyDataSourceTests: XCTestCase {
  private let dataSource = SettingsPrivacyDataSource()
  private let tableView = UITableView(frame: .zero)

  func testConfigureRows_NonCreator() {

    let user = User.template

    self.dataSource.load(user: user)

    XCTAssertEqual(7, dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 3))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 4))
  }

  func testConfigureRows_Creator() {

    let user = User.template
      |> User.lens.stats.createdProjectsCount .~ 1

    self.dataSource.load(user: user)

    XCTAssertEqual(7, dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(1, dataSource.tableView(tableView, numberOfRowsInSection: 3))
    XCTAssertEqual(0, dataSource.tableView(tableView, numberOfRowsInSection: 4))
  }
}
