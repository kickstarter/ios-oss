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
}
