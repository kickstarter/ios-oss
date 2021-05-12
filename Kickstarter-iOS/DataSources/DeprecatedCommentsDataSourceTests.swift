@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import XCTest

final class DeprecatedCommentsDataSourceTests: XCTestCase {
  typealias Section = DeprecatedCommentsDataSource.Section

  let dataSource = DeprecatedCommentsDataSource()
  let tableView = UITableView()

  func testLoadingComments() {
    self.dataSource.load(
      comments: [DeprecatedComment.template],
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
