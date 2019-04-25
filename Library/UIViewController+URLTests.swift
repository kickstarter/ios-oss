import SafariServices
import UIKit
import XCTest
@testable import Library

final class UIViewControllerURLTests: TestCase {
  func testSupportedSchemes() {
    XCTAssertEqual(UIViewController.supportedURLSchemes, ["http", "https"])
  }

  func testGoToHttpScheme() {
    guard let url = URL(string: "http://www.kickstarter.com") else {
      XCTFail("URL cannot be nil")
      return
    }

    let vc = UIViewController()

    let window = UIWindow()
    window.rootViewController = vc
    window.makeKeyAndVisible()

    vc.goTo(url: url)

    XCTAssertTrue(vc.presentedViewController is SFSafariViewController)
  }

  func testGoToHttpsScheme() {
    guard let url = URL(string: "https://www.kickstarter.com") else {
      XCTFail("URL cannot be nil")
      return
    }

    let vc = UIViewController()

    let window = UIWindow()
    window.rootViewController = vc
    window.makeKeyAndVisible()

    vc.goTo(url: url)

    XCTAssertTrue(vc.presentedViewController is SFSafariViewController)
  }

  func testGoToUnsupportedUrlScheme_WhichApplicationCanOpen() {
    guard let url = URL(string: "fb://story/?id=1") else {
      XCTFail("URL cannot be nil")
      return
    }

    let mockApplication = MockApplication()
    mockApplication.canOpenURL = true

    withEnvironment(application: mockApplication) {
      let vc = UIViewController()
      vc.goTo(url: url)

      XCTAssertTrue(mockApplication.canOpenURLWasCalled)
      XCTAssertTrue(mockApplication.openUrlWasCalled)
    }
  }

  func testGoToUnsupportedUrlScheme_WhichApplicationCanNotOpen() {
    guard let url = URL(string: "fb://story/?id=1") else {
      XCTFail("URL cannot be nil")
      return
    }

    let mockApplication = MockApplication()

    withEnvironment(application: mockApplication) {
      let vc = UIViewController()
      vc.goTo(url: url)

      XCTAssertTrue(mockApplication.canOpenURLWasCalled)
      XCTAssertFalse(mockApplication.openUrlWasCalled)
    }
  }
}

private final class MockApplication: UIApplicationType {
  var canOpenURL = false
  var canOpenURLWasCalled = false
  var openUrlWasCalled = false

  func canOpenURL(_ url: URL) -> Bool {
    self.canOpenURLWasCalled = true
    return self.canOpenURL
  }

  // swiftlint:disable:next line_length
  func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?) {
    self.openUrlWasCalled = true
  }
}
