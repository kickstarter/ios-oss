@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
import Library
@testable import LibraryTestHelpers
import Prelude
import XCTest

final class RewardsCollectionViewDataSourceTests: XCTestCase {
  private let dataSource = RewardsCollectionViewDataSource()
  private let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  )

  func testLoadRewards() {
    let project = Project.cosmicSurgery
    let rewardsData = project.rewards.map { reward -> RewardCardViewData in (project, reward, .pledge, nil) }

    self.dataSource.load(rewardsData)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.collectionView))
    XCTAssertEqual(project.rewards.count, self.dataSource.collectionView(
      self.collectionView,
      numberOfItemsInSection: 0
    ))
  }
}
