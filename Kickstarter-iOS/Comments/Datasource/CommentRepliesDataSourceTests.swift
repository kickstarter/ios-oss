@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

class CommentRepliesDataSourceTests: XCTestCase {
  let commentSection = CommentRepliesDataSource.Section.rootComment.rawValue
  let repliesSection = CommentRepliesDataSource.Section.replies.rawValue
  let viewMoreRepliesSection = CommentRepliesDataSource.Section.viewMoreReplies.rawValue
  let viewMoreRepliesErrorSection = CommentRepliesDataSource.Section.viewMoreRepliesError.rawValue
  let dataSource = CommentRepliesDataSource()
  let tableView = UITableView()

  private let replyCellIndexPath = IndexPath(row: 0, section: 3)
  private let viewMoreRepliesCellIndexPath = IndexPath(row: 0, section: 1)
  private let viewMoreRepliesErrorCellIndexPath = IndexPath(row: 0, section: 2)

  private let templateRepliesAndTotalCount: (
    [Comment],
    Int
  ) = ([.replyTemplate, .replyTemplate, .replyTemplate], 3)

  override func setUp() {
    super.setUp()
    self.dataSource.loadRootComment(.template)
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

  func testDataSource_WithReplies_HasRepliesSection() {
    self.dataSource.load(repliesAndTotalCount: self.templateRepliesAndTotalCount, project: .template)
    XCTAssertEqual(3, self.dataSource.numberOfItems(in: self.repliesSection))
    XCTAssertEqual(6, self.dataSource.numberOfSections(in: self.tableView))
  }

  func testDataSource_WithReplies_HasCommentCell() {
    self.dataSource.load(repliesAndTotalCount: self.templateRepliesAndTotalCount, project: .template)
    XCTAssertEqual("CommentCell", self.dataSource.reusableId(item: 0, section: self.repliesSection))
  }

  func testCommentAtIndexPath() {
    self.dataSource.load(repliesAndTotalCount: self.templateRepliesAndTotalCount, project: .template)

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 0, section: self.repliesSection)),
      .replyTemplate
    )
  }

  func testIndexForReplyId_ReplyIdExists() {
    let commentsAndReplyCount = ([
      Comment.replyTemplate |> \.id .~ "1",
      Comment.replyTemplate |> \.id .~ "2",
      Comment.replyTemplate |> \.id .~ "3"
    ], 3)
    self.dataSource.load(repliesAndTotalCount: commentsAndReplyCount, project: .template)

    XCTAssertEqual(self.dataSource.index(for: "1"), IndexPath(row: 0, section: self.repliesSection))
    XCTAssertEqual(self.dataSource.index(for: "2"), IndexPath(row: 1, section: self.repliesSection))
    XCTAssertEqual(self.dataSource.index(for: "3"), IndexPath(row: 2, section: self.repliesSection))
  }

  func testIndexForReplyId_ReplyIdDoesNotExist() {
    let commentsAndReplyCount = ([
      Comment.replyTemplate |> \.id .~ "1",
      Comment.replyTemplate |> \.id .~ "2",
      Comment.replyTemplate |> \.id .~ "3"
    ], 3)
    self.dataSource.load(repliesAndTotalCount: commentsAndReplyCount, project: .template)

    XCTAssertNil(self.dataSource.index(for: "99"))
  }

  func testIsRepliesSectionEmpty_False() {
    self.dataSource.load(repliesAndTotalCount: self.templateRepliesAndTotalCount, project: .template)

    XCTAssertFalse(self.dataSource.isRepliesSectionEmpty(in: self.tableView))
  }

  func testIsRepliesSectionEmpty_True() {
    self.dataSource.load(repliesAndTotalCount: ([], 7), project: .template)

    XCTAssertTrue(self.dataSource.isRepliesSectionEmpty(in: self.tableView))
  }

  func testReplace_ExistingComment() {
    let commentToReplace = Comment.replyTemplate
      |> \.id .~ "3"
      |> \.body .~ "Old Body"

    let comments = [
      Comment.replyTemplate |> \.id .~ "1",
      Comment.replyTemplate |> \.id .~ "2",
      commentToReplace,
      Comment.replyTemplate |> \.id .~ "4",
      Comment.replyTemplate |> \.id .~ "5"
    ]

    let totalCount = 5

    self.dataSource.load(repliesAndTotalCount: (comments, totalCount), project: .template)

    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 5)

    let replacement = Comment.replyTemplate
      |> \.id .~ "3"
      |> \.body .~ "New Body"

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 2, section: self.repliesSection)),
      commentToReplace
    )

    let (indexPath, reload) = self.dataSource
      .replace(comment: replacement, and: .template, byCommentId: replacement.id)

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 2, section: self.repliesSection)),
      replacement
    )
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 5)
    XCTAssertEqual(indexPath?.row, 2)
    XCTAssertEqual(reload, false)
  }

  func testReplace_NonExistingComment_HasAppendedComment() {
    let commentToReplace = Comment.replyTemplate
      |> \.id .~ "3"
      |> \.body .~ "Old Body"

    let comments = [
      Comment.replyTemplate |> \.id .~ "1",
      Comment.replyTemplate |> \.id .~ "2",
      Comment.replyTemplate |> \.id .~ "4",
      Comment.replyTemplate |> \.id .~ "5"
    ]

    let totalCount = 4

    self.dataSource.load(repliesAndTotalCount: (comments, totalCount), project: .template)

    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 4)

    let replacement = Comment.replyTemplate
      |> \.id .~ "3"
      |> \.body .~ "New Body"

    XCTAssertNotEqual(
      self.dataSource.comment(at: IndexPath(row: 2, section: self.repliesSection)),
      commentToReplace
    )

    let (indexPath, reload) = self.dataSource
      .replace(comment: replacement, and: .template, byCommentId: replacement.id)

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 4, section: self.repliesSection)),
      replacement
    )
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 5)
    XCTAssertEqual(indexPath?.row, 4)
    XCTAssertEqual(reload, true)
  }

  func testReplace_NewComment() {
    let comments = [
      Comment.replyTemplate |> \.id .~ "1",
      Comment.replyTemplate |> \.id .~ "2",
      Comment.replyTemplate |> \.id .~ "3",
      Comment.replyTemplate |> \.id .~ "4",
      Comment.replyTemplate |> \.id .~ "5"
    ]

    let totalCount = 5

    self.dataSource.load(repliesAndTotalCount: (comments, totalCount), project: .template)

    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 5)

    let newComment = Comment.replyTemplate
      |> \.id .~ "123"
      |> \.body .~ "New Body"

    let (indexPath, reload) = self.dataSource
      .replace(comment: newComment, and: .template, byCommentId: newComment.id)

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 5, section: self.repliesSection)),
      newComment
    )
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 6)
    XCTAssertEqual(indexPath?.row, 5)
    XCTAssertEqual(reload, true)
  }

  func testReplace_DeletedComment() {
    let comments = [
      Comment.replyTemplate |> \.id .~ "1",
      Comment.replyTemplate |> \.id .~ "2",
      Comment.replyTemplate |> \.id .~ "3",
      Comment.replyTemplate |> \.id .~ "4",
      Comment.replyTemplate |> \.id .~ "5"
    ]

    let totalCount = 5

    self.dataSource.load(repliesAndTotalCount: (comments, totalCount), project: .template)

    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 5)

    let deletedComment = Comment.deletedTemplate
      |> \.id .~ "123"

    let (indexPath, reload) = self.dataSource
      .replace(comment: deletedComment, and: .template, byCommentId: "2")

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 1, section: self.repliesSection)),
      deletedComment
    )
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 5)
    XCTAssertEqual(indexPath?.row, 1)
    XCTAssertEqual(reload, false)
  }

  func testReplace_FailedComment() {
    let comments = [
      Comment.replyTemplate |> \.id .~ "1",
      Comment.replyTemplate |> \.id .~ "2",
      Comment.replyTemplate |> \.id .~ "3",
      Comment.replyTemplate |> \.id .~ "4",
      Comment.replyTemplate |> \.id .~ "5"
    ]

    let totalCount = 5

    self.dataSource.load(repliesAndTotalCount: (comments, totalCount), project: .template)

    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 5)

    let failedComment = Comment.failedTemplate
      |> \.id .~ "123"

    let (indexPath, reload) = self.dataSource
      .replace(comment: failedComment, and: .template, byCommentId: "2")

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 1, section: self.repliesSection)),
      failedComment
    )
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 5)
    XCTAssertEqual(indexPath?.row, 1)
    XCTAssertEqual(reload, false)
  }

  func testLoadComments_DeletedComment() {
    let deletedComment = Comment.deletedTemplate |> \.id .~ "3"
    let comments = [
      Comment.replyTemplate |> \.id .~ "1",
      Comment.replyTemplate |> \.id .~ "2",
      deletedComment,
      Comment.replyTemplate |> \.id .~ "4",
      Comment.replyTemplate |> \.id .~ "5"
    ]

    let totalCount = 5

    self.dataSource.load(repliesAndTotalCount: (comments, totalCount), project: .template)

    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 5)

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 0, section: self.repliesSection)),
      deletedComment
    )
  }

  func testLoadComments_FailedComment() {
    let failedComment = Comment.failedTemplate |> \.id .~ "3"
    let comments = [
      Comment.replyTemplate |> \.id .~ "1",
      Comment.replyTemplate |> \.id .~ "2",
      failedComment,
      Comment.replyTemplate |> \.id .~ "4",
      Comment.replyTemplate |> \.id .~ "5"
    ]

    let totalCount = 5

    self.dataSource.load(repliesAndTotalCount: (comments, totalCount), project: .template)

    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 5)

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 0, section: self.repliesSection)),
      failedComment
    )
  }

  func testLoadComments_Pagination_Prepends() {
    let firstPage = [
      Comment.replyTemplate |> \.id .~ "1",
      Comment.replyTemplate |> \.id .~ "2",
      Comment.replyTemplate |> \.id .~ "3",
      Comment.replyTemplate |> \.id .~ "4",
      Comment.replyTemplate |> \.id .~ "5"
    ]

    let nextPage = [
      Comment.replyTemplate |> \.id .~ "6",
      Comment.replyTemplate |> \.id .~ "7",
      Comment.replyTemplate |> \.id .~ "8",
      Comment.replyTemplate |> \.id .~ "9",
      Comment.replyTemplate |> \.id .~ "10"
    ]

    let totalCount = 10

    self.dataSource.load(repliesAndTotalCount: (firstPage, totalCount), project: .template)

    let firstPageComments = Array(0..<firstPage.count).compactMap { index -> Comment? in
      self.dataSource.comment(at: IndexPath(row: index, section: self.repliesSection))
    }

    XCTAssertEqual(firstPageComments, firstPage)
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.viewMoreRepliesSection), 1)

    self.dataSource.load(repliesAndTotalCount: (nextPage, totalCount), project: .template)

    let allComments = Array(0..<(firstPage.count + nextPage.count)).compactMap { index -> Comment? in
      self.dataSource.comment(at: IndexPath(row: index, section: self.repliesSection))
    }

    XCTAssertEqual(allComments, nextPage + firstPage)
  }

  func testLoadComments_Pagination_FailureThenSuccessful() {
    let firstPage = [
      Comment.replyTemplate |> \.id .~ "1",
      Comment.replyTemplate |> \.id .~ "2",
      Comment.replyTemplate |> \.id .~ "3",
      Comment.replyTemplate |> \.id .~ "4",
      Comment.replyTemplate |> \.id .~ "5",
      Comment.replyTemplate |> \.id .~ "6",
      Comment.replyTemplate |> \.id .~ "7"
    ]

    let nextPage = [
      Comment.replyTemplate |> \.id .~ "8",
      Comment.replyTemplate |> \.id .~ "9",
      Comment.replyTemplate |> \.id .~ "10",
      Comment.replyTemplate |> \.id .~ "11",
      Comment.replyTemplate |> \.id .~ "12",
      Comment.replyTemplate |> \.id .~ "13",
      Comment.replyTemplate |> \.id .~ "14"
    ]

    let totalCount = 21

    XCTAssertTrue(self.dataSource.isRepliesSectionEmpty(in: self.tableView))

    self.dataSource.load(repliesAndTotalCount: (firstPage, totalCount), project: .template)

    XCTAssertEqual(
      self.dataSource
        .numberOfItems(in: self.viewMoreRepliesErrorSection),
      0
    )
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.viewMoreRepliesSection), 1)
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 7)

    self.dataSource.showPaginationErrorState()

    XCTAssertEqual(
      self.dataSource
        .numberOfItems(in: self.viewMoreRepliesErrorSection),
      1
    )
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.viewMoreRepliesSection), 0)
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 7)

    self.dataSource.load(repliesAndTotalCount: (nextPage, totalCount), project: .template)

    XCTAssertEqual(
      self.dataSource
        .numberOfItems(in: self.viewMoreRepliesErrorSection),
      0
    )
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.viewMoreRepliesSection), 1)
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 14)
  }

  func testCell_InSection_ViewMoreRepliesOrErroredPagination() {
    XCTAssertTrue(self.dataSource.sectionForViewMoreReplies(self.viewMoreRepliesCellIndexPath))
    XCTAssertTrue(self.dataSource.sectionForViewMoreReplies(self.viewMoreRepliesErrorCellIndexPath))
    XCTAssertFalse(self.dataSource.sectionForViewMoreReplies(self.replyCellIndexPath))
  }

  func testCell_InSection_Replies() {
    XCTAssertFalse(self.dataSource.sectionForReplies(self.viewMoreRepliesCellIndexPath))
    XCTAssertFalse(self.dataSource.sectionForReplies(self.viewMoreRepliesErrorCellIndexPath))
    XCTAssertTrue(self.dataSource.sectionForReplies(self.replyCellIndexPath))
  }
}
