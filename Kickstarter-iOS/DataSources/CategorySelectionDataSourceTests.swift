@testable import Kickstarter_Framework
import Prelude
import XCTest

final class CategorySelectionDataSourceTests: XCTestCase {
  private let dataSource = CategorySelectionDataSource()
  private let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  )

  func testLoadValues() {
    self.dataSource.load(["title1", "title2", "title3"], categories: [
      ["one", "two"],
      ["red", "green"],
      ["monday"]
    ])

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.collectionView))
    XCTAssertEqual(2, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 0))
    XCTAssertEqual(2, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 1))
    XCTAssertEqual(1, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 2))
  }

  func testValues() {
    self.dataSource.load(["title1", "title2", "title3"], categories: [
      ["one", "two"],
      ["red", "green"],
      ["monday"]
    ])

    let indexPath0 = IndexPath(item: 0, section: 0)
    let indexPath01 = IndexPath(item: 1, section: 0)
    let indexPath1 = IndexPath(item: 0, section: 1)
    let indexPath11 = IndexPath(item: 1, section: 1)
    let indexPath2 = IndexPath(item: 0, section: 2)

    let value0 = self.dataSource[indexPath0] as? (String, IndexPath?)
    let value01 = self.dataSource[indexPath01] as? (String, IndexPath?)
    let value1 = self.dataSource[indexPath1] as? (String, IndexPath?)
    let value11 = self.dataSource[indexPath11] as? (String, IndexPath?)
    let value2 = self.dataSource[indexPath2] as? (String, IndexPath?)

    XCTAssertEqual("one", value0?.0)
    XCTAssertEqual(indexPath0, value0?.1)
    XCTAssertEqual("two", value01?.0)
    XCTAssertEqual(indexPath01, value01?.1)
    XCTAssertEqual("red", value1?.0)
    XCTAssertEqual(indexPath1, value1?.1)
    XCTAssertEqual("green", value11?.0)
    XCTAssertEqual(indexPath11, value11?.1)
    XCTAssertEqual("monday", value2?.0)
    XCTAssertEqual(indexPath2, value2?.1)
  }
}
