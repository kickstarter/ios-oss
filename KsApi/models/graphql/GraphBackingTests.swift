@testable import KsApi
import XCTest

final class GraphBackingTests: XCTestCase {
  func testGraphBackingDecoding() {
    let dictionary: [String: Any] = [
      "backings": [
        "nodes": [
          [
            "id": "QmFja2luZy0xMTMzMTQ5ODE=",
            "amount": [
              "amount": "146.0",
              "currency": "USD",
              "symbol": "$"
            ],
            "bonusAmount": [
              "amount": "5.0",
              "currency": "USD",
              "symbol": "$"
            ],
            "backer": [
              "id": "QmFja2luZy0xMTMzMTC5ODE=",
              "uid": "565656",
              "name": "Backer McGee",
              "imageUrl": "http://www.kickstarter.com/avatar.jpg"
            ],
            "backerCompleted": false,
            "cancelable": true,
            "errorReason": "Your card does not have sufficient funds available.",
            "project": [
              "pid": 674_816_336,
              "slug": "tequila/a-summer-dance-festival",
              "name": "A summer dance festival",
              "state": "LIVE",
              "fxRate": 1.082342,
              "actions": [
                "displayConvertAmount": true
              ],
              "category": [
                "id": "Q2F0ZWdvcnktNTI=",
                "name": "Hardware",
                "parentCategory": [
                  "id": "Q2F0ZWdvcnktMTY=",
                  "name": "Technology"
                ]
              ],
              "finalCollectionDate": "2020-06-17T11:41:29-04:00",
              "location": [
                "country": "CA",
                "countryName": "Canada",
                "displayableName": "Canada",
                "id": "TG9jYXRpb24tMjM0MjQ3NzU=",
                "name": "Canada"
              ],
              "isProjectWeLove": true,
              "prelaunchActivated": false,
              "deadlineAt": 158_750_211,
              "launchedAt": 158_740_211,
              "stateChangedAt": 1_587_502_131,
              "backersCount": 5,
              "creator": [
                "imageUrl": "http://www.kickstarter.com/avatar.jpg",
                "id": "VXNlci0xMjA3OTk3NjQ5",
                "name": "Creator McBaggins",
                "uid": "32434234"
              ],
              "currency": "USD",
              "country": [
                "code": "CA",
                "name": "Canada"
              ],
              "description": "Project description",
              "goal": [
                "amount": "150",
                "currency": "USD",
                "symbol": "$"
              ],
              "pledged": [
                "amount": "173434.0",
                "currency": "USD",
                "symbol": "$"
              ],
              "url": "http://www.kickstarter.com/my/project",
              "image": [
                "id": "UGhvdG8tMTEyNTczMzI=",
                "url": "http://www.kickstarter.com/my/image.jpg"
              ]
            ],
            "status": "errored"
          ]
        ],
        "totalCount": 1
      ],
      "id": "VXNlci00NzM1NjcxODQ="
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    do {
      let envelope = try JSONDecoder().decode(GraphBackingEnvelope.self, from: data)

      XCTAssertEqual(envelope.backings.nodes.count, 1)

      guard let backing = envelope.backings.nodes.first else {
        XCTFail("Should have a backing")
        return
      }

      guard let project = backing.project else {
        XCTFail("Should have a project")
        return
      }

      XCTAssertEqual("QmFja2luZy0xMTMzMTQ5ODE=", backing.id)
      XCTAssertEqual("Your card does not have sufficient funds available.", backing.errorReason)
      XCTAssertEqual(BackingState.errored, backing.status)
      XCTAssertEqual("2020-06-17T11:41:29-04:00", project.finalCollectionDate)
      XCTAssertEqual(674_816_336, project.pid)
      XCTAssertEqual("A summer dance festival", project.name)
      XCTAssertEqual("tequila/a-summer-dance-festival", project.slug)

      XCTAssertNotNil(Backing.backing(from: backing))
      XCTAssertNotNil(Project.project(from: project))
    } catch {
      XCTFail("Failed to decode GraphBackingEnvelope \(error)")
    }
  }
}
