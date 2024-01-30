@testable import KsApi
import XCTest

final class PKCETest: XCTestCase {
  func testCodeChallenge_isValid() {
    let res = try! PKCE.createCodeChallenge(fromVerifier: "foo")
    XCTAssertEqual(res, "LCa0a2j/xo/5m0U8HTBBNBNCLXBkg7+g+YpeiGJm564=")
  }

  func testCreateCodeVerifier_isCorrectLength() {
    let verifier1 = try! PKCE.createCodeVerifier(ofLength: 1)
    XCTAssertEqual(verifier1.count, 1)

    let verifier2 = try! PKCE.createCodeVerifier(ofLength: 32)
    XCTAssertEqual(verifier2.count, 32)

    let verifier3 = try! PKCE.createCodeVerifier(ofLength: 64)
    XCTAssertEqual(verifier3.count, 64)
  }
}
