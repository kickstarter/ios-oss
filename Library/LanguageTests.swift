import XCTest
@testable import Library

final class LanguageTests: XCTestCase {

  func testEquality() {
    XCTAssertEqual(Language.en, Language.en)
    XCTAssertEqual(Language.de, Language.de)
    XCTAssertEqual(Language.fr, Language.fr)
    XCTAssertEqual(Language.es, Language.es)
    XCTAssertNotEqual(Language.en, Language.es)
  }

  func testInitializer() {
    XCTAssertEqual(Language.de, Language(languageString: "De"))
    XCTAssertEqual(Language.en, Language(languageString: "En"))
    XCTAssertEqual(Language.es, Language(languageString: "Es"))
    XCTAssertEqual(Language.fr, Language(languageString: "Fr"))
    XCTAssertNil(Language(languageString: "AB"))
  }

  func testLanguageFromLanguageStrings() {
    XCTAssertEqual(Language.en, Language(languageStrings: ["AB", "EN", "FR"]))
    XCTAssertEqual(Language.es, Language(languageStrings: ["AB", "BC", "ES"]))
    XCTAssertNil(Language(languageStrings: ["AB", "BC", "CD"]))
  }
}
