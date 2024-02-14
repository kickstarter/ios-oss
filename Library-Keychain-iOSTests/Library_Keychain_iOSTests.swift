import XCTest

final class Library_Keychain_iOSTests: XCTestCase {
  func testLibraryKeychainExists() {
    XCTAssertTrue(true)

    /*
     This testing bundle, Library-Keychain-iOSTests, exists so that we can run KeychainTests.

     Testing the keychain requires the unit tests to be hosted; otherwise it throws errors
     about missing entitlements.

     However, the rest of our library tests require the unit tests NOT to be hosted.
     This target is just split out so we can run KeychainTests.swift in that hosted environment..

     */
  }
}
