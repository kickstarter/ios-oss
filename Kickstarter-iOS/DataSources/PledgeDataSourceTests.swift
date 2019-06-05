@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import XCTest

final class PledgeDataSourceTests: XCTestCase {
  let dataSource = PledgeDataSource()
  let tableView = UITableView(frame: .zero, style: .plain)

  // swiftlint:disable line_length
  func testLoad_loggedIn() {
    let data = PledgeTableViewData(
      amount: 100, currencySymbol: "$", estimatedDelivery: "May 2020",
      shippingLocation: "", shippingCost: 0.0, project: Project.template,
      isLoggedIn: true, requiresShippingRules: true
    )
    self.dataSource.load(data: data)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(PledgeDescriptionCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 0))
    XCTAssertEqual(PledgeAmountCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 1))
    XCTAssertEqual(PledgeShippingLocationCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: 1))
    XCTAssertEqual(PledgeRowCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 2))
  }

  func testLoad_loggedOut() {
    let data = PledgeTableViewData(
      amount: 100, currencySymbol: "$", estimatedDelivery: "May 2020",
      shippingLocation: "", shippingCost: 0.0, project: Project.template,
      isLoggedIn: false, requiresShippingRules: true
    )
    self.dataSource.load(data: data)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(PledgeDescriptionCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 0))
    XCTAssertEqual(PledgeAmountCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 1))
    XCTAssertEqual(PledgeShippingLocationCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: 1))
    XCTAssertEqual(PledgeRowCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 2))
    XCTAssertEqual(PledgeContinueCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: 2))
  }

  func testLoad_requiresShippingRules_isFalse() {
    let data = PledgeTableViewData(
      amount: 100, currencySymbol: "$", estimatedDelivery: "May 2020",
      shippingLocation: "", shippingCost: 0.0, project: Project.template,
      isLoggedIn: false, requiresShippingRules: false
    )
    self.dataSource.load(data: data)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: PledgeDataSource.Section.project.rawValue))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: PledgeDataSource.Section.inputs.rawValue))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: PledgeDataSource.Section.summary.rawValue))
    XCTAssertEqual(PledgeDescriptionCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: PledgeDataSource.Section.project.rawValue))
    XCTAssertEqual(PledgeAmountCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: PledgeDataSource.Section.inputs.rawValue))
    XCTAssertEqual(PledgeRowCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: PledgeDataSource.Section.summary.rawValue))
    XCTAssertEqual(PledgeContinueCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: PledgeDataSource.Section.summary.rawValue))
  }

  func testLoadSelectedShippingRule_requiresShipping_isTrue() {
    let data = PledgeTableViewData(
      amount: 100, currencySymbol: "$", estimatedDelivery: "May 2020",
      shippingLocation: "", shippingCost: 0.0, project: Project.template,
      isLoggedIn: false, requiresShippingRules: true
    )
    let selectedShippingData = SelectedShippingRuleData(
      location: "Brooklyn", shippingCost: 1.0,
      project: Project.template
    )

    let indexPath = IndexPath(item: 1, section: PledgeDataSource.Section.inputs.rawValue)

    let initialShippingCellData = PledgeDataSource.PledgeInputRow.shippingLocation(
      location: "",
      shippingCost: 0.0,
      project: .template
    )

    self.dataSource.load(data: data)

    XCTAssertEqual(initialShippingCellData, self.dataSource[indexPath] as? PledgeDataSource.PledgeInputRow)

    self.dataSource.loadSelectedShippingRule(data: selectedShippingData)

    let shippingCellData = PledgeDataSource.PledgeInputRow.shippingLocation(
      location: "Brooklyn",
      shippingCost: 1.0,
      project: .template
    )

    XCTAssertEqual(shippingCellData, self.dataSource[indexPath] as? PledgeDataSource.PledgeInputRow)
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: PledgeDataSource.Section.inputs.rawValue))
  }

  func testLoadSelectedShippingRule_requiresShipping_isFalse() {
    let data = PledgeTableViewData(
      amount: 100, currencySymbol: "$", estimatedDelivery: "May 2020",
      shippingLocation: "", shippingCost: 0.0, project: Project.template,
      isLoggedIn: false, requiresShippingRules: false
    )
    let selectedShippingData = SelectedShippingRuleData(
      location: "Brooklyn", shippingCost: 1.0,
      project: Project.template
    )

    self.dataSource.load(data: data)
    self.dataSource.loadSelectedShippingRule(data: selectedShippingData)

    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: PledgeDataSource.Section.inputs.rawValue))
  }

  func testShippingCellIndexPath_isNil() {
    let data = PledgeTableViewData(
      amount: 100, currencySymbol: "$", estimatedDelivery: "May 2020",
      shippingLocation: "", shippingCost: 0.0, project: Project.template,
      isLoggedIn: false, requiresShippingRules: false
    )

    self.dataSource.load(data: data)

    XCTAssertNil(self.dataSource.shippingCellIndexPath())
  }

  func testShippingCellIndexPath_isNotNil() {
    let data = PledgeTableViewData(
      amount: 100, currencySymbol: "$", estimatedDelivery: "May 2020",
      shippingLocation: "", shippingCost: 0.0, project: Project.template,
      isLoggedIn: false, requiresShippingRules: true
    )

    self.dataSource.load(data: data)

    let indexPath = self.dataSource.shippingCellIndexPath()

    XCTAssertNotNil(indexPath)
    XCTAssertEqual(indexPath, IndexPath(item: 1, section: PledgeDataSource.Section.inputs.rawValue))
  }

  // swiftlint:enable line_length
}
