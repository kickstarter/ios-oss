import Foundation
@testable import KsApi
import XCTest

final class UserEnvelope_GraphUserEnvelopeTests: XCTestCase {
  func testFetchUserEvelope_GraphUser_Success() {
    let fetchUserQueryData = GraphAPI.FetchUserQuery
      .Data(unsafeResultMap: GraphUserEnvelopeTemplates.userJSONDict)

    guard let envelope = UserEnvelope<GraphUser>.userEnvelope(from: fetchUserQueryData) else {
      XCTFail()
      return
    }

    XCTAssertNil(envelope.me.chosenCurrency)
    XCTAssertEqual(envelope.me.email, "user@example.com")
    XCTAssertEqual(envelope.me.hasPassword, true)
    XCTAssertEqual(envelope.me.id, "fakeId")
    XCTAssertEqual(envelope.me.imageUrl, "https://i.kickstarter.com/missing_user_avatar.png")
    XCTAssertEqual(envelope.me.isAppleConnected, false)
    XCTAssertEqual(envelope.me.isBlocked, false)
    XCTAssertEqual(envelope.me.isCreator, false)
    XCTAssertEqual(envelope.me.isDeliverable, true)
    XCTAssertEqual(envelope.me.isEmailVerified, true)
    XCTAssertEqual(envelope.me.name, "Example User")
    XCTAssertEqual(
      envelope.me.storedCards,
      UserCreditCards(storedCards: [
        UserCreditCards
          .CreditCard(
            expirationDate: "2023-01-01",
            id: "6",
            lastFour: "4242",
            type: .visa,
            stripeCardId: "pm_1OtGFX4VvJ2PtfhK3Gp00SWK"
          )
      ])
    )
    XCTAssertEqual(envelope.me.uid, "11111")
  }

  func testFetchUserEnvelope_User_Success() {
    let fetchUserQueryData = GraphAPI.FetchUserQuery
      .Data(unsafeResultMap: GraphUserEnvelopeTemplates.userJSONDict)

    guard let envelope = UserEnvelope<User>.userEnvelope(from: fetchUserQueryData) else {
      XCTFail()
      return
    }

    XCTAssertNil(envelope.me.chosenCurrency)
    XCTAssertEqual(envelope.me.email, "user@example.com")
    XCTAssertEqual(envelope.me.hasPassword, true)
    XCTAssertEqual(envelope.me.id, "fakeId")
    XCTAssertEqual(envelope.me.imageUrl, "https://i.kickstarter.com/missing_user_avatar.png")
    XCTAssertEqual(envelope.me.isAppleConnected, false)
    XCTAssertEqual(envelope.me.isBlocked, false)
    XCTAssertEqual(envelope.me.isCreator, false)
    XCTAssertEqual(envelope.me.isDeliverable, true)
    XCTAssertEqual(envelope.me.isEmailVerified, true)
    XCTAssertEqual(envelope.me.name, "Example User")
    XCTAssertEqual(
      envelope.me.storedCards,
      UserCreditCards(storedCards: [
        UserCreditCards
          .CreditCard(
            expirationDate: "2023-01-01",
            id: "6",
            lastFour: "4242",
            type: .visa,
            stripeCardId: "pm_1OtGFX4VvJ2PtfhK3Gp00SWK"
          )
      ])
    )
    XCTAssertEqual(envelope.me.uid, "11111")
  }

  func testFetchUserEmail() {
    let fetchUserEmailQueryData = GraphAPI.FetchUserEmailQuery
      .Data(unsafeResultMap: GraphUserEnvelopeTemplates.userJSONDict)

    guard let envelope = UserEnvelope<GraphUserEmail>.userEnvelope(from: fetchUserEmailQueryData) else {
      XCTFail()
      return
    }

    XCTAssertEqual(envelope.me.email, "user@example.com")
  }
}
