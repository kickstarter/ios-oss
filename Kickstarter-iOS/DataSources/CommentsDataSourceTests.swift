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

  func testComment() {
    XCTAssertEqual(self.section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(12, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.section))
    XCTAssertEqual("CommentCell", self.dataSource.reusableId(item: 1, section: self.section))
  }

  func testCommentRemoved() {
    XCTAssertEqual(self.section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(12, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.section))
    XCTAssertEqual("CommentRemovedCell", self.dataSource.reusableId(item: 0, section: self.section))
  }

  func testCommentFailed() {
    XCTAssertEqual(self.section + 1, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(12, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.section))
    XCTAssertEqual("CommentPostFailedCell", self.dataSource.reusableId(item: 11, section: self.section))
  }
}
