import XCTest
@testable import Kickstarter_iOS
@testable import Library
@testable import Models_TestHelpers
import Models

final class ActivitiesDataSourceTests: XCTestCase {
  let dataSource = ActivitiesDataSource()
  let tableView = UITableView()

  func testDataSource() {
    let updateActivity = ActivityFactory.updateActivity
    let backingActivity = ActivityFactory.backingActivity
    let successActivity = ActivityFactory.successActivity

    self.dataSource.emptyState(visible: true)

    XCTAssertEqual(1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual("ActivityEmptyStateCell", self.dataSource.reusableId(item: 0, section: 0))

    self.dataSource.load(activities: [updateActivity, backingActivity, successActivity])

    XCTAssertEqual(2, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual("ActivityEmptyStateCell", self.dataSource.reusableId(item: 0, section: 0))

    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(6, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))

    XCTAssertEqual(updateActivity, self.dataSource[itemSection: (0, 1)] as? Activity)
    XCTAssertEqual("ActivityUpdateCell", self.dataSource.reusableId(item: 0, section: 1))

    XCTAssertEqual("Padding", self.dataSource.reusableId(item: 1, section: 1))

    XCTAssertEqual(backingActivity, self.dataSource[itemSection: (2, 1)] as? Activity)
    XCTAssertEqual("ActivityFriendBackingCell", self.dataSource.reusableId(item: 2, section: 1))

    XCTAssertEqual("Padding", self.dataSource.reusableId(item: 3, section: 1))

    XCTAssertEqual(successActivity, self.dataSource[itemSection: (4, 1)] as? Activity)
    XCTAssertEqual("ActivityStateChangeCell", self.dataSource.reusableId(item: 4, section: 1))

    XCTAssertEqual("Padding", self.dataSource.reusableId(item: 5, section: 1))

    self.dataSource.emptyState(visible: false)

    XCTAssertEqual(2, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(6, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))

    self.dataSource.load(activities: [])

    XCTAssertEqual(2, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
  }
}
