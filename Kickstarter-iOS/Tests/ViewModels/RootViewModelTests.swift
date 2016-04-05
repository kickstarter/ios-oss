import XCTest
import UIKit
@testable import Kickstarter_iOS
@testable import Library
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import ReactiveExtensions_TestHelpers
@testable import Models_TestHelpers
import Result
import ReactiveCocoa

final class RootViewModelTests: XCTestCase {
  let vm: RootViewModelType = RootViewModel()
  let apiService = MockService()

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(
      currentUser: nil,
      ubiquitousStore: MockKeyValueStore(),
      userDefaults: MockKeyValueStore()
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  func testViewControllers() {
    let viewControllerNames = TestObserver<[String], NoError>()
    vm.outputs.setViewControllers.map(extractControllerNames)
      .observe(viewControllerNames.observer)

    vm.inputs.viewDidLoad()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Search", "Activities", "LoginTout"]
      ],
      "Show the logged out tabs."
    )

    AppEnvironment.login(AccessTokenEnvelope(access_token: "deadbeef", user: UserFactory.user))
    vm.inputs.userSessionStarted()
    
    viewControllerNames.assertValues(
      [
        ["Discovery", "Search", "Activities", "LoginTout"],
        ["Discovery", "Search", "Activities", "Profile"]
      ],
      "Show the logged in tabs."
    )

    AppEnvironment.updateCurrentUser(UserFactory.creator)
    vm.inputs.currentUserUpdated()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Search", "Activities", "LoginTout"],
        ["Discovery", "Search", "Activities", "Profile"],
        ["Discovery", "Search", "Activities", "Dashboard", "Profile"]
      ],
      "Show the creator dashboard tab."
    )

    AppEnvironment.logout()
    vm.inputs.userSessionEnded()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Search", "Activities", "LoginTout"],
        ["Discovery", "Search", "Activities", "Profile"],
        ["Discovery", "Search", "Activities", "Dashboard", "Profile"],
        ["Discovery", "Search", "Activities", "LoginTout"],
      ],
      "Show the logged out tabs."
    )
  }
}

private func extractControllerNames(vcs: [UIViewController]) -> [String] {
  return vcs
    .flatMap { vc in (vc as? UINavigationController)?.viewControllers.first }
    .map { root in
      "\(root.dynamicType)"
        .stringByReplacingOccurrencesOfString("ViewController", withString: "")
  }
}
