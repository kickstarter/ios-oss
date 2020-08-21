import Foundation
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ManagePledgeDataSourceTests: TestCase {
  let dataSource = ManagePledgeDataSource()
  let tableView = UITableView()

  func testLoadDataIntoDataSource() {
    let rewards = [Reward.template, .template]
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ rewards

    self.dataSource.load(project: project, rewards: rewards)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(2, self.dataSource.numberOfItems(in: 0))
  }
}
