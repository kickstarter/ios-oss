import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi

final class PledgeDataSourceTests: XCTestCase {
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  let tableView = UITableView()
  let dataSource = PledgeDataSource()

  func testLoad() {
    dataSource.load(amount: 100, currency: "USD")

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: collectionView))
    XCTAssertEqual(2, self.dataSource.collectionView(collectionView, numberOfItemsInSection: 1))
    XCTAssertEqual(1, self.dataSource.collectionView(collectionView, numberOfItemsInSection: 2))
  }

  func testLoadDescription() {
    dataSource.load(deliveryDescription: "September 2020")

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
  }
}
