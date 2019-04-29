import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi

final class PledgeDataSourceTests: XCTestCase {
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  let dataSource = PledgeDataSource()
  let tableView = UITableView(frame: .zero, style: .plain)

  func testLoad() {
    self.dataSource.load(amount: 100, currency: "USD", delivery: "September 2020")

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(PledgeAmountCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 1))
    XCTAssertEqual(PledgeDescriptionCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 0))
    XCTAssertEqual(PledgeRowCell.defaultReusableId, self.dataSource.reusableId(item: 1, section: 1))
    XCTAssertEqual(PledgeRowCell.defaultReusableId, self.dataSource.reusableId(item: 0, section: 2))

  }
}
