import Prelude
import XCTest
@testable import KsApi

final class UserQueriesTests: XCTestCase {
  func testUserCurrencyQuery() {
    let query = Query.user(chosenCurrencyQueryFields())

    XCTAssertEqual("me { chosenCurrency }", query.description)
    XCTAssertEqual("{ me { chosenCurrency } }", Query.build(NonEmptySet(query)))
  }
}
