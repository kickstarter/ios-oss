@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class SettingsPrivacyDataSourceTests: XCTestCase {
  private let dataSource = SettingsPrivacyDataSource()
  private let tableView = UITableView(frame: .zero)

  func testConfigureRows_NonCreator() {
    let user = User.template

    self.dataSource.load(user: user)

    XCTAssertEqual(7, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 3))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 4))
  }

  func testConfigureRows_Creator() {
    let user = User.template
      |> \.stats.createdProjectsCount .~ 1

    self.dataSource.load(user: user)

    XCTAssertEqual(7, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 3))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 4))
  }
}
