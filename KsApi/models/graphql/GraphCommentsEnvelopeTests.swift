@testable import KsApi
import XCTest

final class GraphCommentsEnvelopeTests: XCTestCase {
  func testDecode() {
    let dictionary: [String: Any] = [
      "project": [
        "comments": [
          "edges": [
            [
              "node": [
                "author": [
                  "id": "VXNlci0xOTE1MDY0NDY3",
                  "isCreator": true,
                  "name": "Billy Bob"
                ],
                "body": "I have not received a survey yet either.",
                "id": "Q29tbWVudC0zMDQ5MDQ2NA==",
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
                  "name": "Kate Hudson"
                ],
                "body": "I hope you guys all remembered to write in Bat Boy/Bigfoot on your ballots! Bat Boy 2020!!",
                "id": "Q29tbWVudC0zMDQ2ODc1MA==",
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
                  "name": "Joe Smith"
                ],
                "body": "I haven't received my survey yet. Should I have?",
                "id": "Q29tbWVudC0zMDQ1ODg5MQ==",
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
      XCTAssertEqual(envelope.comments[0].id, "Q29tbWVudC0zMDQ5MDQ2NA==")
      XCTAssertEqual(envelope.comments[0].body, "I have not received a survey yet either.")
      XCTAssertEqual(envelope.comments[0].author.id, "VXNlci0xOTE1MDY0NDY3")
      XCTAssertEqual(envelope.comments[0].author.isCreator, true)
      XCTAssertEqual(envelope.comments[0].author.name, "Billy Bob")
      XCTAssertEqual(envelope.comments[0].replyCount, 1)

      XCTAssertEqual(envelope.comments.count, 3)

      XCTAssertEqual(envelope.hasNextPage, true)
      XCTAssertEqual(envelope.cursor, "WzMwNDU4ODkxXQ==")
      XCTAssertEqual(envelope.totalCount, 61)
    } catch {
      XCTFail()
      print(error)
    }
  }
}
