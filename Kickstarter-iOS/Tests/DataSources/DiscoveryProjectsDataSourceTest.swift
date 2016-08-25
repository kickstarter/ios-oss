import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi
import Prelude

final class DiscoveryProjectsDataSourceTests: XCTestCase {
  let dataSource = DiscoveryProjectsDataSource()
  let tableView = UITableView()

  func testOnboarding() {
    let section = DiscoveryProjectsDataSource.Section.onboarding.rawValue

    self.dataSource.show(onboarding: true)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: section))

    self.dataSource.show(onboarding: false)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
  }

  func testActivitySample() {
    let section = DiscoveryProjectsDataSource.Section.activitySample.rawValue

    self.dataSource.load(activities: [.template])

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: section))

    self.dataSource.load(activities: [])

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
  }

  func testProjects() {
    let section = DiscoveryProjectsDataSource.Section.projects.rawValue

    self.dataSource.load(projects: [.template, .template, .template])

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(3, self.dataSource.tableView(tableView, numberOfRowsInSection: section))

    self.dataSource.load(projects: [])

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
  }
}
