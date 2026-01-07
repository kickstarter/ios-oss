@testable import KsApi
import XCTest

final class PKCETest: XCTestCase {
  func testData_RandomSecureBytes_overwritesOriginalData() {
    let buffer1 = Data(repeating: 0, count: 32)
    var buffer2 = Data(repeating: 0, count: 32)
    var buffer3 = Data(repeating: 0, count: 32)

    XCTAssertEqual(buffer1, buffer2)
    XCTAssertEqual(buffer2, buffer3)

    try! buffer2.fillWithRandomSecureBytes()
    try! buffer3.fillWithRandomSecureBytes()

    XCTAssertNotEqual(
      buffer1,
      buffer2,
      "Buffer filled with random data should not be equal to buffer filled with zeroes"
    )
    XCTAssertNotEqual(
      buffer1,
      buffer3,
      "Buffer filled with random data should not be equal to buffer filled with zeroes"
    )
    XCTAssertNotEqual(buffer2, buffer3, "Two randomly filled buffers should not be equal")
  }

  func testData_SHA256Hash_isCorrectValue() {
    let testString = "Hello, world. I am a string."
    let stringData = testString.data(using: .utf8)

    let hash = try! stringData!.sha256Hash()

    let expectedHashString = "c1c6864039f380248d30a73525c8351427c7fb468d58b7b1005f3e3727a042a1"
    let actualHashString = hash.map { String(format: "%02x", $0) }.joined()

    XCTAssertEqual(expectedHashString, actualHashString)
  }

  func testData_Base64URLEncodedString_isCorrectValue() {
    let testString = "Hello, world. I am a string."

    let expectedEncodedString = "SGVsbG8sIHdvcmxkLiBJIGFtIGEgc3RyaW5nLg"
    let actualEncodedString = testString.data(using: .utf8)!.base64URLEncodedStringWithNoPadding()

    XCTAssertEqual(expectedEncodedString, actualEncodedString)
  }

  func testPKCECodeChallenge_givenSentence_isCorrect() {
    // Use https://oauth.school/exercise/refresh/ to obtain a code challenge from a string.
    let r1 = try! PKCE.createCodeChallenge(fromVerifier: "Hello, world. I am a string.")
    XCTAssertEqual(r1, "wcaGQDnzgCSNMKc1Jcg1FCfH-0aNWLexAF8-NyegQqE")

    let r2 = try! PKCE.createCodeChallenge(fromVerifier: "Another test string.")
    XCTAssertEqual(r2, "kvYrE5sk3NsQbuSV_H9sWnAGpOFx8gw09MJ80SDx5Ag")

    let r3 = try! PKCE.createCodeChallenge(fromVerifier: "Just one more, for good measure!")
    XCTAssertEqual(r3, "0elvB0AIlk_NSBDvOtDwUP5x6AAI2ugJDBe075L2DHI")
  }

  func testCheckCodeVerifier_tooShort_returnsFalse() {
    let verifier = try! PKCE.createCodeVerifier(byteLength: 2)
    XCTAssertFalse(PKCE.checkCodeVerifier(verifier))
  }

  func testCheckCodeVerifier_tooLong_returnsFalse() {
    let verifier = try! PKCE.createCodeVerifier(byteLength: 256)
    XCTAssertFalse(PKCE.checkCodeVerifier(verifier))
  }

  func testCheckCodeVerifier_languageSentence_returnsFalse() {
    let verifier = "Hello, world. I am a string. Hello, world. I am a string."
    XCTAssertFalse(PKCE.checkCodeVerifier(verifier))
  }

  func testCheckCodeVerifier_validVerifier_returnsTrue() {
    let verifier = try! PKCE.createCodeVerifier(byteLength: 32)
    XCTAssertTrue(PKCE.checkCodeVerifier(verifier))
  }
}
