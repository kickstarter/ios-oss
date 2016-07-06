import XCTest
@testable import Library
@testable import Kickstarter_Framework
@testable import KsApi
import Prelude

final class FindFriendsDataSourceTests: XCTestCase {
  let dataSource = FindFriendsDataSource()
  let tableView = UITableView()

  func testDataSource() {
    self.dataSource.facebookConnect(source: FriendsSource.discovery, visible: true)

    XCTAssertEqual(1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual("FindFriendsFacebookConnectCell", self.dataSource.reusableId(item: 0, section: 0))

    let stats = FriendStatsEnvelope.template
    self.dataSource.facebookConnect(source: FriendsSource.discovery, visible: false)
    self.dataSource.stats(stats: stats, source: FriendsSource.discovery)

    XCTAssertEqual(2, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual("FindFriendsStatsCell", self.dataSource.reusableId(item: 0, section: 1))

    let friends = [User.template, User.template, User.template]
    self.dataSource.friends(friends, source: FriendsSource.discovery)

    XCTAssertEqual(3, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual("FindFriendsFriendFollowCell", self.dataSource.reusableId(item: 0, section: 2))
    XCTAssertEqual("FindFriendsFriendFollowCell", self.dataSource.reusableId(item: 1, section: 2))
    XCTAssertEqual("FindFriendsFriendFollowCell", self.dataSource.reusableId(item: 2, section: 2))
  }
}
