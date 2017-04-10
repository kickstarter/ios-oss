import XCTest
@testable import Library
@testable import Kickstarter_Framework
@testable import KsApi
import Prelude

final class BackerDashboardProjectsDataSourceTests: XCTestCase {
  let dataSource = BackerDashboardProjectsDataSource()
  let tableView = UITableView()
  let sectionEmpty = BackerDashboardProjectsDataSource.Section.emptyState.rawValue
  let sectionProjects = BackerDashboardProjectsDataSource.Section.projects.rawValue

  func testProjects() {
    self.dataSource.load(projects: [.template])

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: tableView))

    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: sectionProjects))
    XCTAssertEqual("BackerDashboardProjectCell",
                   self.dataSource.reusableId(item: 0, section: sectionProjects))

    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: sectionEmpty))
    XCTAssertNil(self.dataSource.reusableId(item: 0, section: sectionEmpty))
  }

  func testEmptyState() {
    self.dataSource.emptyState(visible: true, projectsType: .backed)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: tableView))

    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: sectionEmpty))
    XCTAssertEqual("BackerDashboardEmptyStateCell",
                   self.dataSource.reusableId(item: 0, section: sectionEmpty))
  }
}
