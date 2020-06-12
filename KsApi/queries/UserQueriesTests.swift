@testable import KsApi
import Prelude
import XCTest

final class UserQueriesTests: XCTestCase {
  func testAccountQuery() {
    let query = Query.user(accountQueryFields())

    XCTAssertEqual(
      "me { chosenCurrency email hasPassword isAppleConnected isDeliverable isEmailVerified }",
      query.description
    )
    XCTAssertEqual(
      "{ me { chosenCurrency email hasPassword isAppleConnected isDeliverable isEmailVerified } }",
      Query.build(NonEmptySet(query))
    )
  }

  func testChangeEmailQuery() {
    let query = Query.user(changeEmailQueryFields())

    XCTAssertEqual("me { email isDeliverable isEmailVerified }", query.description)
    XCTAssertEqual("{ me { email isDeliverable isEmailVerified } }", Query.build(NonEmptySet(query)))
  }

  func testStoredCardsQuery() {
    let query = Query.user(storedCardsQueryFields())

    XCTAssertEqual(
      "me { id storedCards { nodes { expirationDate id lastFour type } totalCount } }",
      query.description
    )
    XCTAssertEqual(
      "{ me { id storedCards { nodes { expirationDate id lastFour type } totalCount } } }",
      Query.build(NonEmptySet(query))
    )
  }

  func testBackingsQuery() {
    let query = Query.user(backingsQueryFields(status: GraphBacking.Status.errored.rawValue))
    XCTAssertEqual(
      "me { backings(status: errored) { nodes { errorReason id project { finalCollectionDate name pid slug } status } totalCount } id }",
      query.description
    )
    XCTAssertEqual(
      "{ me { backings(status: errored) { nodes { errorReason id project { finalCollectionDate name pid slug } status } totalCount } id } }",
      Query.build(NonEmptySet(query))
    )
  }
}
