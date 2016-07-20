import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi
import Prelude

internal final class DashboardProjectsDrawerDataSourceTests: XCTestCase {
  let dataSource = DashboardProjectsDrawerDataSource()
  let tableView = UITableView()

  func testDataSource() {
    let project1 = Project.template
    let project2 = .template |> Project.lens.id .~ 2

    let data1 = ProjectsDrawerData(project: project1, indexNum: 0, isChecked: true)
    let data2 = ProjectsDrawerData(project: project2, indexNum: 1, isChecked: false)
    let data = [data1, data2]

    XCTAssertEqual(0, self.dataSource.numberOfSectionsInTableView(tableView))

    self.dataSource.load(data: data)

    XCTAssertEqual(1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(2, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual("DashboardProjectsDrawerCell", self.dataSource.reusableId(item: 0, section: 0))
    XCTAssertEqual("DashboardProjectsDrawerCell", self.dataSource.reusableId(item: 1, section: 0))

    XCTAssertEqual(project1, self.dataSource.projectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)))
    XCTAssertEqual(project2, self.dataSource.projectAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)))
  }
}
