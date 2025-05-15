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
      XCTAssertNotNil(commentFragment.fragments.commentBaseFragment.author)
      XCTAssertEqual(commentFragment.fragments.commentBaseFragment.authorBadges, [.collaborator])
      XCTAssertEqual(commentFragment.fragments.commentBaseFragment.body, "new post")
      XCTAssertEqual(commentFragment.fragments.commentBaseFragment.id, "Q29tbWVudC0zMjY2NDEwNQ==")
      XCTAssertNil(commentFragment.fragments.commentBaseFragment.parentId)
      XCTAssertEqual(commentFragment.replies?.totalCount, 3)

    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}
