@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class PledgePaymentPlansDataSourceTest: XCTestCase {
  private let dataSource = PledgePaymentPlansDataSource()
  private let tableView = UITableView()

  func testLoad_DefaultState() {
    let defaultData = PledgePaymentPlansAndSelectionData(selectedPlan: .pledgeinFull)

    self.dataSource.load(defaultData)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))

    XCTAssertEqual(1, self.dataSource.numberOfItems(in: PledgePaymentPlansType.pledgeinFull.rawValue))

    XCTAssertEqual(1, self.dataSource.numberOfItems(in: PledgePaymentPlansType.pledgeOverTime.rawValue))

    XCTAssertEqual(
      "PledgePaymentPlanInFullCell",
      self.dataSource.reusableId(item: 0, section: PledgePaymentPlansType.pledgeinFull.rawValue)
    )

    XCTAssertEqual(
      "PledgePaymentPlanPlotCell",
      self.dataSource.reusableId(
        item: 0,
        section: PledgePaymentPlansType.pledgeOverTime.rawValue
      )
    )
  }
}
