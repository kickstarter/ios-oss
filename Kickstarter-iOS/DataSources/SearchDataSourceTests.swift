@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class SearchDataSourceTests: XCTestCase {
  let dataSource = SearchDataSource()
  let tableView = UITableView()

  func testPopularTitle() {
    let section = SearchDataSource.Section.popularTitle.rawValue

    self.dataSource.popularTitle(isVisible: false)
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))

    self.dataSource.popularTitle(isVisible: true)
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
    XCTAssertEqual("MostPopularCell", self.dataSource.reusableId(item: 0, section: section))
  }

  func testProjects() {
    let section = SearchDataSource.Section.projects.rawValue

    self.dataSource.load(projects: [
      .template |> Project.lens.id .~ 1,
      .template |> Project.lens.id .~ 2,
      .template |> Project.lens.id .~ 3
    ])

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))

    XCTAssertEqual("MostPopularSearchProjectCell", self.dataSource.reusableId(item: 0, section: section))
    XCTAssertEqual("SearchProjectCell", self.dataSource.reusableId(item: 1, section: section))
    XCTAssertEqual("SearchProjectCell", self.dataSource.reusableId(item: 2, section: section))
  }

  func testProjects_WithNoResults() {
    let section = SearchDataSource.Section.projects.rawValue

    self.dataSource.load(projects: [])

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
  }

  func testProjects_WithSingleResult() {
    let section = SearchDataSource.Section.projects.rawValue

    self.dataSource.load(projects: [.template |> Project.lens.id .~ 1])

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))

    XCTAssertEqual("MostPopularSearchProjectCell", self.dataSource.reusableId(item: 0, section: section))
  }
}
