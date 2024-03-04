@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class PostCampaignRewardsSummaryDataSourceTests: XCTestCase {
  private let dataSource = PostCampaignRewardsSummaryDataSource()
  private let tableView = UITableView()

  func testLoadValues() {
    let items: [PostCampaignRewardsSummaryItem] = [
      .header(("Header title", NSAttributedString(string: "$800"))),
      .reward(("Reward title", NSAttributedString(string: "$400"))),
      .reward(("Reward title", NSAttributedString(string: "$400")))
    ]

    self.dataSource.load(items)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      1,
      self.dataSource.numberOfItems(in: PostCampaignRewardsSummaryDataSource.Section.header.rawValue)
    )
    XCTAssertEqual(
      2,
      self.dataSource.numberOfItems(in: PostCampaignRewardsSummaryDataSource.Section.rewards.rawValue)
    )
  }
}
