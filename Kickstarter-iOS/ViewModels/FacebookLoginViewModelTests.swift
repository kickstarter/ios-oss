@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class FacebookLoginViewModelTests: TestCase {
  let vm: FacebookLoginViewModelType = FacebookLoginViewModel()

  func testFacebookAppDelegate() {
    XCTAssertFalse(self.facebookAppDelegate.didFinishLaunching)
    XCTAssertFalse(self.facebookAppDelegate.openedUrl)

    self.vm.inputs.applicationDidFinishLaunching(
      application: UIApplication.shared,
      launchOptions: [:]
    )

    XCTAssertTrue(self.facebookAppDelegate.didFinishLaunching)
    XCTAssertFalse(self.facebookAppDelegate.openedUrl)

    let result = self.vm.inputs.applicationOpenUrl(
      application: UIApplication.shared,
      url: URL(string: "http://www.fb.com")!,
      options: [:]
    )
    XCTAssertFalse(result)

    XCTAssertTrue(self.facebookAppDelegate.openedUrl)
  }
}
