import Foundation
@testable import Library
import UIKit
import XCTest

final class FacebookSDKTypeTests: XCTestCase {
  override func setUp() {
    super.setUp()
    MockFacebookSDK.reset()
  }

  func testMockFacebookSDKConfigure() {
    // Given
    let appID = "test_app_id"
    let application = UIApplication.shared
    let launchOptions: [UIApplication.LaunchOptionsKey: Any]? = [.init(rawValue: "test"): "value"]

    // When
    MockFacebookSDK.configure(
      appID: appID,
      application: application,
      launchOptions: launchOptions
    )

    // Then
    XCTAssertTrue(MockFacebookSDK.configureCalled)
    XCTAssertEqual(MockFacebookSDK.configureAppID, appID)
    XCTAssertEqual(MockFacebookSDK.configureApplication, application)
    XCTAssertEqual(MockFacebookSDK.configureLaunchOptions?[.init(rawValue: "test")] as? String, "value")
  }

  func testMockFacebookSDKHandleOpenURL() {
    // Given
    let application = UIApplication.shared
    let url = URL(string: "https://example.com")!
    let options: [UIApplication.OpenURLOptionsKey: Any] = [.init(rawValue: "test"): "value"]
    MockFacebookSDK.handleOpenURLReturnValue = true

    // When
    let result = MockFacebookSDK.handleOpenURL(application, open: url, options: options)

    // Then
    XCTAssertTrue(MockFacebookSDK.handleOpenURLCalled)
    XCTAssertEqual(MockFacebookSDK.handleOpenURLApp, application)
    XCTAssertEqual(MockFacebookSDK.handleOpenURLURL, url)
    XCTAssertEqual(MockFacebookSDK.handleOpenURLOptions?[.init(rawValue: "test")] as? String, "value")
    XCTAssertTrue(result)
  }

  func testMockFacebookSDKReset() {
    // Given
    MockFacebookSDK.configure(appID: "test", application: UIApplication.shared, launchOptions: nil)
    _ = MockFacebookSDK.handleOpenURL(
      UIApplication.shared,
      open: URL(string: "https://test.com")!,
      options: [:]
    )

    // When
    MockFacebookSDK.reset()

    // Then
    XCTAssertFalse(MockFacebookSDK.configureCalled)
    XCTAssertNil(MockFacebookSDK.configureAppID)
    XCTAssertNil(MockFacebookSDK.configureApplication)
    XCTAssertNil(MockFacebookSDK.configureLaunchOptions)
    XCTAssertFalse(MockFacebookSDK.handleOpenURLCalled)
    XCTAssertNil(MockFacebookSDK.handleOpenURLApp)
    XCTAssertNil(MockFacebookSDK.handleOpenURLURL)
    XCTAssertNil(MockFacebookSDK.handleOpenURLOptions)
    XCTAssertFalse(MockFacebookSDK.handleOpenURLReturnValue)
  }
}
