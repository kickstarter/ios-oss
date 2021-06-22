@testable import KsApi
import XCTest

final class GraphCommentsEnvelopeTests: XCTestCase {
  func testProjectCommentsDecode() {
    let dictionary: [String: Any] = [
      "project": [
        "comments": [
          "edges": [
            [
              "node": [
                "author": [
                  "id": "VXNlci0xOTE1MDY0NDY3",
                  "isCreator": true,
                  "name": "Billy Bob",
                  "imageUrl": "https://image.com"
                ],
                "authorBadges": [],
                "body": "I have not received a survey yet either.",
                "id": "Q29tbWVudC0zMDQ5MDQ2NA==",
                "createdAt": 1_622_267_124,
                "deleted": true,
                "replies": [
                  "totalCount": 1
                ]
              ]
            ],
            [
              "node": [
                "author": [
                  "id": "VXNlci0yMDU3OTc4MTQ2",
                  "isCreator": nil,
                  "name": "Kate Hudson",
                  "imageUrl": "https://image.com"
                ],
                "authorBadges": ["backer"],
                "body": "I hope you guys all remembered to write in Bat Boy/Bigfoot on your ballots! Bat Boy 2020!!",
                "id": "Q29tbWVudC0zMDQ2ODc1MA==",
                "createdAt": 1_522_067_124,
                "deleted": false,
                "replies": [
                  "totalCount": 1
                ]
              ]
            ],
            [
              "node": [
                "author": [
                  "id": "VXNlci0yMTA1MDg2MzA4",
                  "isCreator": false,
                  "name": "Joe Smith",
                  "imageUrl": "https://image.com"
                ],
                "authorBadges": ["superbacker"],
                "body": "I haven't received my survey yet. Should I have?",
                "id": "Q29tbWVudC0zMDQ1ODg5MQ==",
                "createdAt": 1_622_067_114,
                "deleted": false,
                "replies": [
                  "totalCount": 1
                ]
              ]
            ]
          ],
          "pageInfo": [
            "startCursor": "WzMwNDkwNDY0XQ==",
            "endCursor": "WzMwNDU4ODkxXQ==",
            "hasNextPage": true
          ],
          "totalCount": 61
        ],
        "slug": "jadelabo-j1-beautiful-powerful-and-smart-idex-3d-printer"
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    do {
      let envelope = try JSONDecoder().decode(GraphCommentsEnvelope.self, from: data)

      XCTAssertEqual(envelope.comments.first?.id, "Q29tbWVudC0zMDQ5MDQ2NA==")
      XCTAssertEqual(envelope.comments.first?.body, "I have not received a survey yet either.")
      XCTAssertEqual(envelope.comments.first?.author.id, decompose(id: "VXNlci0xOTE1MDY0NDY3")?.description)
      XCTAssertEqual(envelope.comments.first?.author.isCreator, true)
      XCTAssertEqual(envelope.comments.first?.author.name, "Billy Bob")
      XCTAssertEqual(envelope.comments.first?.author.imageUrl, "https://image.com")
      XCTAssertEqual(envelope.comments.first?.replyCount, 1)
      XCTAssertEqual(envelope.comments.first?.createdAt, 1_622_267_124)
      XCTAssertEqual(envelope.comments.first?.deleted, true)
      XCTAssertEqual(envelope.comments.count, 3)

      XCTAssertNil(envelope.updateID)
      XCTAssertEqual(envelope.hasNextPage, true)
      XCTAssertEqual(envelope.cursor, "WzMwNDU4ODkxXQ==")
      XCTAssertEqual(envelope.totalCount, 61)

      XCTAssertEqual(envelope.slug, "jadelabo-j1-beautiful-powerful-and-smart-idex-3d-printer")
    } catch {
      XCTFail()
    }
  }

  func testProjectUpdateCommentsDecode() {
    let dictionary: [String: Any] = [
      "post": [
        "id": "WzMwNDU4ODkxXQ==",
        "comments": [
          "edges": [
            [
              "node": [
                "author": [
                  "id": "VXNlci0xOTE1MDY0NDY3",
                  "isCreator": true,
                  "name": "Billy Bob",
                  "imageUrl": "https://image.com"
                ],
                "authorBadges": [],
                "body": "I have not received a survey yet either.",
                "id": "Q29tbWVudC0zMDQ5MDQ2NA==",
                "createdAt": 1_622_267_124,
                "deleted": true,
                "replies": [
                  "totalCount": 1
                ]
              ]
            ],
            [
              "node": [
                "author": [
                  "id": "VXNlci0yMDU3OTc4MTQ2",
                  "isCreator": nil,
                  "name": "Kate Hudson",
                  "imageUrl": "https://image.com"
                ],
                "authorBadges": ["backer"],
                "body": "I hope you guys all remembered to write in Bat Boy/Bigfoot on your ballots! Bat Boy 2020!!",
                "id": "Q29tbWVudC0zMDQ2ODc1MA==",
                "createdAt": 1_522_067_124,
                "deleted": false,
                "replies": [
                  "totalCount": 1
                ]
              ]
            ],
            [
              "node": [
                "author": [
                  "id": "VXNlci0yMTA1MDg2MzA4",
                  "isCreator": false,
                  "name": "Joe Smith",
                  "imageUrl": "https://image.com"
                ],
                "authorBadges": ["superbacker"],
                "body": "I haven't received my survey yet. Should I have?",
                "id": "Q29tbWVudC0zMDQ1ODg5MQ==",
                "createdAt": 1_622_067_114,
                "deleted": false,
                "replies": [
                  "totalCount": 1
                ]
              ]
            ]
          ],
          "pageInfo": [
            "startCursor": "WzMwNDkwNDY0XQ==",
            "endCursor": "WzMwNDU4ODkxXQ==",
            "hasNextPage": true
          ],
          "totalCount": 61
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    do {
      let envelope = try JSONDecoder().decode(GraphCommentsEnvelope.self, from: data)

      XCTAssertEqual(envelope.comments.first?.id, "Q29tbWVudC0zMDQ5MDQ2NA==")
      XCTAssertEqual(envelope.comments.first?.body, "I have not received a survey yet either.")
      XCTAssertEqual(envelope.comments.first?.author.id, decompose(id: "VXNlci0xOTE1MDY0NDY3")?.description)
      XCTAssertEqual(envelope.comments.first?.author.isCreator, true)
      XCTAssertEqual(envelope.comments.first?.author.name, "Billy Bob")
      XCTAssertEqual(envelope.comments.first?.author.imageUrl, "https://image.com")
      XCTAssertEqual(envelope.comments.first?.replyCount, 1)
      XCTAssertEqual(envelope.comments.first?.createdAt, 1_622_267_124)
      XCTAssertEqual(envelope.comments.first?.deleted, true)
      XCTAssertEqual(envelope.comments.count, 3)

      XCTAssertEqual(envelope.updateID, "WzMwNDU4ODkxXQ==")
      XCTAssertEqual(envelope.hasNextPage, true)
      XCTAssertEqual(envelope.cursor, "WzMwNDU4ODkxXQ==")
      XCTAssertEqual(envelope.totalCount, 61)

      XCTAssertNil(envelope.slug)
    } catch {
      XCTFail()
      print(error)
    }
  }

  func testProjectOrUpdateCommentsDecode() {
    let dictionary: [String: Any] = [:]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    do {
      _ = try JSONDecoder().decode(GraphCommentsEnvelope.self, from: data)
      XCTFail("Should not be decodable")
    } catch let DecodingError.dataCorrupted(context) {
      XCTAssertEqual("Unable to decode a Project or Update.", "\(context.debugDescription)")
    } catch {
      XCTFail("Should only fail with DecodingError.dataCorrupted")
    }
  }
}
