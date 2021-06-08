@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

class CommentsDataSourceTests: XCTestCase {
  let dataSource = CommentsDataSource()
  let tableView = UITableView()
  let commentsSection = CommentsDataSource.Section.comments.rawValue
  let emptySection = CommentsDataSource.Section.empty.rawValue

  override func setUp() {
    super.setUp()
    self.dataSource.load(comments: Comment.templates, project: .template)
  }

  override func tearDown() {
    super.tearDown()
    self.dataSource.load(comments: [], project: .template)
  }

  func testLoadedComments() {
    XCTAssertEqual(5, self.dataSource.numberOfItems(in: self.commentsSection))
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
  }

  func testComment_shouldContainCommentCell() {
    let rowIndex: Int = 0
    XCTAssertEqual(Comment.Status.success, Comment.templates[rowIndex].status)
    XCTAssertEqual("CommentCell", self.dataSource.reusableId(item: 0, section: self.commentsSection))
  }

  func testComment_shouldContainRemovedCell() {
    let rowIndex: Int = 1
    XCTAssertTrue(Comment.templates[rowIndex].isDeleted)
    XCTAssertEqual(
      "CommentRemovedCell",
      self.dataSource.reusableId(item: rowIndex, section: self.commentsSection)
    )
  }

  func testComment_shouldContainFailedCell() {
    let rowIndex: Int = 4
    XCTAssertEqual(Comment.Status.failed, Comment.templates[rowIndex].status)
    XCTAssertEqual(
      "CommentPostFailedCell",
      self.dataSource.reusableId(item: rowIndex, section: self.commentsSection)
    )
  }

  func testCommentAtIndexPath() {
    super.setUp()

    self.dataSource.load(comments: Comment.templates, project: .template)

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 1, section: 0)),
      Comment.templates[1]
    )
  }

  func testEmptyState_WhenNoComments_ShouldShowEmptyStateCell() {
    let rowIndex: Int = 0
    self.dataSource.load(comments: [], project: .template)

    XCTAssertEqual(1, self.dataSource.numberOfItems(in: self.emptySection))
    XCTAssertEqual(
      "EmptyCommentsCell",
      self.dataSource.reusableId(item: rowIndex, section: self.emptySection)
    )
  }

  func testEmptyState_WhenNoCommentsAndThenAddedComments_ShouldNotShowEmptyStateCell() {
    let rowIndex: Int = 0
    XCTAssertEqual(5, self.dataSource.numberOfItems(in: self.commentsSection))
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))

    self.dataSource.load(comments: [], project: .template)

    XCTAssertEqual(1, self.dataSource.numberOfItems(in: self.emptySection))
    XCTAssertEqual(0, self.dataSource.numberOfItems(in: self.commentsSection))
    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      "EmptyCommentsCell",
      self.dataSource.reusableId(item: rowIndex, section: self.emptySection)
    )

    self.dataSource.load(comments: [Comment.template], project: .template)

    XCTAssertEqual(1, self.dataSource.numberOfItems(in: self.commentsSection))
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
  }
}
