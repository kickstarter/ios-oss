import XCTest
@testable import Kickstarter_iOS
@testable import Library
@testable import KsApi
import Prelude

internal final class DashboardDataSourceTests: XCTestCase {
  let dataSource = DashboardDataSource()
  let tableView = UITableView()

  func testDataSource() {
    let project = Project.template

    XCTAssertEqual(0, self.dataSource.numberOfSectionsInTableView(tableView))

    self.dataSource.load(project: project)

    XCTAssertEqual(2, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual("DashboardContextCell", self.dataSource.reusableId(item: 0, section: 0))
    XCTAssertEqual("DashboardActionCell", self.dataSource.reusableId(item: 0, section: 1))
    XCTAssertEqual(project, self.dataSource[itemSection: (0, 0)] as? Project)

    let rewardStats = [ProjectStatsEnvelope.RewardStats.template]

    self.dataSource.load(rewardStats: rewardStats, project: project)

    XCTAssertEqual(4, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(2, self.dataSource.tableView(tableView, numberOfRowsInSection: 3))
    XCTAssertEqual("Padding", self.dataSource.reusableId(item: 0, section: 3))
    XCTAssertEqual("DashboardRewardsCell", self.dataSource.reusableId(item: 1, section: 3))

    let videoStats = ProjectStatsEnvelope.VideoStats.template

    self.dataSource.load(videoStats: videoStats)

    XCTAssertEqual(6, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(2, self.dataSource.tableView(tableView, numberOfRowsInSection: 5))
    XCTAssertEqual("Padding", self.dataSource.reusableId(item: 0, section: 5))
    XCTAssertEqual("DashboardVideoCell", self.dataSource.reusableId(item: 1, section: 5))
  }
}
