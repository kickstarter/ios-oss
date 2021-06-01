@testable import KsApi
import XCTest

class GraphCommentRepliesEnvelopeTests: XCTestCase {
  func testDecode() {
    let dictionary: [String: Any] = [
      "comment": [
        "author": [
          "id": "VXNlci0xNDcwOTUyNTQ1",
          "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&w=200&h=200&fit=crop&v=&auto=format&frame=1&q=92&s=e5c4e9017b28bb95181ff20d61b17f99",
          "isCreator": nil,
          "name": "Hari Singh"
        ],
        "authorBadges": [],
        "body": "iOS Test",
        "createdAt": 1_621_004_843,
        "deleted": false,
        "id": "Q29tbWVudC0zMjY2MjUzOQ==",
        "replies": [
          "edges": [
            [
              "node": [
                "author": [
                  "id": "VXNlci0xNDcwOTUyNTQ1",
                  "imageUrl": "https://image.com",
                  "isCreator": true,
                  "name": "Hari Singh"
                ],
                "authorBadges": [],
                "body": "iOS Test",
                "createdAt": 1_621_005_066,
                "deleted": false,
                "id": "Q29tbWVudC0zMjY2MjU0MA==",
                "parentId": "Q29tbWVudC0zMjY2ZjU0MA=="
              ]
            ],
            [
              "node": [
                "author": [
                  "id": "VXNlci0xNDcwOTUyNTQ1",
                  "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&w=200&h=200&fit=crop&v=&auto=format&frame=1&q=92&s=e5c4e9017b28bb95181ff20d61b17f99",
                  "isCreator": nil,
                  "name": "Hari Singh"
                ],
                "authorBadges": [],
                "body": "another iOS test",
                "createdAt": 1_621_005_184,
                "deleted": false,
                "id": "Q29tbWVudC0zMjY2MjU0MQ=="
              ]
            ],
            [
              "node": [
                "author": [
                  "id": "VXNlci0xNDcwOTUyNTQ1",
                  "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&w=200&h=200&fit=crop&v=&auto=format&frame=1&q=92&s=e5c4e9017b28bb95181ff20d61b17f99",
                  "isCreator": nil,
                  "name": "Hari Singh"
                ],
                "authorBadges": [],
                "body": "iOS Test",
                "createdAt": 1_621_005_265,
                "deleted": false,
                "id": "Q29tbWVudC0zMjY2MjU0Mg=="
              ]
            ],
            [
              "node": [
                "author": [
                  "id": "VXNlci0xNDcwOTUyNTQ1",
                  "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&w=200&h=200&fit=crop&v=&auto=format&frame=1&q=92&s=e5c4e9017b28bb95181ff20d61b17f99",
                  "isCreator": nil,
                  "name": "Hari Singh"
                ],
                "authorBadges": [],
                "body": "iOS Test",
                "createdAt": 1_621_005_410,
                "deleted": false,
                "id": "Q29tbWVudC0zMjY2MjU0Mw=="
              ]
            ],
            [
              "node": [
                "author": [
                  "id": "VXNlci0xNDcwOTUyNTQ1",
                  "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&w=200&h=200&fit=crop&v=&auto=format&frame=1&q=92&s=e5c4e9017b28bb95181ff20d61b17f99",
                  "isCreator": nil,
                  "name": "Hari Singh"
                ],
                "authorBadges": [],
                "body": "Hello World",
                "createdAt": 1_621_005_773,
                "deleted": false,
                "id": "Q29tbWVudC0zMjY2MjU0NA=="
              ]
            ],
            [
              "node": [
                "author": [
                  "id": "VXNlci0xNDcwOTUyNTQ1",
                  "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&w=200&h=200&fit=crop&v=&auto=format&frame=1&q=92&s=e5c4e9017b28bb95181ff20d61b17f99",
                  "isCreator": nil,
                  "name": "Hari Singh"
                ],
                "authorBadges": [],
                "body": "another iOS test",
                "createdAt": 1_621_024_061,
                "deleted": false,
                "id": "Q29tbWVudC0zMjY2MjU0NQ=="
              ]
            ]
          ],
          "pageInfo": [
            "hasPreviousPage": true,
            "startCursor": "MQ=="
          ],
          "totalCount": 6
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    do {
      let envelope = try JSONDecoder().decode(GraphCommentRepliesEnvelope.self, from: data)

      XCTAssertEqual(envelope.replies[0].id, "Q29tbWVudC0zMjY2MjU0MA==")
      XCTAssertEqual(envelope.replies[0].parentId, "Q29tbWVudC0zMjY2ZjU0MA==")
      XCTAssertEqual(envelope.replies[0].body, "iOS Test")
      XCTAssertEqual(envelope.replies[0].author.id, decompose(id: "VXNlci0xNDcwOTUyNTQ1")?.description)
      XCTAssertTrue(envelope.replies[0].author.isCreator)
      XCTAssertEqual(envelope.replies[0].author.name, "Hari Singh")
      XCTAssertEqual(envelope.replies[0].author.imageUrl, "https://image.com")
      XCTAssertEqual(envelope.replies[0].replyCount, 0)
      XCTAssertEqual(envelope.replies[0].createdAt, 1_621_005_066)
      XCTAssertFalse(envelope.replies[0].deleted)
      XCTAssertEqual(envelope.replies.count, 6)

      XCTAssertEqual(envelope.hasPreviousPage, true)
      XCTAssertEqual(envelope.cursor, "MQ==")
      XCTAssertEqual(envelope.totalCount, 6)

      XCTAssertEqual(envelope.comment.id, "Q29tbWVudC0zMjY2MjUzOQ==")
    } catch {
      XCTFail()
      print(error)
    }
  }
}
