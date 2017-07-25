import XCTest
import UIKit
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import KsApi
import Result
import ReactiveSwift
import Prelude

final class RootViewModelTests: TestCase {
  let vm: RootViewModelType = RootViewModel()
  let viewControllerNames = TestObserver<[String], NoError>()
  let filterDiscovery = TestObserver<DiscoveryParams, NoError>()
  let selectedIndex = TestObserver<Int, NoError>()
  let scrollToTopControllerName = TestObserver<String, NoError>()
  let switchDashboardProject = TestObserver<Param, NoError>()
  let tabBarItemsData = TestObserver<TabBarItemsData, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.setViewControllers
      .map(extractRootNames)
      .observe(self.viewControllerNames.observer)

    self.vm.outputs.filterDiscovery.map(second).observe(self.filterDiscovery.observer)
    self.vm.outputs.selectedIndex.observe(self.selectedIndex.observer)
    self.vm.outputs.switchDashboardProject.map(second).observe(self.switchDashboardProject.observer)

    self.vm.outputs.scrollToTop
      .map(extractRootName)
      .skipNil()
      .observe(self.scrollToTopControllerName.observer)

    self.vm.outputs.tabBarItemsData.observe(self.tabBarItemsData.observer)
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

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
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

  func testBackerDashboardFeatureFlagEnabled() {
    let config = .template
      |> Config.lens.features .~ ["ios_backer_dashboard": true]

    withEnvironment(config: config) {
      vm.inputs.viewDidLoad()
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
      vm.inputs.userSessionStarted()

      viewControllerNames.assertValues(
        [
          ["Discovery", "Activities", "Search", "LoginTout"],
          ["Discovery", "Activities", "Search", "BackerDashboard"]
        ],
        "Show the BackerDashboard instead of Profile."
      )

      AppEnvironment.updateCurrentUser(.template |> User.lens.stats.memberProjectsCount .~ 1)
      vm.inputs.currentUserUpdated()

      viewControllerNames.assertValues(
        [
          ["Discovery", "Activities", "Search", "LoginTout"],
          ["Discovery", "Activities", "Search", "BackerDashboard"],
          ["Discovery", "Activities", "Search", "Dashboard", "BackerDashboard"]
        ],
        "Show the creator dashboard tab."
      )
    }
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

    self.selectedIndex.assertValues([], "No index selected immediately.")

    self.vm.inputs.didSelectIndex(1)

    self.selectedIndex.assertValues([1], "Selects index immediately.")

    self.vm.inputs.didSelectIndex(0)

    self.selectedIndex.assertValues([1, 0], "Selects index immediately.")

    self.vm.inputs.didSelectIndex(10)

    self.selectedIndex.assertValues([1, 0, 3], "Selecting index out of range safely clamps to bounds.")
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
    self.selectedIndex.assertValues([])
    self.vm.inputs.switchToDiscovery(params: nil)
    self.selectedIndex.assertValues([0])
    self.vm.inputs.switchToActivities()
    self.selectedIndex.assertValues([0, 1])
    self.vm.inputs.switchToSearch()
    self.selectedIndex.assertValues([0, 1, 2])
    self.vm.inputs.switchToProfile()
    self.selectedIndex.assertValues([0, 1, 2])
    self.vm.inputs.switchToLogin()
    self.selectedIndex.assertValues([0, 1, 2, 3])

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
    self.vm.inputs.userSessionStarted()

    self.selectedIndex.assertValues([0, 1, 2, 3, 3])
    self.vm.inputs.switchToProfile()
    self.selectedIndex.assertValues([0, 1, 2, 3, 3, 3])
    self.vm.inputs.switchToLogin()
    self.selectedIndex.assertValues([0, 1, 2, 3, 3, 3])
  }

  func testSwitchToDiscoveryParam() {
    self.vm.inputs.viewDidLoad()

    let params = DiscoveryParams.defaults

    self.filterDiscovery.assertValues([])
    self.vm.inputs.switchToDiscovery(params: params)
    self.filterDiscovery.assertValues([params])
  }

  func testSwitchToDashboardParam() {
    self.vm.inputs.viewDidLoad()

    let param = Param.id(1)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template
      |> User.lens.stats.memberProjectsCount .~ 1))
    self.vm.inputs.userSessionStarted()

    self.switchDashboardProject.assertValues([])
    self.vm.inputs.switchToDashboard(project: param)
    self.switchDashboardProject.assertValues([param])
  }

  func testTabBarItemStyles() {
    let user = .template |> User.lens.avatar.small .~ "http://image.com/image"
    let creator = .template
      |> User.lens.stats.memberProjectsCount .~ 1
      |> User.lens.avatar.small .~ "http://image.com/image2"

    let items: [TabBarItem] = [
      .home(index: 0),
      .activity(index: 1),
      .search(index: 2),
      .profile(avatarUrl: nil, index: 3)
    ]

    let itemsLoggedIn: [TabBarItem] = [
      .home(index: 0),
      .activity(index: 1),
      .search(index: 2),
      .profile(avatarUrl: URL(string: user.avatar.small), index: 3)
    ]
    let itemsMember: [TabBarItem] = [
      .home(index: 0),
      .activity(index: 1),
      .search(index: 2),
      .dashboard(index: 3),
      .profile(avatarUrl: URL(string: creator.avatar.small), index: 4)
    ]

    let tabData = TabBarItemsData(items: items, isLoggedIn: false, isMember: false)
    let tabDataLoggedIn = TabBarItemsData(items: itemsLoggedIn, isLoggedIn: true, isMember: false)
    let tabDataMember = TabBarItemsData(items: itemsMember, isLoggedIn: true, isMember: true)

    self.tabBarItemsData.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.tabBarItemsData.assertValues([tabData])

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.userSessionStarted()

    self.tabBarItemsData.assertValues([tabData, tabDataLoggedIn])

    self.vm.inputs.currentUserUpdated()

    self.tabBarItemsData.assertValues([tabData, tabDataLoggedIn, tabDataLoggedIn])

    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()

    self.tabBarItemsData.assertValues([tabData, tabDataLoggedIn, tabDataLoggedIn, tabData])

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: creator))
    self.vm.inputs.userSessionStarted()

    self.tabBarItemsData.assertValues([tabData, tabDataLoggedIn, tabDataLoggedIn, tabData, tabDataMember])
  }

  func testSetViewControllers_DoesNotFilterDiscovery() {
    self.filterDiscovery.assertValueCount(0)

    let viewControllerNames = TestObserver<[String], NoError>()
    vm.outputs.setViewControllers.map(extractRootNames)
      .observe(viewControllerNames.observer)

    vm.inputs.viewDidLoad()

    let params = DiscoveryParams.defaults
    self.vm.inputs.switchToDiscovery(params: params)
    self.filterDiscovery.assertValues([params])

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
    vm.inputs.userSessionStarted()

    AppEnvironment.updateCurrentUser(.template |> User.lens.stats.memberProjectsCount .~ 1)
    vm.inputs.currentUserUpdated()

    AppEnvironment.logout()
    vm.inputs.userSessionEnded()

    self.viewControllerNames.assertValueCount(4)
    self.filterDiscovery.assertValues([params])
  }
}

private func extractRootNames(_ vcs: [UIViewController]) -> [String] {
  return vcs.flatMap(extractRootName)
}

private func extractRootName(_ vc: UIViewController) -> String? {
  return (vc as? UINavigationController)?
    .viewControllers
    .first
    .map { root in
      "\(type(of: root))"
        .replacingOccurrences(of: "ViewController", with: "")
  }
}
