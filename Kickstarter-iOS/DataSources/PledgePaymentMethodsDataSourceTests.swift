@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
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
        projectCountry: "Country 1",
        isErroredPaymentMethod: false
      ),
      (
        card: GraphUserCreditCard.visa,
        isEnabled: false,
        isSelected: false,
        projectCountry: "Country 2",
        isErroredPaymentMethod: false
      )
    ]

    self.dataSource.load(cellData)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      2,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.paymentMethods.rawValue)
    )
    XCTAssertEqual(
      1,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.addNewCard.rawValue)
    )
  }

  func testLoadingState() {
    self.dataSource.load([], isLoading: true)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView), "Sections padded")
    XCTAssertEqual(
      1,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.loading.rawValue)
    )
    XCTAssertEqual(
      0,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.paymentMethods.rawValue)
    )
    XCTAssertEqual(
      0,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.addNewCard.rawValue)
    )
  }
}
