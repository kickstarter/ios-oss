import XCTest
import UIKit
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import KsApi
import Result
import ReactiveCocoa
import Prelude

final class RootViewModelTests: TestCase {
  let vm: RootViewModelType = RootViewModel()
  let viewControllerNames = TestObserver<[String], NoError>()
  let selectedIndex = TestObserver<Int, NoError>()
  let scrollToTopControllerName = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.setViewControllers
      .map(extractRootNames)
      .observe(self.viewControllerNames.observer)

    self.vm.outputs.selectedIndex.observe(self.selectedIndex.observer)

    self.vm.outputs.scrollToTop
      .map(extractRootName)
      .ignoreNil()
      .observe(self.scrollToTopControllerName.observer)
  }

  func testSetViewControllers() {
    let viewControllerNames = TestObserver<[String], NoError>()
    vm.outputs.setViewControllers.map(extractRootNames)
      .observe(viewControllerNames.observer)

    vm.inputs.viewDidLoad()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Search", "Activities", "LoginTout"]
      ],
      "Show the logged out tabs."
    )

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    vm.inputs.userSessionStarted()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Search", "Activities", "LoginTout"],
        ["Discovery", "Search", "Activities", "Profile"]
      ],
      "Show the logged in tabs."
    )

    AppEnvironment.updateCurrentUser(.template |> User.lens.stats.memberProjectsCount .~ 1)
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

  func testViewControllersDontOverEmit() {
    let viewControllerNames = TestObserver<[String], NoError>()
    vm.outputs.setViewControllers.map(extractRootNames)
      .observe(viewControllerNames.observer)

    self.vm.inputs.viewDidLoad()

    self.viewControllerNames.assertValueCount(1)

    self.vm.inputs.currentUserUpdated()

    self.viewControllerNames.assertValueCount(1)
  }

  func testSelectedIndex() {
    self.selectedIndex.assertValues([], "No index seleted before view loads.")

    self.vm.inputs.viewDidLoad()

    self.selectedIndex.assertValues([0], "First index selected immediately.")

    self.vm.inputs.didSelectIndex(1)

    self.selectedIndex.assertValues([0, 1], "Selects index immediately.")

    self.vm.inputs.didSelectIndex(0)

    self.selectedIndex.assertValues([0, 1, 0], "Selects index immediately.")

    self.vm.inputs.didSelectIndex(10)

    self.selectedIndex.assertValues([0, 1, 0, 3], "Selecting index out of range safely clamps to bounds.")
  }

  func testScrollToTop() {
    self.scrollToTopControllerName.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.scrollToTopControllerName.assertDidNotEmitValue()

    self.vm.inputs.didSelectIndex(1)

    self.scrollToTopControllerName.assertDidNotEmitValue("Selecting index doesn't cause scroll to top.")

    self.vm.inputs.didSelectIndex(0)

    self.scrollToTopControllerName.assertDidNotEmitValue(
      "Selecting different index doesn't cause scroll to top."
    )

    self.vm.inputs.didSelectIndex(0)

    self.scrollToTopControllerName.assertValues(["Discovery"],
                                                "Selecting index again causes scroll to top.")
  }

  func testSwitchingTabs() {
    self.vm.inputs.viewDidLoad()
    self.selectedIndex.assertValues([0])
    self.vm.inputs.switchToDiscovery()
    self.selectedIndex.assertValues([0, 0])
    self.vm.inputs.switchToActivities()
    self.selectedIndex.assertValues([0, 0, 2])
  }
}

private func extractRootNames(vcs: [UIViewController]) -> [String] {
  return vcs.flatMap(extractRootName)
}

private func extractRootName(vc: UIViewController) -> String? {
  return (vc as? UINavigationController)?
    .viewControllers
    .first
    .map { root in
      "\(root.dynamicType)"
        .stringByReplacingOccurrencesOfString("ViewController", withString: "")
  }
}
