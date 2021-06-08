@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

class CommentRepliesDataSourceTests: XCTestCase {
  let commentSection = CommentRepliesDataSource.Section.comment.rawValue
  let dataSource = CommentRepliesDataSource()
  let tableView = UITableView()

  override func setUp() {
    super.setUp()
    self.dataSource.load(comment: .template)
  }

  func testDataSource_WithComment_HasLoadedRootComment() {
    XCTAssertEqual(1, self.dataSource.numberOfItems(in: self.commentSection))
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
  }
  
  func testDataSource_WithComment_HasRootCommentCell() {
    let rowIndex: Int = 0
    XCTAssertEqual(Comment.Status.success, Comment.templates[rowIndex].status)
    XCTAssertEqual("RootCommentCell", self.dataSource.reusableId(item: 0, section: self.commentSection))
  }
}
