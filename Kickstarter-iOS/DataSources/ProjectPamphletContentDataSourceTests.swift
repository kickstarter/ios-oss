import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi
import Prelude

final class ProjectPamphletContentDataSourceTests: TestCase {
  let dataSource = ProjectPamphletContentDataSource()
  let tableView = UITableView()

  func testIndexPathIsPledgeAnyAmountCell() {
    let project = Project.template
    dataSource.load(project: project)

    let section = ProjectPamphletContentDataSource.Section.calloutReward.rawValue
    XCTAssertTrue(dataSource.indexPathIsPledgeAnyAmountCell(.init(row: 0, section: section)))
  }

  func testAvailableRewardsSection_ShowsCorrectValues() {
    let availableSection = ProjectPamphletContentDataSource.Section.availableRewards.rawValue
    let unavailableSection = ProjectPamphletContentDataSource.Section.unavailableRewards.rawValue

    let reward = Reward.template
      |> Reward.lens.remaining .~ 1
    let project = Project.template
      |> Project.lens.rewards .~ [reward]

    dataSource.load(project: project)

    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: availableSection))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: unavailableSection))
  }

  func testUnavailableRewardsSection_ShowsCorrectValues() {
    let availableSection = ProjectPamphletContentDataSource.Section.availableRewards.rawValue
    let unavailableSection = ProjectPamphletContentDataSource.Section.unavailableRewards.rawValue

    let reward = Reward.template
      |> Reward.lens.remaining .~ 0
    let project = Project.template
      |> Project.lens.rewards .~ [reward]

    dataSource.load(project: project)

    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: availableSection))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: unavailableSection))
  }
}
