import Foundation
@testable import KsApi
import XCTest

final class UserEnvelope_GraphUserEnvelopeTests: XCTestCase {
  func test() {
    let fetchUserQueryData = GraphAPI.FetchUserQuery
      .Data(unsafeResultMap: GraphUserEnvelopeTemplates.userJSONDict)

    guard let envelope = UserEnvelope<GraphUser>.userEnvelope(from: fetchUserQueryData) else {
      XCTFail()
      return
    }

    XCTAssertNil(envelope.me.chosenCurrency)
    XCTAssertEqual(envelope.me.email, "nativesquad@ksr.com")
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
      UserCreditCards(storedCards: [
        UserCreditCards
          .CreditCard(expirationDate: "2023-01-01", id: "6", lastFour: "4242", type: .visa)
      ])
    )
    XCTAssertEqual(envelope.me.uid, "1470952545")
  }
}
