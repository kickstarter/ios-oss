@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ThanksProjectsDataSourceTests: XCTestCase {
  let dataSource = ThanksProjectsDataSource()
  let collectionView = UICollectionView(
    frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0),
    collectionViewLayout: UICollectionViewLayout()
  )

  func testLoadData() {
    let projects = [
      Project.template |> Project.lens.id .~ 1,
      Project.template |> Project.lens.id .~ 2,
      Project.template |> Project.lens.id .~ 3
    ]
    self.dataSource.loadData(projects: projects, category: Category.games)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.collectionView))
    XCTAssertEqual(4, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 0))
  }

  func testLoadData_ExperimentalVariant() {
    let projects = [
      Project.template |> Project.lens.id .~ 1,
      Project.template |> Project.lens.id .~ 2,
      Project.template |> Project.lens.id .~ 3
    ]
    self.dataSource
      .loadData(projects: projects, category: Category.games, nativeProjectCardsVariant: .variant1)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.collectionView))
    XCTAssertEqual(4, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 0))
  }

  func testProjectAtIndexPaths() {
    let projects = [
      Project.template |> Project.lens.id .~ 1,
      Project.template |> Project.lens.id .~ 2,
      Project.template |> Project.lens.id .~ 3
    ]
    self.dataSource.loadData(projects: projects, category: Category.art)

    let indexPath0 = IndexPath(item: 0, section: 0)
    let indexPath1 = IndexPath(item: 1, section: 0)
    let indexPath2 = IndexPath(item: 2, section: 0)
    let indexPath3 = IndexPath(item: 3, section: 0)

    XCTAssertEqual(Project.template |> Project.lens.id .~ 1, self.dataSource.projectAtIndexPath(indexPath0))
    XCTAssertEqual(Project.template |> Project.lens.id .~ 2, self.dataSource.projectAtIndexPath(indexPath1))
    XCTAssertEqual(Project.template |> Project.lens.id .~ 3, self.dataSource.projectAtIndexPath(indexPath2))
    XCTAssertNil(self.dataSource.projectAtIndexPath(indexPath3), "Project is nil for non-project item")
  }

  func testCategoryAtIndexPaths() {
    let projects = [
      Project.template |> Project.lens.id .~ 1,
      Project.template |> Project.lens.id .~ 2,
      Project.template |> Project.lens.id .~ 3
    ]
    self.dataSource.loadData(projects: projects, category: Category.games)

    XCTAssertEqual("DiscoveryPostcardCell", self.dataSource.reusableId(item: 0, section: 0))
    XCTAssertEqual("DiscoveryPostcardCell", self.dataSource.reusableId(item: 1, section: 0))
    XCTAssertEqual("DiscoveryPostcardCell", self.dataSource.reusableId(item: 2, section: 0))
    XCTAssertEqual("ThanksCategoryCell", self.dataSource.reusableId(item: 3, section: 0))
  }
}
