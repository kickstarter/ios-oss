@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

class CommentRepliesDataSourceTests: XCTestCase {
  let commentSection = CommentRepliesDataSource.Section.comment.rawValue
  let dataSource = CommentRepliesDataSource()
  let tableView = UITableView()
  let rootCommentIndex: Int = 0

  override func setUp() {
    super.setUp()
    self.dataSource.load(comment: .template, project: .template)
  }

  func testDataSource_WithComments_HasLoadedComments() {
    XCTAssertEqual(1, self.dataSource.numberOfItems(in: self.commentSection))
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
  }

  func testRootComment_WithReUseID_ShouldBeCommentCellType() {
    XCTAssertEqual(
      "CommentCell",
      self.dataSource.reusableId(item: self.rootCommentIndex, section: self.commentSection)
    )
  }

  func testRootCommentAndProject_WithCommentAndProject_ShouldContainCommentAndProjectData() {
    let commentAndProjectInDataSource = self
      .dataSource[itemSection: (self.rootCommentIndex, self.commentSection)] as! (Comment, Project)

    XCTAssertEqual(commentAndProjectInDataSource.0, Comment.template)
    XCTAssertEqual(commentAndProjectInDataSource.1, Project.template)
  }
}
