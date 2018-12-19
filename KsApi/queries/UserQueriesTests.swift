import Prelude
import XCTest
@testable import KsApi

final class UserQueriesTests: XCTestCase {
  func testAccountQuery() {
    let query = Query.user(accountQueryFields())

    XCTAssertEqual("me { chosenCurrency hasPassword isDeliverable isEmailVerified }", query.description)
    XCTAssertEqual(
      "{ me { chosenCurrency hasPassword isDeliverable isEmailVerified } }", Query.build(NonEmptySet(query))
    )
  }

  func testChangeEmailQuery() {
    let query = Query.user(changeEmailQueryFields())

    XCTAssertEqual("me { email isDeliverable isEmailVerified }", query.description)
    XCTAssertEqual("{ me { email isDeliverable isEmailVerified } }", Query.build(NonEmptySet(query)))
  }

  func testStoredCardsQuery() {
    let query = Query.user(storedCardsQueryFields())

    XCTAssertEqual("me { id storedCards { nodes { expirationDate id lastFour type } totalCount } }",
                   query.description)
    XCTAssertEqual("{ me { id storedCards { nodes { expirationDate id lastFour type } totalCount } } }",
                   Query.build(NonEmptySet(query)))
  }
}
