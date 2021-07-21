import Foundation
@testable import KsApi
import XCTest

final class UserEnvelope_GraphUserEnvelopeTests: XCTestCase {
  func test() {
    let jsonDict: [String: Any?] =
      [
        "me": [
          "chosenCurrency": nil,
          "email": "foo@bar.com",
          "hasPassword": true,
          "id": "VXNlci0xNDcwOTUyNTQ1",
          "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
          "isAppleConnected": false,
          "isCreator": false,
          "isDeliverable": true,
          "isEmailVerified": true,
          "name": "Hari Singh",
          "storedCards": [
            "nodes": [
              [
                "expirationDate": "2023-01-01",
                "id": "6",
                "lastFour": "4242",
                "type": GraphAPI.CreditCardTypes(rawValue: "VISA") as Any
              ]
            ],
            "totalCount": 1
          ],
          "uid": "1470952545"
        ]
      ]

    let fetchUserQueryData = GraphAPI.FetchUserQuery.Data(unsafeResultMap: jsonDict)
    guard let envelope = UserEnvelope<GraphUser>.userEnvelope(from: fetchUserQueryData) else {
      XCTFail()
      return
    }

    XCTAssertNil(envelope.me.chosenCurrency)
    XCTAssertEqual(envelope.me.email, "foo@bar.com")
    XCTAssertEqual(envelope.me.hasPassword, true)
    XCTAssertEqual(envelope.me.id, "VXNlci0xNDcwOTUyNTQ1")
    XCTAssertEqual(
      envelope.me.imageUrl,
      "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8"
    )
    XCTAssertEqual(envelope.me.isAppleConnected, false)
    XCTAssertEqual(envelope.me.isCreator, false)
    XCTAssertEqual(envelope.me.isDeliverable, true)
    XCTAssertEqual(envelope.me.isEmailVerified, true)
    XCTAssertEqual(envelope.me.name, "Hari Singh")
    XCTAssertEqual(
      envelope.me.storedCards,
      GraphUserCreditCard(nodes: [
        GraphUserCreditCard
          .CreditCard(expirationDate: "2023-01-01", id: "6", lastFour: "4242", type: .visa)
      ])
    )
    XCTAssertEqual(envelope.me.uid, "1470952545")
  }
}
