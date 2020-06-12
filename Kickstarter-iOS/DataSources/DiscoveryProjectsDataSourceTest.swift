@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class DiscoveryProjectsDataSourceTests: XCTestCase {
  let dataSource = DiscoveryProjectsDataSource()
  let tableView = UITableView()

  func testOnboarding() {
    let section = DiscoveryProjectsDataSource.Section.onboarding.rawValue

    self.dataSource.show(onboarding: true)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))

    self.dataSource.show(onboarding: false)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
  }

  func testEditorial() {
    let section = DiscoveryProjectsDataSource.Section.editorial.rawValue

    let editorialValue: DiscoveryEditorialCellValue = .init(
      title: "title", subtitle: "subtitle", imageName: "", tagId: .lightsOn
    )

    self.dataSource.showEditorial(value: editorialValue)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))

    self.dataSource.showEditorial(value: editorialValue)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section),
      "One only row is ever added"
    )
  }

  func testPersonalization() {
    let section = DiscoveryProjectsDataSource.Section.personalization.rawValue

    self.dataSource.showPersonalization(true)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))

    self.dataSource.showPersonalization(false)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
  }

  func testActivitySample() {
    let section = DiscoveryProjectsDataSource.Section.activitySample.rawValue

    self.dataSource.load(activities: [.template])

    XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))

    self.dataSource.load(activities: [])

    XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
  }

  func testProjects() {
    let section = DiscoveryProjectsDataSource.Section.projects.rawValue

    self.dataSource.load(projects: [.template, .template, .template])

    XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))

    self.dataSource.load(projects: [])

    XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
  }

  func testProjects_ExperimentVariant() {
    let section = DiscoveryProjectsDataSource.Section.projects.rawValue

    self.dataSource.load(
      projects: [.template, .template, .template],
      params: DiscoveryParams.defaults,
      projectCardVariant: .variant1
    )

    XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
  }
}
