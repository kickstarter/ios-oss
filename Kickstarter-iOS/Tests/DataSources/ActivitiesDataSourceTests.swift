import XCTest
@testable import Kickstarter_iOS
@testable import Library
@testable import KsApi_TestHelpers
@testable import KsApi
import Prelude

final class ActivitiesDataSourceTests: XCTestCase {
  let dataSource = ActivitiesDataSource()
  let tableView = UITableView()

  func testDataSource() {
    let updateActivity = Activity.template |> Activity.lens.category .~ .update
    let backingActivity = Activity.template |> Activity.lens.category .~ .backing
    let successActivity = Activity.template |> Activity.lens.category .~ .success

    self.dataSource.emptyState(visible: true)

    XCTAssertEqual(1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual("ActivityEmptyStateCell", self.dataSource.reusableId(item: 0, section: 0))

    self.dataSource.emptyState(visible: false)
    self.dataSource.facebookConnect(source: FriendsSource.activity, visible: true)

    XCTAssertEqual(2, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual("FindFriendsFacebookConnectCell", self.dataSource.reusableId(item: 0, section: 1))
    XCTAssertEqual("PaddingHalf", self.dataSource.reusableId(item: 1, section: 1))

    let indexPaths = self.dataSource.removeFacebookConnectRows()

    XCTAssertEqual(2, indexPaths.count)
    XCTAssertEqual(1, indexPaths.first?.section)
    XCTAssertEqual(2, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))

    self.dataSource.findFriends(source: FriendsSource.activity, visible: true)

    XCTAssertEqual(3, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(2, self.dataSource.tableView(tableView, numberOfRowsInSection: 2))
    XCTAssertEqual("FindFriendsHeaderCell", self.dataSource.reusableId(item: 0, section: 2))
    XCTAssertEqual("PaddingHalf", self.dataSource.reusableId(item: 1, section: 2))

    let indexPathsFriends = self.dataSource.removeFindFriendsRows()

    XCTAssertEqual(2, indexPaths.count)
    XCTAssertEqual(2, indexPathsFriends.first?.section)
    XCTAssertEqual(3, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 2))

    self.dataSource.load(activities: [updateActivity, backingActivity, successActivity])

    XCTAssertEqual(4, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(6, self.dataSource.tableView(tableView, numberOfRowsInSection: 3))

    XCTAssertEqual(updateActivity, self.dataSource[testItemSection: (0, 3)] as? Activity)
    XCTAssertEqual("ActivityUpdateCell", self.dataSource.reusableId(item: 0, section: 3))

    XCTAssertEqual("Padding", self.dataSource.reusableId(item: 1, section: 3))

    XCTAssertEqual(backingActivity, self.dataSource[testItemSection: (2, 3)] as? Activity)
    XCTAssertEqual("ActivityFriendBackingCell", self.dataSource.reusableId(item: 2, section: 3))

    XCTAssertEqual("Padding", self.dataSource.reusableId(item: 3, section: 3))

    XCTAssertEqual(successActivity, self.dataSource[testItemSection: (4, 3)] as? Activity)
    XCTAssertEqual("ActivitySuccessCell", self.dataSource.reusableId(item: 4, section: 3))

    XCTAssertEqual("Padding", self.dataSource.reusableId(item: 5, section: 3))

    self.dataSource.load(activities: [])

    XCTAssertEqual(4, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 3))

    self.dataSource.facebookConnect(source: FriendsSource.activity, visible: false)

    XCTAssertEqual(4, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 3))

    self.dataSource.findFriends(source: FriendsSource.activity, visible: false)

    XCTAssertEqual(4, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 3))
  }
}
