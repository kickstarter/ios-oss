@testable import Kickstarter_Framework
@testable import KsApi
import Prelude
import XCTest

final class PledgePaymentMethodsDataSourceTests: XCTestCase {
  private let dataSource = PledgePaymentMethodsDataSource()
  private let tableView = UITableView()

  func testLoadValues() {
    let cellData = [
      (
        card: GraphUserCreditCard.amex,
        isEnabled: true,
        isSelected: true,
        projectCountry: "Country 1"
      ),
      (
        card: GraphUserCreditCard.visa,
        isEnabled: false,
        isSelected: false,
        projectCountry: "Country 2"
      )
    ]

    self.dataSource.load(cellData)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(2, self.dataSource.numberOfItems(in: 0))
  }
}
