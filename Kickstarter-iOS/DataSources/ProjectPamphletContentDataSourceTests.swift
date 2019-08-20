@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ProjectPamphletContentDataSourceTests: TestCase {

  
  let dataSource = ProjectPamphletContentDataSource()
  let tableView = UITableView()

  func testIndexPathIsPledgeAnyAmountCell() {
    let project = Project.template
    self.dataSource.load(project: project)

    let section = ProjectPamphletContentDataSource.Section.calloutReward.rawValue
    XCTAssertTrue(self.dataSource.indexPathIsPledgeAnyAmountCell(.init(row: 0, section: section)))
  }

  func testAvailableRewardsSection_ShowsCorrectValues() {
    let availableSection = ProjectPamphletContentDataSource.Section.availableRewards.rawValue
    let unavailableSection = ProjectPamphletContentDataSource.Section.unavailableRewards.rawValue

    let reward = Reward.template
      |> Reward.lens.remaining .~ 1
    let project = Project.template
      |> Project.lens.rewards .~ [reward]

    self.dataSource.load(project: project)

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

    self.dataSource.load(project: project)

    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: availableSection))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: unavailableSection))
  }

  func testRewardsSection_hidesWhen_nativeCheckoutFeatureEnabled_checkoutExperimentEnabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.nativeCheckout.rawValue: true]
      |> Config.lens.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]

    withEnvironment(config: config) {
      let availableReward = Reward.template
        |> Reward.lens.remaining .~ 1
      let unavailableReward = Reward.template
        |> Reward.lens.remaining .~ 0
      let project = Project.template
        |> Project.lens.rewards .~ [availableReward, unavailableReward]

      dataSource.load(project: project)

      XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    }
  }

  func testRewardsSection_showsWhen_nativeCheckoutFeatureEnabled_checkoutExperimentDisabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.nativeCheckout.rawValue: true]
      |> Config.lens.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]

    self.assertSectionIsShown(config)
  }

  func testRewardsSection_showsWhen_nativeCheckoutFeatureDisabled_checkoutExperimentEnabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.nativeCheckout.rawValue: false]
      |> Config.lens.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]

    self.assertSectionIsShown(config)
  }

  func testRewardsSection_showsWhen_nativeCheckoutFeatureDisabled_checkoutExperimentDisabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.nativeCheckout.rawValue: false]
      |> Config.lens.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]

    self.assertSectionIsShown(config)
  }

  private func assertSectionIsShown(_ config: Config) {
    let releaseBundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue,
                                   lang: "en")
    withEnvironment(config: config, mainBundle: releaseBundle) {
      let availableSection = ProjectPamphletContentDataSource.Section.availableRewards.rawValue
      let unavailableSection = ProjectPamphletContentDataSource.Section.unavailableRewards.rawValue

      let availableReward = Reward.template
        |> Reward.lens.remaining .~ 1
      let unavailableReward = Reward.template
        |> Reward.lens.remaining .~ 0
      let project = Project.template
        |> Project.lens.rewards .~ [availableReward, unavailableReward]

      dataSource.load(project: project)

      XCTAssertEqual(7, self.dataSource.numberOfSections(in: self.tableView))
      XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: availableSection))
      XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: unavailableSection))
    }
  }
}
