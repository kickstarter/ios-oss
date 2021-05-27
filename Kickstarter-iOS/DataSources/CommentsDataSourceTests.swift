@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

class CommentsDataSourceTests: XCTestCase {
  let dataSource = CommentsDataSource()
  let tableView = UITableView()
  let section = CommentsDataSource.Section.comments.rawValue

  override func setUp() {
    super.setUp()
    self.dataSource.load(comments: Comment.templates, project: .template)
  }

  func testLoadedComments() {
    XCTAssertEqual(5, self.dataSource.numberOfItems(in: self.section))
    XCTAssertEqual(self.section + 1, self.dataSource.numberOfSections(in: self.tableView))
  }

  func testComment_shouldContainCommentCell() {
    let rowIndex: Int = 0
    XCTAssertEqual(Comment.Status.success, Comment.templates[rowIndex].status)
    XCTAssertEqual("CommentCell", self.dataSource.reusableId(item: 0, section: self.section))
  }

  func testComment_shouldContainRemovedCell() {
    let rowIndex: Int = 1
    XCTAssertEqual(Comment.Status.removed, Comment.templates[rowIndex].status)
    XCTAssertEqual("CommentRemovedCell", self.dataSource.reusableId(item: rowIndex, section: self.section))
  }

  func testComment_shouldContainFailedCell() {
    let rowIndex: Int = 4
    XCTAssertEqual(Comment.Status.failed, Comment.templates[rowIndex].status)
    XCTAssertEqual("CommentPostFailedCell", self.dataSource.reusableId(item: rowIndex, section: self.section))
  }
}
