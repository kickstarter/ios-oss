@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

class CommentsDataSourceTests: XCTestCase {
  private let commentsSection = CommentsDataSource.Section.comments.rawValue
  private let dataSource = CommentsDataSource()
  private let emptySection = CommentsDataSource.Section.empty.rawValue
  private let errorSection = CommentsDataSource.Section.error.rawValue
  private let tableView = UITableView()

  private let templateComments = Comment.templates + [Comment.retryingTemplate, Comment.retrySuccessTemplate]

  override func setUp() {
    super.setUp()
    self.dataSource.load(comments: self.templateComments, project: .template, shouldShowErrorState: false)
  }

  override func tearDown() {
    super.tearDown()
    self.dataSource.load(comments: [], project: .template, shouldShowErrorState: false)
  }

  func testLoadedComments() {
    XCTAssertEqual(7, self.dataSource.numberOfItems(in: self.commentsSection))
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
  }

  func testComment_shouldContainCommentCell() {
    let rowIndex: Int = 0
    XCTAssertEqual(Comment.Status.success, self.templateComments[rowIndex].status)
    XCTAssertEqual("CommentCell", self.dataSource.reusableId(item: 0, section: self.commentsSection))
  }

  func testComment_shouldContainRemovedCell() {
    let rowIndex: Int = 1
    XCTAssertTrue(self.templateComments[rowIndex].isDeleted)
    XCTAssertEqual(
      "CommentRemovedCell",
      self.dataSource.reusableId(item: rowIndex, section: self.commentsSection)
    )
  }

  func testComment_shouldContainFailedCell() {
    let rowIndex: Int = 4
    XCTAssertEqual(Comment.Status.failed, self.templateComments[rowIndex].status)
    XCTAssertEqual(
      "CommentPostFailedCell",
      self.dataSource.reusableId(item: rowIndex, section: self.commentsSection)
    )
  }

  func testComment_shouldContainFailedCell_Retrying() {
    let rowIndex: Int = 5
    XCTAssertEqual(Comment.Status.retrying, self.templateComments[rowIndex].status)
    XCTAssertEqual(
      "CommentPostFailedCell",
      self.dataSource.reusableId(item: rowIndex, section: self.commentsSection)
    )
  }

  func testComment_shouldContainCommentCell_RetrySuccess() {
    let rowIndex: Int = 6
    XCTAssertEqual(Comment.Status.retrySuccess, self.templateComments[rowIndex].status)
    XCTAssertEqual(
      "CommentCell",
      self.dataSource.reusableId(item: rowIndex, section: self.commentsSection)
    )
  }

  func testCommentAtIndexPath() {
    super.setUp()

    self.dataSource.load(comments: Comment.templates, project: .template, shouldShowErrorState: false)

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 1, section: 0)),
      Comment.templates[1]
    )
  }

  func testEmptyState_WhenNoComments_HasEmptyStateCell() {
    let rowIndex: Int = 0
    self.dataSource.load(comments: [], project: .template, shouldShowErrorState: false)

    XCTAssertEqual(1, self.dataSource.numberOfItems(in: self.emptySection))
    XCTAssertEqual(
      "EmptyCommentsCell",
      self.dataSource.reusableId(item: rowIndex, section: self.emptySection)
    )
  }

  func testEmptyState_OnCommentsLoadingError_ShouldShowErrorStateCell() {
    let rowIndex: Int = 0
    self.dataSource.load(comments: [], project: .template, shouldShowErrorState: true)

    XCTAssertEqual(1, self.dataSource.numberOfItems(in: self.errorSection))
    XCTAssertEqual(
      "CommentsErrorCell",
      self.dataSource.reusableId(item: rowIndex, section: self.errorSection)
    )
    XCTAssertTrue(self.dataSource.isInErrorState(indexPath: IndexPath(row: 0, section: 2)))
  }

  func testEmptyState_OnCommentsLoadingSuccess_ShouldNotShowErrorStateCell() {
    let rowIndex: Int = 0
    self.dataSource.load(comments: [], project: .template, shouldShowErrorState: false)

    XCTAssertEqual(1, self.dataSource.numberOfItems(in: self.emptySection))
    XCTAssertEqual(
      "EmptyCommentsCell",
      self.dataSource.reusableId(item: rowIndex, section: self.emptySection)
    )
    XCTAssertFalse(self.dataSource.isInErrorState(indexPath: IndexPath(row: 0, section: 1)))
  }

  func testEmptyState_WhenNoCommentsAndThenAddedComments_DoesNotShowEmptyStateCell() {
    let rowIndex: Int = 0
    XCTAssertEqual(7, self.dataSource.numberOfItems(in: self.commentsSection))
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))

    self.dataSource.load(comments: [], project: .template, shouldShowErrorState: false)

    XCTAssertEqual(1, self.dataSource.numberOfItems(in: self.emptySection))
    XCTAssertEqual(0, self.dataSource.numberOfItems(in: self.commentsSection))
    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      "EmptyCommentsCell",
      self.dataSource.reusableId(item: rowIndex, section: self.emptySection)
    )

    self.dataSource.load(comments: [Comment.template], project: .template, shouldShowErrorState: false)

    XCTAssertEqual(1, self.dataSource.numberOfItems(in: self.commentsSection))
    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
  }
}
