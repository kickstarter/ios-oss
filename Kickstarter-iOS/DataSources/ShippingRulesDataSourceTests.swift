@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ShippingRulesDataSourceTests: XCTestCase {
  let dataSource = ShippingRulesDataSource()
  let tableView = UITableView(frame: .zero, style: .plain)

  func testLoad() {
    self.dataSource.load(["a", "b", "c"])

    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(ShippingRuleCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 0))
    XCTAssertEqual(ShippingRuleCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: 0))
    XCTAssertEqual(ShippingRuleCell.defaultReusableId, self.dataSource.reusableId(item: 2, section: 0))
  }
}
