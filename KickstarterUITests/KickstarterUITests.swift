@testable import Library
import SafariServices
import UIKit
import XCTest

final class KickstarterUITests: TestCase {
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
