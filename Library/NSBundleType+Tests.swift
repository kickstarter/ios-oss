@testable import Library
import XCTest

class NSBundleTests: XCTestCase {
  func testDebugAppVersionString() {
    let bundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.debug.rawValue, lang: "en")
    XCTAssertEqual(bundle.appVersionString, "1.2.3.4.5.6.7.8.9.0 #1234567890")
  }

  func testReleaseAppVersionString() {
    let bundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue, lang: "en")
    XCTAssertEqual(bundle.appVersionString, "1.2.3.4.5.6.7.8.9.0")
  }
}
