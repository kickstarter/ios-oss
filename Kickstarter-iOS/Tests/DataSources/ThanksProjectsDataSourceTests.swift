import XCTest
@testable import Kickstarter_iOS
@testable import Library
@testable import Models_TestHelpers
import Models
import Prelude

final class ThanksProjectsDataSourceTests: XCTestCase {
  let dataSource = ThanksProjectsDataSource()
  let collectionView = UICollectionView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0),
                                        collectionViewLayout: UICollectionViewLayout())

  func testLoadData() {
    let projects = [
      Project.template |> Project.lens.id *~ 1,
      Project.template |> Project.lens.id *~ 2,
      Project.template |> Project.lens.id *~ 3
    ]
    dataSource.loadData(projects: projects, category: Category.games)

    XCTAssertEqual(1, self.dataSource.numberOfSectionsInCollectionView(collectionView))
    XCTAssertEqual(4, self.dataSource.collectionView(collectionView, numberOfItemsInSection: 0))

  }

  func testProjectAtIndexPaths() {
    let projects = [
      Project.template |> Project.lens.id *~ 1,
      Project.template |> Project.lens.id *~ 2,
      Project.template |> Project.lens.id *~ 3
    ]
    dataSource.loadData(projects: projects, category: Category.art)

    let indexPath0 = NSIndexPath(forItem: 0, inSection: 0)
    let indexPath1 = NSIndexPath(forItem: 1, inSection: 0)
    let indexPath2 = NSIndexPath(forItem: 2, inSection: 0)
    let indexPath3 = NSIndexPath(forItem: 3, inSection: 0)

    XCTAssertEqual(Project.template |> Project.lens.id *~ 1, dataSource.projectAtIndexPath(indexPath0))
    XCTAssertEqual(Project.template |> Project.lens.id *~ 2, dataSource.projectAtIndexPath(indexPath1))
    XCTAssertEqual(Project.template |> Project.lens.id *~ 3, dataSource.projectAtIndexPath(indexPath2))
    XCTAssertNil(dataSource.projectAtIndexPath(indexPath3), "Project is nil for non-project item")
  }

  func testCategoryAtIndexPaths() {
    let projects = [
      Project.template |> Project.lens.id *~ 1,
      Project.template |> Project.lens.id *~ 2,
      Project.template |> Project.lens.id *~ 3
    ]
    dataSource.loadData(projects: projects, category: Category.games)

    let indexPath0 = NSIndexPath(forItem: 0, inSection: 0)
    let indexPath1 = NSIndexPath(forItem: 1, inSection: 0)
    let indexPath2 = NSIndexPath(forItem: 2, inSection: 0)
    let indexPath3 = NSIndexPath(forItem: 3, inSection: 0)

    XCTAssertNil(dataSource.categoryAtIndexPath(indexPath0), "Category is nil for non-category item")
    XCTAssertNil(dataSource.categoryAtIndexPath(indexPath1), "Category is nil for non-category item")
    XCTAssertNil(dataSource.categoryAtIndexPath(indexPath2), "Category is nil for non-category item")
    XCTAssertEqual(Category.games, dataSource.categoryAtIndexPath(indexPath3))
  }
}
