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
  let tabBarItemsData = TestObserver<TabBarItemsData, NoError>()
  let profileItemData = TestObserver<ProfileTabBarItemData, NoError>()

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

    self.vm.outputs.tabBarItemsData.observe(self.tabBarItemsData.observer)
    self.vm.outputs.profileTabBarItemData.observe(self.profileItemData.observer)
  }

  func testSetViewControllers() {
    let viewControllerNames = TestObserver<[String], NoError>()
    vm.outputs.setViewControllers.map(extractRootNames)
      .observe(viewControllerNames.observer)

    vm.inputs.viewDidLoad()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Activities", "Search", "LoginTout"]
      ],
      "Show the logged out tabs."
    )

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    vm.inputs.userSessionStarted()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Activities", "Search", "LoginTout"],
        ["Discovery", "Activities", "Search", "Profile"]
      ],
      "Show the logged in tabs."
    )

    AppEnvironment.updateCurrentUser(.template |> User.lens.stats.memberProjectsCount .~ 1)
    vm.inputs.currentUserUpdated()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Activities", "Search", "LoginTout"],
        ["Discovery", "Activities", "Search", "Profile"],
        ["Discovery", "Activities", "Search", "Dashboard", "Profile"]
      ],
      "Show the creator dashboard tab."
    )

    AppEnvironment.logout()
    vm.inputs.userSessionEnded()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Activities", "Search", "LoginTout"],
        ["Discovery", "Activities", "Search", "Profile"],
        ["Discovery", "Activities", "Search", "Dashboard", "Profile"],
        ["Discovery", "Activities", "Search", "LoginTout"],
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
    self.selectedIndex.assertValues([0, 0, 1])
  }

  func testTabBarItemStyles() {
    let items = [
      TabBarItem.home(index: 0),
      .activity(index: 1),
      .search(index: 2),
      .profile(index: 3)
    ]
    let itemsMember = [
      TabBarItem.home(index: 0),
      .activity(index: 1),
      .search(index: 2),
      .dashboard(index: 3),
      .profile(index: 4)
    ]
    let tabData = TabBarItemsData(items: items, isLoggedIn: false, isMember: false)
    let tabDataLoggedIn = TabBarItemsData(items: items, isLoggedIn: true, isMember: false)
    let tabDataMember = TabBarItemsData(items: itemsMember, isLoggedIn: true, isMember: true)

    self.tabBarItemsData.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.tabBarItemsData.assertValues([tabData])

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    self.vm.inputs.userSessionStarted()

    self.tabBarItemsData.assertValues([tabData, tabDataLoggedIn])

    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()

    self.tabBarItemsData.assertValues([tabData, tabDataLoggedIn, tabData])

    let creator = .template |> User.lens.stats.memberProjectsCount .~ 1
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: creator))
    self.vm.inputs.userSessionStarted()

    self.tabBarItemsData.assertValues([tabData, tabDataLoggedIn, tabData, tabDataMember])
  }

  func testProfileTabBarItem() {
    let user = .template |> User.lens.avatar.small .~ "http://image.com/image"
    let creator = .template
      |> User.lens.stats.memberProjectsCount .~ 1
      |> User.lens.avatar.small .~ "http://image.com/image2"

    let data = ProfileTabBarItemData(avatarUrl: NSURL(string: user.avatar.small),
                                     isMember: false,
                                     item: TabBarItem.profile(index: 3))
    let dataMember = ProfileTabBarItemData(avatarUrl: NSURL(string: creator.avatar.small),
                                     isMember: true,
                                     item: TabBarItem.profile(index: 4))

    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()
    self.vm.inputs.viewDidLoad()

    self.profileItemData.assertValueCount(0)

    // logged in avatar
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.userSessionStarted()

    self.profileItemData.assertValues([data])

    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()

    self.profileItemData.assertValues([data], "Profile image does not emit on logout")

    // logged in avatar member
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: creator))
    self.vm.inputs.userSessionStarted()

    self.profileItemData.assertValues([data, dataMember])
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
