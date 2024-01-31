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

  func testPKCECodeChallenge_isValid() {
    // TODO: Add more examples.
    let res = try! PKCE.createCodeChallenge(fromVerifier: "foo")
    XCTAssertEqual(res, "LCa0a2j_xo_5m0U8HTBBNBNCLXBkg7-g-YpeiGJm564")
  }

  func testPKCECreateCodeVerifier_matchesRequirements() {
    let verifier = try! PKCE.createCodeVerifier(byteLength: 32)
    XCTAssertEqual(verifier.count, 43)

    let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let lowercase = "abcdefghijklmnopqrstuvwxyz"
    let numbers = "0123456789"
    let specials = "-._~"

    let validCharacters = CharacterSet(charactersIn: uppercase + lowercase + numbers + specials)

    for character in verifier {
      let unichar = character.unicodeScalars.first!
      XCTAssertTrue(validCharacters.contains(unichar), "\(unichar) not in valid character set")
    }
  }
}
