@testable import KsApi
import Prelude
import XCTest

final class UserQueriesTests: XCTestCase {
  func testAccountQuery() {
    let query = Query.user(accountQueryFields())

    XCTAssertEqual(
      "me { chosenCurrency email hasPassword id imageUrl: imageUrl(blur: false, width: 1024) isAppleConnected isDeliverable isEmailVerified name uid }",
      query.description
    )
    XCTAssertEqual(
      "{ me { chosenCurrency email hasPassword id imageUrl: imageUrl(blur: false, width: 1024) isAppleConnected isDeliverable isEmailVerified name uid } }",
      Query.build(NonEmptySet(query))
    )
  }

  func testChangeEmailQuery() {
    let query = Query.user(changeEmailQueryFields())

    XCTAssertEqual(
      "me { email id imageUrl: imageUrl(blur: false, width: 1024) isDeliverable isEmailVerified name uid }",
      query.description
    )
    XCTAssertEqual(
      "{ me { email id imageUrl: imageUrl(blur: false, width: 1024) isDeliverable isEmailVerified name uid } }",
      Query.build(NonEmptySet(query))
    )
  }

  func testStoredCardsQuery() {
    let query = Query.user(storedCardsQueryFields())

    XCTAssertEqual(
      "me { chosenCurrency id imageUrl: imageUrl(blur: false, width: 1024) name storedCards { nodes { expirationDate id lastFour type } totalCount } uid }",
      query.description
    )
    XCTAssertEqual(
      "{ me { chosenCurrency id imageUrl: imageUrl(blur: false, width: 1024) name storedCards { nodes { expirationDate id lastFour type } totalCount } uid } }",
      Query.build(NonEmptySet(query))
    )
  }

  func testBackingsQuery() {
    let query = Query.user(backingsQueryFields(status: BackingState.errored.rawValue))
    XCTAssertEqual(
      "me { backings(status: errored) { nodes { errorReason id project { finalCollectionDate name pid slug } status } totalCount } id imageUrl: imageUrl(blur: false, width: 1024) name uid }",
      query.description
    )
    XCTAssertEqual(
      "{ me { backings(status: errored) { nodes { errorReason id project { finalCollectionDate name pid slug } status } totalCount } id imageUrl: imageUrl(blur: false, width: 1024) name uid } }",
      Query.build(NonEmptySet(query))
    )
  }
}
