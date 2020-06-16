@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class PledgeExpandableRewardsHeaderDataSourceTests: XCTestCase {
  private let dataSource = PledgeExpandableRewardsHeaderDataSource()
  private let tableView = UITableView()

  func testLoadValues() {
    let items: [PledgeExpandableRewardsHeaderItem] = [
      .header(("Header title", NSAttributedString(string: "$800"))),
      .reward(("Reward title", NSAttributedString(string: "$400"))),
      .reward(("Reward title", NSAttributedString(string: "$400")))
    ]

    self.dataSource.load(items)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      1,
      self.dataSource.numberOfItems(in: PledgeExpandableRewardsHeaderDataSource.Section.header.rawValue)
    )
    XCTAssertEqual(
      2,
      self.dataSource.numberOfItems(in: PledgeExpandableRewardsHeaderDataSource.Section.rewards.rawValue)
    )
  }
}
