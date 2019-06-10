@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class BackerDashboardProjectsDataSourceTests: XCTestCase {
  let dataSource = BackerDashboardProjectsDataSource()
  let tableView = UITableView()
  let sectionEmpty = BackerDashboardProjectsDataSource.Section.emptyState.rawValue
  let sectionProjects = BackerDashboardProjectsDataSource.Section.projects.rawValue

  func testProjects() {
    self.dataSource.load(projects: [.template])

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))

    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.sectionProjects))
    XCTAssertEqual(
      "BackerDashboardProjectCell",
      self.dataSource.reusableId(item: 0, section: self.sectionProjects)
    )

    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.sectionEmpty))
    XCTAssertNil(self.dataSource.reusableId(item: 0, section: self.sectionEmpty))
  }

  func testEmptyState() {
    self.dataSource.emptyState(visible: true, projectsType: .backed)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))

    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.sectionEmpty))
    XCTAssertEqual(
      "BackerDashboardEmptyStateCell",
      self.dataSource.reusableId(item: 0, section: self.sectionEmpty)
    )
  }
}
