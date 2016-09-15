import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi

final class CommentsDataSourceTests: XCTestCase {
  typealias Section = CommentsDataSource.Section

  let dataSource = CommentsDataSource()
  let tableView = UITableView()

  func testLoadingComments() {
    self.dataSource.load(comments: [Comment.template],
                         project: Project.template,
                         loggedInUser: User.template)

    XCTAssertEqual(2, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(0, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.EmptyState.rawValue))
    XCTAssertEqual(1, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.Comments.rawValue))
  }

  func testLoadingEmptyState() {
    self.dataSource.load(project: Project.template, update: nil)

    XCTAssertEqual(1, self.dataSource.numberOfSectionsInTableView(tableView))
    XCTAssertEqual(1, self.dataSource.tableView(
      tableView, numberOfRowsInSection: Section.EmptyState.rawValue))
  }
}
