import XCTest
@testable import Kickstarter_Framework
@testable import Library

final class PledgeDataSourceTests: XCTestCase {
  let dataSource = PledgeDataSource()
  let tableView = UITableView(frame: .zero, style: .plain)

  // swiftlint:disable line_length
  func testLoad_loggedIn() {
    self.dataSource.load(
      amount: 100,
      currency: "USD",
      delivery: "May 2020",
      shipping: ("Brooklyn", NSAttributedString(string: "CA$ 7.50")),
      isLoggedIn: true
    )

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(PledgeDescriptionCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 0))
    XCTAssertEqual(PledgeAmountCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 1))
    XCTAssertEqual(PledgeShippingLocationCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: 1))
    XCTAssertEqual(PledgeRowCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 2))
  }

  func testLoad_loggedOut() {
    self.dataSource.load(
      amount: 100,
      currency: "USD",
      delivery: "May 2020",
      shipping: ("Brooklyn", NSAttributedString(string: "CA$ 7.50")),
      isLoggedIn: false
    )

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(PledgeDescriptionCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 0))
    XCTAssertEqual(PledgeAmountCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 1))
    XCTAssertEqual(PledgeShippingLocationCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: 1))
    XCTAssertEqual(PledgeRowCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 2))
    XCTAssertEqual(PledgeContinueCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: 2))
  }
  // swiftlint:enable line_length
}
