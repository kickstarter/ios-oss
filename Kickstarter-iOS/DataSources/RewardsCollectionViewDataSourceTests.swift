@testable import Kickstarter_Framework
@testable import KsApi
import XCTest

final class RewardsCollectionViewDataSourceTests: XCTestCase {
  private let dataSource = RewardsCollectionViewDataSource()
  private let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  )

  func testLoadRewards() {
    let rewards = [Reward.template, Reward.template]

    self.dataSource.load(rewards: rewards)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.collectionView))
    XCTAssertEqual(2, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 0))
  }
}
