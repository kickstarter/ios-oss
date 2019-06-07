@testable import Kickstarter_Framework
@testable import KsApi
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
    let rewardsData = project.rewards.map { (project, Either<Reward, Backing>.left($0)) }

    self.dataSource.load(rewardsData)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.collectionView))
    XCTAssertEqual(project.rewards.count, self.dataSource.collectionView(
      self.collectionView,
      numberOfItemsInSection: 0
    ))
  }
}
