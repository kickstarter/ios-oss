import XCTest
@testable import Kickstarter_tvOS

final class LanguageTests : XCTestCase {

  func testEquality() {

    XCTAssertEqual(Language.en, Language.en)
    XCTAssertEqual(Language.de, Language.de)
    XCTAssertEqual(Language.fr, Language.fr)
    XCTAssertEqual(Language.es, Language.es)

    XCTAssertNotEqual(Language.en, Language.es)
  }
}
