@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

class CommentRepliesDataSourceTests: XCTestCase {
  let dataSource = CommentRepliesDataSource()
  let tableView = UITableView()
  let commentSection = CommentRepliesDataSource.Section.comment.rawValue

  override func setUp() {
    super.setUp()
    self.dataSource.load(comment: .template, project: .template)
  }

  func testLoadedComments() {
    XCTAssertEqual(1, self.dataSource.numberOfItems(in: self.commentSection))
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
  }

  func testRootComment_shouldContainCommentCell() {
    let rowIndex: Int = 0
    XCTAssertEqual(Comment.Status.success, Comment.templates[rowIndex].status)
    XCTAssertEqual("CommentCell", self.dataSource.reusableId(item: 0, section: self.commentSection))
  }
}
