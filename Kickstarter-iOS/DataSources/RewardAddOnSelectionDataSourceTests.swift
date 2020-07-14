@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class RewardsAddOnSelectionDataSourceTests: XCTestCase {
  private let dataSource = RewardAddOnSelectionDataSource()
  private let tableView = UITableView()

  func testLoadRewards() {
    let project = Project.cosmicSurgery
    let rewardsData = project.rewards.map { reward -> RewardAddOnCellData in
      .init(project: project, reward: reward, shippingRule: .template)
    }

    self.dataSource.load(rewardsData)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(project.rewards.count, self.dataSource.numberOfItems(in: 0))
  }
}
