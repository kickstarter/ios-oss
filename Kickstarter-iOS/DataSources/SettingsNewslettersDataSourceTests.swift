@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class SettingsNewslettersDataSourceTests: XCTestCase {

  let dataSource = SettingsNewslettersDataSource()
  let tableView = UITableView()

  func testLoadData() {
    let newsletters = Newsletter.allCases
    let user = User.template
    let totalRows = newsletters.count + 1 //We add a cell (Subscribe to All) on  top

    dataSource.load(newsletters: newsletters, user: user)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(totalRows, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
  }

  func testSubscribeToAllCell_IsAddedOnTheTop() {

    let newsletters = Newsletter.allCases
    let user = User.template

    dataSource.load(newsletters: newsletters, user: user)
    XCTAssertEqual("SettingsNewslettersTopCell", self.dataSource.reusableId(item: 0, section: 0))
  }

  func testNewsletterCells_AreAddedAfterTopCell() {

    let newsletters = Newsletter.allCases
    let user = User.template

    dataSource.load(newsletters: newsletters, user: user)
    XCTAssertEqual("SettingsNewslettersCell", self.dataSource.reusableId(item: 1, section: 0))
    XCTAssertEqual("SettingsNewslettersCell", self.dataSource.reusableId(item: 2, section: 0))
    XCTAssertEqual("SettingsNewslettersCell", self.dataSource.reusableId(item: 3, section: 0))
    XCTAssertEqual("SettingsNewslettersCell", self.dataSource.reusableId(item: 4, section: 0))
    XCTAssertEqual("SettingsNewslettersCell", self.dataSource.reusableId(item: 5, section: 0))
    XCTAssertEqual("SettingsNewslettersCell", self.dataSource.reusableId(item: 6, section: 0))
    XCTAssertEqual("SettingsNewslettersCell", self.dataSource.reusableId(item: 7, section: 0))
    XCTAssertEqual("SettingsNewslettersCell", self.dataSource.reusableId(item: 8, section: 0))
    XCTAssertEqual("SettingsNewslettersCell", self.dataSource.reusableId(item: 9, section: 0))
  }
}
