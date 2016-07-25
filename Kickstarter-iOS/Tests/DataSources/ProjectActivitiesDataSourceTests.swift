import XCTest
@testable import Library
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude

internal final class ProjectActivitiesDataSourceTests: XCTestCase {
  let dataSource = ProjectActivitiesDataSource()
  let tableView = UITableView()

  func testDataSource() {
    let timeZone = NSTimeZone(abbreviation: "UTC")!
    let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)!
    calendar.timeZone = timeZone

    withEnvironment(calendar: calendar, timeZone: timeZone) {
      let section = ProjectActivitiesDataSource.Section.activities.rawValue
      let project = Project.template
      let activities = [
        Activity.template
          |> Activity.lens.category .~ Activity.Category.backing
          |> Activity.lens.createdAt .~ 1474606800 // 2016-09-23T05:00:00Z
          |> Activity.lens.project .~ project,
        Activity.template
          |> Activity.lens.category .~ Activity.Category.commentPost
          |> Activity.lens.createdAt .~ 1474605000 // 2016-09-23T04:30:00Z
          |> Activity.lens.project .~ project,
        Activity.template
          |> Activity.lens.category .~ Activity.Category.success
          |> Activity.lens.createdAt .~ 1474700400 // 2016-09-24T07:00:00Z
          |> Activity.lens.project .~ project,
        Activity.template
          |> Activity.lens.category .~ Activity.Category.launch
          |> Activity.lens.createdAt .~ 1474538400 // 2016-09-22T10:00:00Z
          |> Activity.lens.project .~ project
      ]

      self.dataSource.load(activities: activities, project: project)

      XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
      XCTAssertEqual(7, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
      XCTAssertEqual("ProjectActivityDateCell", self.dataSource.reusableId(item: 0, section: section))
      XCTAssertEqual("ProjectActivitySuccessCell", self.dataSource.reusableId(item: 1, section: section))
      XCTAssertEqual("ProjectActivityDateCell", self.dataSource.reusableId(item: 2, section: section))
      XCTAssertEqual("ProjectActivityBackingCell", self.dataSource.reusableId(item: 3, section: section))
      XCTAssertEqual("ProjectActivityCommentCell", self.dataSource.reusableId(item: 4, section: section))
      XCTAssertEqual("ProjectActivityDateCell", self.dataSource.reusableId(item: 5, section: section))
      XCTAssertEqual("ProjectActivityLaunchCell", self.dataSource.reusableId(item: 6, section: section))
    }
  }

  func testEmptyState() {
    let section = ProjectActivitiesDataSource.Section.emptyState.rawValue
    self.dataSource.emptyState(visible: true)

    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
    XCTAssertEqual("ProjectActivityEmptyStateCell", self.dataSource.reusableId(item: 0, section: section))
  }
}
