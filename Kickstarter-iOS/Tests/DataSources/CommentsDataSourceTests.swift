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

    // FIXME
//    XCTAssertEqual(2, self.dataSource.numberOfSections(in: tableView))
//    XCTAssertEqual(0, self.dataSource.tableView(
//      tableView, numberOfRowsInSection: Section.emptyState.rawValue)
//    )
//    XCTAssertEqual(1, self.dataSource.tableView(
//      tableView, numberOfRowsInSection: Section.comments.rawValue)
//    )
  }

  func testLoadingEmptyState() {
    // FIXME
//    self.dataSource.load(project: Project.template, update: nil)
//
//    XCTAssertEqual(1, self.dataSource.numberOfSections(in: tableView))
//    XCTAssertEqual(1, self.dataSource.tableView(
//      tableView, numberOfRowsInSection: Section.emptyState.rawValue))
  }
}
