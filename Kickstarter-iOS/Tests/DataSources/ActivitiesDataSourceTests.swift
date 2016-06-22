import XCTest
@testable import Kickstarter_iOS
@testable import Library
@testable import KsApi
import Prelude

final class ActivitiesDataSourceTests: XCTestCase {
  let dataSource = ActivitiesDataSource()
  let tableView = UITableView()

  func testSurvey() {
    let section = ActivitiesDataSource.Section.survey.rawValue

    self.dataSource.load(surveyResponse: .template)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(2, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
    XCTAssertEqual("ActivitySurveyResponseCell", self.dataSource.reusableId(item: 0, section: section))

    self.dataSource.load(surveyResponse: nil)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
  }

  func testFacebookConnect() {
    let section = ActivitiesDataSource.Section.facebookConnect.rawValue

    self.dataSource.facebookConnect(source: .activity, visible: true)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(2, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
    XCTAssertEqual("FindFriendsFacebookConnectCell", self.dataSource.reusableId(item: 0, section: section))
    XCTAssertEqual("PaddingHalf", self.dataSource.reusableId(item: 1, section: section))

    let indexPaths = self.dataSource.removeFacebookConnectRows()

    XCTAssertEqual(2, indexPaths.count)
    XCTAssertEqual(section, indexPaths.first?.section)
    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
  }

  func testFindFriends() {
    let section = ActivitiesDataSource.Section.findFriends.rawValue

    self.dataSource.findFriends(source: .activity, visible: true)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(2, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
    XCTAssertEqual("FindFriendsHeaderCell", self.dataSource.reusableId(item: 0, section: section))
    XCTAssertEqual("PaddingHalf", self.dataSource.reusableId(item: 1, section: section))

    let indexPaths = self.dataSource.removeFindFriendsRows()

    XCTAssertEqual(2, indexPaths.count)
    XCTAssertEqual(section, indexPaths.first?.section)
    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
  }

  func testActivities() {
    let section = ActivitiesDataSource.Section.activities.rawValue
    let updateActivity = Activity.template |> Activity.lens.category .~ .update
    let backingActivity = Activity.template |> Activity.lens.category .~ .backing
    let successActivity = Activity.template |> Activity.lens.category .~ .success

    self.dataSource.load(activities: [updateActivity, backingActivity, successActivity])

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(6, self.dataSource.tableView(tableView, numberOfRowsInSection: section))

    XCTAssertEqual(updateActivity, self.dataSource[testItemSection: (0, section)] as? Activity)
    XCTAssertEqual("ActivityUpdateCell", self.dataSource.reusableId(item: 0, section: section))

    XCTAssertEqual("Padding", self.dataSource.reusableId(item: 1, section: section))

    XCTAssertEqual(backingActivity, self.dataSource[testItemSection: (2, section)] as? Activity)
    XCTAssertEqual("ActivityFriendBackingCell", self.dataSource.reusableId(item: 2, section: section))

    XCTAssertEqual("Padding", self.dataSource.reusableId(item: 3, section: section))

    XCTAssertEqual(successActivity, self.dataSource[testItemSection: (4, section)] as? Activity)
    XCTAssertEqual("ActivitySuccessCell", self.dataSource.reusableId(item: 4, section: section))

    XCTAssertEqual("Padding", self.dataSource.reusableId(item: 5, section: section))
  }

  func testEmptyState() {
    let section = ActivitiesDataSource.Section.emptyState.rawValue

    self.dataSource.emptyState(visible: true)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
    XCTAssertEqual("ActivityEmptyStateCell", self.dataSource.reusableId(item: 0, section: section))

    self.dataSource.emptyState(visible: false)

    XCTAssertEqual(section + 1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
  }
}
