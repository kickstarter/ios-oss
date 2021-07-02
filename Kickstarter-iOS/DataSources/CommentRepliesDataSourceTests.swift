@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

class CommentRepliesDataSourceTests: XCTestCase {
  let commentSection = CommentRepliesDataSource.Section.rootComment.rawValue
  let repliesSection = CommentRepliesDataSource.Section.replies.rawValue
  let dataSource = CommentRepliesDataSource()
  let tableView = UITableView()

  private let templateRepliesAndTotalCount: (
    [Comment],
    Int
  ) = ([.replyTemplate, .replyTemplate, .replyTemplate], 3)

  override func setUp() {
    super.setUp()
    self.dataSource.createContext(comment: .template)
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
    XCTAssertEqual(5, self.dataSource.numberOfSections(in: self.tableView))
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

    guard
      let (indexPath, reload) = self.dataSource
      .replace(comment: replacement, and: .template, byCommentId: replacement.id)
    else {
      XCTFail("Should return and indexPath and Bool.")
      return
    }

    XCTAssertEqual(
      self.dataSource.comment(at: IndexPath(row: 2, section: self.repliesSection)),
      replacement
    )
    XCTAssertEqual(self.dataSource.numberOfItems(in: self.repliesSection), 5)
    XCTAssertEqual(indexPath?.row, 2)
    XCTAssertEqual(reload, false)
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

    guard
      let (indexPath, reload) = self.dataSource
      .replace(comment: newComment, and: .template, byCommentId: newComment.id)
    else {
      XCTFail("Should return and indexPath and Bool.")
      return
    }

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

    guard
      let (indexPath, reload) = self.dataSource
      .replace(comment: deletedComment, and: .template, byCommentId: "2")
    else {
      XCTFail("Should return and indexPath and Bool.")
      return
    }

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

    guard
      let (indexPath, reload) = self.dataSource
      .replace(comment: failedComment, and: .template, byCommentId: "2")
    else {
      XCTFail("Should return and indexPath and Bool.")
      return
    }

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

    self.dataSource.load(repliesAndTotalCount: (nextPage, totalCount), project: .template)

    let allComments = Array(0..<(firstPage.count + nextPage.count)).compactMap { index -> Comment? in
      self.dataSource.comment(at: IndexPath(row: index, section: self.repliesSection))
    }

    XCTAssertEqual(allComments, nextPage + firstPage)
  }
}
