import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi
import Prelude

internal final class PaymentMethodsDataSourceTests: XCTestCase {

  let dataSource = PaymentMethodsDataSource()
  let tableView = UITableView(frame: .zero)

  func testDataSource() {

    let cards = GraphUserCreditCard.template.storedCards.nodes
    self.dataSource.load(creditCards: cards)

    XCTAssertEqual(7, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))

    XCTAssertEqual("CreditCardCell", self.dataSource.reusableId(item: 0, section: 0))
  }
}
