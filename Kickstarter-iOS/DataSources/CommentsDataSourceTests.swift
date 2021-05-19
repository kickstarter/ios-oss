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
    self.dataSource.load()
  }

  func testComment_shouldContainCommentCell() {
    XCTAssertEqual(self.section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual("CommentCell", self.dataSource.reusableId(item: 1, section: self.section))
  }

  func testComment_shouldContainRemovedCell() {
    XCTAssertEqual(self.section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual("CommentRemovedCell", self.dataSource.reusableId(item: 0, section: self.section))
  }

  func testComment_shouldContainFailedCell() {
    XCTAssertEqual(self.section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual("CommentPostFailedCell", self.dataSource.reusableId(item: 11, section: self.section))
  }
}
