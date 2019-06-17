@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

// swiftlint:disable line_length

final class PledgeDataSourceTests: XCTestCase {
  let dataSource = PledgeDataSource()
  let tableView = UITableView(frame: .zero, style: .plain)

  func testLoad_LoggedIn() {
    self.dataSource.load(project: .template, reward: .template, isLoggedIn: true)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(PledgeDescriptionCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 0))
    XCTAssertEqual(PledgeAmountCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 1))
    XCTAssertEqual(PledgeRowCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 2))
  }

  func testLoad_LoggedOut() {
    self.dataSource.load(project: .template, reward: .template, isLoggedIn: false)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(PledgeDescriptionCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 0))
    XCTAssertEqual(PledgeAmountCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 1))
    XCTAssertEqual(PledgeRowCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 2))
    XCTAssertEqual(PledgeContinueCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: 2))
  }

  func testLoad_Shipping_Disabled() {
    self.dataSource.load(project: .template, reward: .template, isLoggedIn: false)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: PledgeDataSource.Section.project.rawValue))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: PledgeDataSource.Section.inputs.rawValue))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: PledgeDataSource.Section.summary.rawValue))
    XCTAssertEqual(PledgeDescriptionCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: PledgeDataSource.Section.project.rawValue))
    XCTAssertEqual(PledgeAmountCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: PledgeDataSource.Section.inputs.rawValue))
    XCTAssertEqual(PledgeRowCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: PledgeDataSource.Section.summary.rawValue))
    XCTAssertEqual(PledgeContinueCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: PledgeDataSource.Section.summary.rawValue))
  }

  func testLoad_Shipping_Enabled() {
    let shipping = Reward.Shipping.template |> Reward.Shipping.lens.enabled .~ true
    let reward = Reward.template |> Reward.lens.shipping .~ shipping

    self.dataSource.load(project: .template, reward: reward, isLoggedIn: false)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: PledgeDataSource.Section.project.rawValue))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: PledgeDataSource.Section.inputs.rawValue))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: PledgeDataSource.Section.summary.rawValue))
    XCTAssertEqual(PledgeDescriptionCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: PledgeDataSource.Section.project.rawValue))
    XCTAssertEqual(PledgeAmountCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: PledgeDataSource.Section.inputs.rawValue))
    XCTAssertEqual(PledgeShippingLocationCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: PledgeDataSource.Section.inputs.rawValue))
    XCTAssertEqual(PledgeRowCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: PledgeDataSource.Section.summary.rawValue))
    XCTAssertEqual(PledgeContinueCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: PledgeDataSource.Section.summary.rawValue))
  }
}
