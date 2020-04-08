import Foundation
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ProjectSummaryCarouselDataSourceTests: TestCase {
  let dataSource = ProjectSummaryCarouselDataSource()
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

  func testLoadDataIntoDataSource() {
    let items = [
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whatIsTheProject,
        response: "Test copy 1"
      ),
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whatWillYouDoWithTheMoney,
        response: "Test copy 2"
      ),
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whoAreYou,
        response: "Test copy 3"
      )
    ]

    self.dataSource.load(items)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.collectionView))
    XCTAssertEqual(3, self.dataSource.numberOfItems(in: 0))
  }
}
