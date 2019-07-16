@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class PledgePaymentMethodsDataSourceTests: XCTestCase {
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  let dataSource = PledgePaymentMethodsDataSource()

  func testDataSource() {
    let cards = GraphUserCreditCard.template.storedCards.nodes
    self.dataSource.load(creditCards: cards)

    XCTAssertEqual(8, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 0))

    XCTAssertEqual("PledgeCreditCardCell", self.dataSource.reusableId(item: 0, section: 0))
  }
}
