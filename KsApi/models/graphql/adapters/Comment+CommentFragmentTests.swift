@testable import KsApi
import Prelude
import XCTest

final class Comment_CommentFragmentTests: XCTestCase {
  func test() {
    do {
      let variables = ["withStoredCards": true]
      let commentFragment = try GraphAPI.CommentFragment(
        jsonObject: CommentFragmentTemplate.valid.data,
        variables: variables
      )

      XCTAssertNotNil(commentFragment)
      XCTAssertNotNil(commentFragment.author)
      XCTAssertEqual(commentFragment.authorBadges, [.collaborator])
      XCTAssertEqual(commentFragment.body, "new post")
      XCTAssertEqual(commentFragment.id, "Q29tbWVudC0zMjY2NDEwNQ==")
      XCTAssertNil(commentFragment.parentId)
      XCTAssertEqual(commentFragment.replies?.totalCount, 3)

    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}
