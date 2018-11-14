import Prelude
import XCTest
@testable import KsApi

final class UserQueriesTests: XCTestCase {
  func testUserCurrencyQuery() {
    let query = Query.user(chosenCurrencyQueryFields())

    XCTAssertEqual("me { chosenCurrency }", query.description)
    XCTAssertEqual("{ me { chosenCurrency } }", Query.build(NonEmptySet(query)))
  }

  func testUserEmailQuery() {
    let query = Query.user(userEmailQueryFields())

    XCTAssertEqual("me { email }", query.description)
    XCTAssertEqual("{ me { email } }", Query.build(NonEmptySet(query)))
  }

  func testStoredCardsQuery() {
    let query = Query.user(storedCardsQueryFields())

    XCTAssertEqual("me { id storedCards { nodes { expirationDate id lastFour type } totalCount } }",
                   query.description)
    XCTAssertEqual("{ me { id storedCards { nodes { expirationDate id lastFour type } totalCount } } }",
                   Query.build(NonEmptySet(query)))
  }
}
