@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class DiscoveryProjectTagsCollectionViewDataSourceTests: XCTestCase {
  private let dataSource = DiscoveryProjectTagsCollectionViewDataSource()
  private let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  )

  func testDataSource() {
    let values = [
      DiscoveryProjectTagPillCellValue(type: .green, tagIconImageName: "icon-pwl", tagLabelText: "PWL"),
      DiscoveryProjectTagPillCellValue(type: .grey, tagIconImageName: "icon-category", tagLabelText: "Art"),
      DiscoveryProjectTagPillCellValue(type: .grey, tagIconImageName: "icon-category", tagLabelText: "Games")
    ]

    self.dataSource.load(with: values)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.collectionView))
    XCTAssertEqual(3, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 0))
    XCTAssertEqual("DiscoveryProjectTagPillCell", self.dataSource.reusableId(item: 0, section: 0))
  }
}
