@testable import Kickstarter_Framework
import Prelude
import XCTest

final class PillCollectionViewDataSourceTests: XCTestCase {
  private let dataSource = PillCollectionViewDataSource()
  private let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  )

  func testLoadValues() {
    self.dataSource.load(["one", "two", "three"])

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.collectionView))
    XCTAssertEqual(3, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 0))
  }
}
