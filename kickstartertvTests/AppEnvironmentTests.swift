import XCTest
@testable import kickstartertv

final class AppEnvironmentTests : XCTestCase {

  func testPushAndPopEnvironment() {
    let lang = AppEnvironment.current.language

    AppEnvironment.pushEnvironment()
    XCTAssertEqual(AppEnvironment.current.language, lang)

    AppEnvironment.pushEnvironment(language: .es)
    XCTAssertEqual(AppEnvironment.current.language, Language.es)

    AppEnvironment.pushEnvironment(Environment())
    XCTAssertEqual(AppEnvironment.current.language, Language.en)

    AppEnvironment.popEnvironment()
    XCTAssertEqual(AppEnvironment.current.language, Language.es)

    AppEnvironment.popEnvironment()
    XCTAssertEqual(AppEnvironment.current.language, lang)

    AppEnvironment.popEnvironment()
  }

  func testReplaceCurrentEnvironment() {

    AppEnvironment.pushEnvironment(language: .es)
    XCTAssertEqual(AppEnvironment.current.language, Language.es)

    AppEnvironment.pushEnvironment(language: .fr)
    XCTAssertEqual(AppEnvironment.current.language, Language.fr)

    AppEnvironment.replaceCurrentEnvironment(language: Language.de)
    XCTAssertEqual(AppEnvironment.current.language, Language.de)

    AppEnvironment.popEnvironment()
    XCTAssertEqual(AppEnvironment.current.language, Language.es)
  }
}
