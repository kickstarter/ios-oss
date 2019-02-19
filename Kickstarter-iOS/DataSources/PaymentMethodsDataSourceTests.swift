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

  func testCardDeletion() {
    let cards = GraphUserCreditCard.template.storedCards.nodes
    self.dataSource.load(creditCards: cards)

    guard let card = cards.first else {
      XCTFail("Card should exist")
      return
    }

    var deletedCard: GraphUserCreditCard.CreditCard?
    let deletionHandler = { card in
      deletedCard = card
    }

    self.dataSource.deletionHandler = deletionHandler
    self.dataSource.tableView(self.tableView, commit: .delete, forRowAt: .init(row: 0, section: 0))

    XCTAssertEqual(deletedCard, card)
  }
}
