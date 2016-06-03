import XCTest
import Models
@testable import Kickstarter_iOS
@testable import Library
@testable import Models_TestHelpers
import Prelude

internal final class ProfileDataSourceTests: XCTestCase {
  let dataSource = ProfileDataSource()
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

  func testDataSource() {
    let liveProject = Project.template
    let successfulProject = Project.template |> Project.lens.state .~ .successful
    let failedProject = Project.template |> Project.lens.state .~ .failed

    self.dataSource.load(projects: [liveProject, successfulProject, failedProject])

    XCTAssertEqual(3, self.dataSource.collectionView(collectionView, numberOfItemsInSection: 0))

    XCTAssertEqual(liveProject, self.dataSource[itemSection: (0, 0)] as? Project)
    XCTAssertEqual("ProfileProjectCell", self.dataSource.reusableId(item: 0, section: 0))

    XCTAssertEqual(successfulProject, self.dataSource[itemSection: (1, 0)] as? Project)
    XCTAssertEqual("ProfileProjectCell", self.dataSource.reusableId(item: 1, section: 0))

    XCTAssertEqual(failedProject, self.dataSource[itemSection: (2, 0)] as? Project)
    XCTAssertEqual("ProfileProjectCell", self.dataSource.reusableId(item: 2, section: 0))
  }
}
