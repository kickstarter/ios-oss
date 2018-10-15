import Prelude
import XCTest
@testable import KsApi

final class UserQueriesTests: XCTestCase {
  func testBaseUserQuery() {
    let query = Query.user(baseUserQueryFields())

    XCTAssertEqual("me { id name uid }", query.description)
    XCTAssertEqual("{ me { id name uid } }", Query.build(NonEmptySet(query)))
  }

  func testUserCurrencyQuery() {
    let query = Query.user(chosenCurrencyQueryFields())

    XCTAssertEqual("me { chosenCurrency id name uid }", query.description)
    XCTAssertEqual("{ me { chosenCurrency id name uid } }", Query.build(NonEmptySet(query)))
  }
}
