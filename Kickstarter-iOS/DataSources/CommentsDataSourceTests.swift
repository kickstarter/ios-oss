@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import XCTest

final class CommentsDataSourceTests: XCTestCase {
  typealias Section = CommentsDataSource.Section

  let dataSource = CommentsDataSource()
  let tableView = UITableView()

  func testLoadingComments() {
    self.dataSource.load(
      comments: [Comment.template],
      project: Project.template,
      update: Update.template,
      loggedInUser: User.template,
      shouldShowEmptyState: false
    )

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      0, self.dataSource.tableView(
        self.tableView, numberOfRowsInSection: Section.emptyState.rawValue
      )
    )
    XCTAssertEqual(
      1, self.dataSource.tableView(
        self.tableView, numberOfRowsInSection: Section.comments.rawValue
      )
    )
  }
}
