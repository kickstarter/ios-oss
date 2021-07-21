@testable import KsApi
import Prelude
import XCTest

final class Comment_CommentFragmentTests: XCTestCase {
  func test() {
    do {
      let commentFragment = try GraphAPI.CommentFragment(jsonObject: commentDictionary())

      XCTAssertNotNil(commentFragment)
      XCTAssertNotNil(commentFragment.author)
      XCTAssertEqual(commentFragment.authorBadges?.count, 0)
      XCTAssertEqual(commentFragment.body, "new post")
      XCTAssertEqual(commentFragment.id, "Q29tbWVudC0zMjY2NDEwNQ==")
      XCTAssertNil(commentFragment.parentId)
      XCTAssertEqual(commentFragment.replies?.totalCount, 3)

    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}

private func commentDictionary() -> [String: Any] {
  let json = """
  {
    "__typename": "Comment",
    "author": {
      "__typename": "User",
      "chosenCurrency": "USD",
      "email": "mubarak@kickstarter.com",
      "isAppleConnected": true,
      "isEmailVerified": false,
      "isDeliverable": true,
      "hasPassword": false,
      "storedCards": {
        "__typename": "UserCreditCardTypeConnection",
        "nodes": [
          {
          "__typename": "CreditCard",
            "expirationDate": "2023-01-01",
            "id": "6",
            "lastFour": "4242",
            "type": "VISA"
          }
        ],
        "totalCount": 1
      },
      "id": "VXNlci02MTgwMDU4ODY=",
      "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
      "isCreator": null,
      "name": "Mubarak Sadoon",
      "uid": "618005886"
    },
    "authorBadges": [],
    "body": "new post",
    "createdAt": 1624917189,
    "deleted": false,
    "id": "Q29tbWVudC0zMjY2NDEwNQ==",
    "parentId": null,
    "replies": {
      "__typename": "CommentConnection",
      "totalCount": 3
    }
  }
  """

  let data = Data(json.utf8)
  return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
}
