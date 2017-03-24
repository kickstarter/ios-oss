import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi
import Prelude

final class SearchDataSourceTests: XCTestCase {
  let dataSource = SearchDataSource()
  let tableView = UITableView()

  func testPopularTitle() {
    let section = SearchDataSource.Section.popularTitle.rawValue

    dataSource.popularTitle(isVisible: false)
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: section))

    dataSource.popularTitle(isVisible: true)
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
    XCTAssertEqual("MostPopularCell", self.dataSource.reusableId(item: 0, section: section))
  }

  func testProjects() {
    let section = SearchDataSource.Section.projects.rawValue

    dataSource.load(projects: [
      .template |> Project.lens.id .~ 1,
      .template |> Project.lens.id .~ 2,
      .template |> Project.lens.id .~ 3
      ])

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(3, self.dataSource.tableView(tableView, numberOfRowsInSection: section))

    XCTAssertEqual("MostPopularSearchProjectCell", self.dataSource.reusableId(item: 0, section: section))
    XCTAssertEqual("SearchProjectCell", self.dataSource.reusableId(item: 1, section: section))
    XCTAssertEqual("SearchProjectCell", self.dataSource.reusableId(item: 2, section: section))
  }

  func testProjects_WithNoResults() {
    let section = SearchDataSource.Section.projects.rawValue

    dataSource.load(projects: [])

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
  }

  func testProjects_WithSingleResult() {
    let section = SearchDataSource.Section.projects.rawValue

    dataSource.load(projects: [.template |> Project.lens.id .~ 1])

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: section))

    XCTAssertEqual("MostPopularSearchProjectCell", self.dataSource.reusableId(item: 0, section: section))
  }
}
