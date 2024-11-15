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

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))

    XCTAssertEqual(2, self.dataSource.numberOfItems(in: PledgePaymentPlansType.pledgeinFull.rawValue))

    XCTAssertEqual(
      "PledgePaymentPlanCell",
      self.dataSource.reusableId(item: 0, section: 0)
    )

    XCTAssertEqual(
      "PledgePaymentPlanCell",
      self.dataSource.reusableId(item: 1, section: 0)
    )
  }
}
