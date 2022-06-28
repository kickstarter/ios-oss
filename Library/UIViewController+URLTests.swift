@testable import Library
import SafariServices
import UIKit
import XCTest

final class UIViewControllerURLTests: TestCase {
  func testSupportedSchemes() {
    XCTAssertEqual(UIViewController.supportedURLSchemes, ["http", "https"])
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

    XCTAssertNotNil(vc.presentedViewController)

    XCTAssertTrue(vc.presentedViewController is SFSafariViewController)
  }
}
