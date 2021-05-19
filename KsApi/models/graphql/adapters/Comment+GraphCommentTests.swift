@testable import KsApi
import XCTest

final class Comment_GraphCommentTests: XCTestCase {
  func test() {
    let comment = Comment.comment(from: .template)

    XCTAssertEqual(comment.id, "VXNlci0yMDU3OTc4MTQ2")
    XCTAssertEqual(
      comment.body,
      "I hope you guys all remembered to write in Bat Boy/Bigfoot on your ballots! Bat Boy 2020!!"
    )
    XCTAssertEqual(comment.replyCount, 4)
    XCTAssertEqual(comment.author.id, "VXNlci0xOTE1MDY0NDY3")
    XCTAssertEqual(comment.author.name, "Author McGee")
    XCTAssertEqual(comment.author.isCreator, false)
  }
}
