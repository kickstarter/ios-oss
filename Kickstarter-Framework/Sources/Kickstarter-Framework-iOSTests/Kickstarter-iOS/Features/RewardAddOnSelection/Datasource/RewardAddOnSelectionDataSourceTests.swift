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
    let rewardsData = project.rewards.map { reward -> RewardAddOnCardViewData in
      .init(
        project: project,
        reward: reward,
        context: .pledge,
        shippingRule: .template,
        selectedQuantities: [:]
      )
    }
    .map(RewardAddOnSelectionDataSourceItem.rewardAddOn)

    self.dataSource.load(rewardsData)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(project.rewards.count, self.dataSource.numberOfItems(in: 0))
  }

  func testLoadRewards_EmptyState() {
    self.dataSource.load([.emptyState(.addOnsUnavailable)])

    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertTrue(self.dataSource.isEmptyStateIndexPath(IndexPath(row: 0, section: 1)))
  }

  func testLoadRewards_EmptyState_Error() {
    self.dataSource.load([.emptyState(.errorPullToRefresh)])

    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertTrue(self.dataSource.isEmptyStateIndexPath(IndexPath(row: 0, section: 1)))
  }
}
