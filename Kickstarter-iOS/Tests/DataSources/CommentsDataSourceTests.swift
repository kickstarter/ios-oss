import XCTest
@testable import Kickstarter_iOS
@testable import Library
@testable import KsApi_TestHelpers
@testable import KsApi

final class CommentsDataSourceTests: XCTestCase {
  typealias Section = CommentsDataSource.Section

  let dataSource = CommentsDataSource()
  let tableView = UITableView()

  func testLoadingComments() {
    self.dataSource.load(comments: [Comment.template],
                         project: Project.template,
                         loggedInUser: User.template)

    XCTAssertEqual(4, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.BackerEmptyState.rawValue))
    XCTAssertEqual(0, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.NonBackerEmptyState.rawValue))
    XCTAssertEqual(0, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.LoggedOutEmptyState.rawValue))
    XCTAssertEqual(1, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.Comments.rawValue))
  }

  func testLoadingEmptyStates() {
    self.dataSource.backerEmptyState(visible: true)

    XCTAssertEqual(1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(1, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.BackerEmptyState.rawValue))

    self.dataSource.nonBackerEmptyState(visible: true)
    self.dataSource.backerEmptyState(visible: false)

    XCTAssertEqual(2, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.BackerEmptyState.rawValue))
    XCTAssertEqual(1, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.NonBackerEmptyState.rawValue))

    self.dataSource.loggedOutEmptyState(visible: true)
    self.dataSource.nonBackerEmptyState(visible: false)

    XCTAssertEqual(3, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.BackerEmptyState.rawValue))
    XCTAssertEqual(0, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.NonBackerEmptyState.rawValue))
    XCTAssertEqual(1, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.LoggedOutEmptyState.rawValue))
  }
}
