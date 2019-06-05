@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

final class RootViewModelTests: TestCase {
  let vm: RootViewModelType = RootViewModel()
  let viewControllerNames = TestObserver<[String], Never>()
  let filterDiscovery = TestObserver<DiscoveryParams, Never>()
  let selectedIndex = TestObserver<RootViewControllerIndex, Never>()
  let setBadgeValueAtIndexValue = TestObserver<String?, Never>()
  let setBadgeValueAtIndexIndex = TestObserver<RootViewControllerIndex, Never>()
  let scrollToTopControllerName = TestObserver<String, Never>()
  let switchDashboardProject = TestObserver<Param, Never>()
  let tabBarItemsData = TestObserver<TabBarItemsData, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.setViewControllers
      .map(extractRootNames)
      .observe(self.viewControllerNames.observer)

    self.vm.outputs.filterDiscovery.map(second).observe(self.filterDiscovery.observer)
    self.vm.outputs.selectedIndex.observe(self.selectedIndex.observer)
    self.vm.outputs.setBadgeValueAtIndex.map { $0.0 }.observe(self.setBadgeValueAtIndexValue.observer)
    self.vm.outputs.setBadgeValueAtIndex.map { $0.1 }.observe(self.setBadgeValueAtIndexIndex.observer)
    self.vm.outputs.switchDashboardProject.map(second).observe(self.switchDashboardProject.observer)

    let viewControllers = self.vm.outputs.setViewControllers
      .map { $0.map { $0.viewController }.compact() }

    Signal.combineLatest(viewControllers, self.vm.outputs.scrollToTop)
      .map { vcs, idx in vcs[clamp(0, vcs.count - 1)(idx)] }
      .map(extractName)
      .observe(self.scrollToTopControllerName.observer)

    self.vm.outputs.tabBarItemsData.observe(self.tabBarItemsData.observer)
  }

  func testSetBadgeValueAtIndex_NoValue() {
    let mockApplication = MockApplication()
    mockApplication.applicationIconBadgeNumber = 0

    self.setBadgeValueAtIndexValue.assertValues([])
    self.setBadgeValueAtIndexIndex.assertValues([])

    withEnvironment(application: mockApplication) {
      self.vm.inputs.viewDidLoad()

      self.setBadgeValueAtIndexValue.assertValues([nil])
      self.setBadgeValueAtIndexIndex.assertValues([1])
    }
  }

  func testSetBadgeValueAtIndex_ValueSet() {
    let mockApplication = MockApplication()
    mockApplication.applicationIconBadgeNumber = 5

    self.setBadgeValueAtIndexValue.assertValues([])
    self.setBadgeValueAtIndexIndex.assertValues([])

    withEnvironment(application: mockApplication) {
      self.vm.inputs.viewDidLoad()

      self.setBadgeValueAtIndexValue.assertValues(["5"])
      self.setBadgeValueAtIndexIndex.assertValues([1])
    }
  }

  func testSetBadgeValueAtIndex_MaxValueSet() {
    let mockApplication = MockApplication()
    mockApplication.applicationIconBadgeNumber = 100

    self.setBadgeValueAtIndexValue.assertValues([])
    self.setBadgeValueAtIndexIndex.assertValues([])

    withEnvironment(application: mockApplication) {
      self.vm.inputs.viewDidLoad()

      self.setBadgeValueAtIndexValue.assertValues(["99+"])
      self.setBadgeValueAtIndexIndex.assertValues([1])
    }
  }

  func testSetBadgeValueAtIndex_AppWillEnterForeground() {
    let mockApplication = MockApplication()
    mockApplication.applicationIconBadgeNumber = 100

    self.setBadgeValueAtIndexValue.assertValues([])
    self.setBadgeValueAtIndexIndex.assertValues([])

    withEnvironment(application: mockApplication) {
      self.vm.inputs.viewDidLoad()

      self.setBadgeValueAtIndexValue.assertValues(["99+"])
      self.setBadgeValueAtIndexIndex.assertValues([1])
    }

    mockApplication.applicationIconBadgeNumber = 50

    withEnvironment(application: mockApplication) {
      self.vm.inputs.applicationWillEnterForeground()

      self.setBadgeValueAtIndexValue.assertValues(["99+", "50"])
      self.setBadgeValueAtIndexIndex.assertValues([1, 1])
    }
  }

  func testClearBadgeValueOnActivitiesTabSelected() {
    let mockApplication = MockApplication()
    mockApplication.applicationIconBadgeNumber = 100

    self.setBadgeValueAtIndexValue.assertValues([])
    self.setBadgeValueAtIndexIndex.assertValues([])

    withEnvironment(application: mockApplication) {
      self.vm.inputs.viewDidLoad()

      self.setBadgeValueAtIndexValue.assertValues(["99+"])
      self.setBadgeValueAtIndexIndex.assertValues([1])

      self.vm.inputs.didSelect(index: 1)

      self.setBadgeValueAtIndexValue.assertValues(["99+", nil])
      self.setBadgeValueAtIndexIndex.assertValues([1, 1])
    }
  }

  func testSetBadgeValueAtIndex_UserSessionStarted_Ended() {
    let mockApplication = MockApplication()
    mockApplication.applicationIconBadgeNumber = 0

    self.setBadgeValueAtIndexValue.assertValues([])
    self.setBadgeValueAtIndexIndex.assertValues([])

    withEnvironment(application: mockApplication) {
      self.vm.inputs.viewDidLoad()

      self.setBadgeValueAtIndexValue.assertValues([nil])
      self.setBadgeValueAtIndexIndex.assertValues([1])
    }

    let user = .template
      |> User.lens.unseenActivityCount .~ 50

    withEnvironment(application: mockApplication) {
      AppEnvironment.login(.init(accessToken: "deadbeef", user: user))
      self.vm.inputs.userSessionStarted()

      self.setBadgeValueAtIndexValue.assertValues([nil, "50"])
      self.setBadgeValueAtIndexIndex.assertValues([1, 1])

      AppEnvironment.logout()

      self.vm.inputs.userSessionEnded()

      self.setBadgeValueAtIndexValue.assertValues([nil, "50", nil])
      self.setBadgeValueAtIndexIndex.assertValues([1, 1, 1])
    }
  }

  func testSetBadgeValueAtIndex_FromNotification() {
    let mockApplication = MockApplication()
    mockApplication.applicationIconBadgeNumber = 100

    self.setBadgeValueAtIndexValue.assertValues([])
    self.setBadgeValueAtIndexIndex.assertValues([])

    withEnvironment(application: mockApplication) {
      self.vm.inputs.viewDidLoad()

      self.setBadgeValueAtIndexValue.assertValues(["99+"])
      self.setBadgeValueAtIndexIndex.assertValues([1])

      self.vm.inputs.didReceiveBadgeValue(10)

      self.setBadgeValueAtIndexValue.assertValues(["99+", "10"])
      self.setBadgeValueAtIndexIndex.assertValues([1, 1])

      self.vm.inputs.didReceiveBadgeValue(0)

      self.setBadgeValueAtIndexValue.assertValues(["99+", "10", nil])
      self.setBadgeValueAtIndexIndex.assertValues([1, 1, 1])
    }
  }

  func testSetViewControllers() {
    let viewControllerNames = TestObserver<[String], Never>()
    vm.outputs.setViewControllers.map(extractRootNames)
      .observe(viewControllerNames.observer)

    self.vm.inputs.viewDidLoad()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Activities", "Search", "LoginTout"]
      ],
      "Show the logged out tabs."
    )

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
    self.vm.inputs.userSessionStarted()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Activities", "Search", "LoginTout"],
        ["Discovery", "Activities", "Search", "BackerDashboard"]
      ],
      "Show the logged in tabs."
    )

    AppEnvironment.updateCurrentUser(.template |> \.stats.memberProjectsCount .~ 1)
    self.vm.inputs.currentUserUpdated()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Activities", "Search", "LoginTout"],
        ["Discovery", "Activities", "Search", "BackerDashboard"],
        ["Discovery", "Activities", "Search", "Dashboard", "BackerDashboard"]
      ],
      "Show the creator dashboard tab."
    )

    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()

    viewControllerNames.assertValues(
      [
        ["Discovery", "Activities", "Search", "LoginTout"],
        ["Discovery", "Activities", "Search", "BackerDashboard"],
        ["Discovery", "Activities", "Search", "Dashboard", "BackerDashboard"],
        ["Discovery", "Activities", "Search", "LoginTout"]
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

      AppEnvironment.updateCurrentUser(.template |> \.stats.memberProjectsCount .~ 1)
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
    let viewControllerNames = TestObserver<[String], Never>()
    vm.outputs.setViewControllers.map(extractRootNames)
      .observe(viewControllerNames.observer)

    self.vm.inputs.viewDidLoad()

    self.viewControllerNames.assertValueCount(1)

    self.vm.inputs.currentUserUpdated()

    self.viewControllerNames.assertValueCount(1)
  }

  func testUpdateUserLocalePreferences() {
    let viewControllerNames = TestObserver<[String], Never>()
    vm.outputs.setViewControllers.map(extractRootNames)
      .observe(viewControllerNames.observer)

    self.vm.inputs.viewDidLoad()

    self.viewControllerNames.assertValueCount(1)
    self.tabBarItemsData.assertValueCount(1)

    self.vm.inputs.userLocalePreferencesChanged()

    self.viewControllerNames.assertValueCount(2)
    self.tabBarItemsData.assertValueCount(2)
  }

  func testSelectedIndex() {
    self.selectedIndex.assertValues([], "No index seleted before view loads.")

    self.vm.inputs.viewDidLoad()

    self.selectedIndex.assertValues([0], "Default index selected immediately.")

    self.vm.inputs.didSelect(index: 1)

    self.selectedIndex.assertValues([0, 1], "Selects index immediately.")

    self.vm.inputs.didSelect(index: 0)

    self.selectedIndex.assertValues([0, 1, 0], "Selects index immediately.")

    self.vm.inputs.didSelect(index: 10)

    self.selectedIndex.assertValues([0, 1, 0, 3], "Selects index immediately.")
  }

  func testScrollToTop() {
    self.scrollToTopControllerName.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.scrollToTopControllerName.assertDidNotEmitValue()

    self.vm.inputs.shouldSelect(index: 1)
    self.vm.inputs.didSelect(index: 1)

    self.scrollToTopControllerName.assertDidNotEmitValue("Selecting index doesn't cause scroll to top.")

    self.vm.inputs.shouldSelect(index: 0)
    self.vm.inputs.didSelect(index: 0)

    self.scrollToTopControllerName.assertDidNotEmitValue(
      "Selecting different index doesn't cause scroll to top."
    )

    self.vm.inputs.shouldSelect(index: 0)
    self.vm.inputs.didSelect(index: 0)

    self.scrollToTopControllerName.assertValues(
      ["Discovery"],
      "Selecting same index again causes scroll to top."
    )
  }

  func testSwitchingTabs() {
    self.vm.inputs.viewDidLoad()
    self.selectedIndex.assertValues([0])
    self.vm.inputs.switchToDiscovery(params: nil)
    self.selectedIndex.assertValues([0, 0])
    self.vm.inputs.switchToActivities()
    self.selectedIndex.assertValues([0, 0, 1])
    self.vm.inputs.switchToSearch()
    self.selectedIndex.assertValues([0, 0, 1, 2])
    self.vm.inputs.switchToProfile()
    self.selectedIndex.assertValues([0, 0, 1, 2])
    self.vm.inputs.switchToLogin()
    self.selectedIndex.assertValues([0, 0, 1, 2, 3])

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
    self.vm.inputs.userSessionStarted()

    self.selectedIndex.assertValues([0, 0, 1, 2, 3, 3])
    self.vm.inputs.switchToProfile()
    self.selectedIndex.assertValues([0, 0, 1, 2, 3, 3, 3])
    self.vm.inputs.switchToLogin()
    self.selectedIndex.assertValues([0, 0, 1, 2, 3, 3, 3])
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

    AppEnvironment.login(AccessTokenEnvelope(
      accessToken: "deadbeef", user: .template
        |> \.stats.memberProjectsCount .~ 1
    ))
    self.vm.inputs.userSessionStarted()

    self.switchDashboardProject.assertValues([])
    self.vm.inputs.switchToDashboard(project: param)
    self.switchDashboardProject.assertValues([param])
  }

  func testTabBarItemStyles() {
    let user = User.template |> \.avatar.small .~ "http://image.com/image"
    let creator = User.template
      |> \.stats.memberProjectsCount .~ 1
      |> \.avatar.small .~ "http://image.com/image2"

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

    let viewControllerNames = TestObserver<[String], Never>()
    vm.outputs.setViewControllers.map(extractRootNames)
      .observe(viewControllerNames.observer)

    self.vm.inputs.viewDidLoad()

    let params = DiscoveryParams.defaults
    self.vm.inputs.switchToDiscovery(params: params)
    self.filterDiscovery.assertValues([params])

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
    self.vm.inputs.userSessionStarted()

    AppEnvironment.updateCurrentUser(.template |> \.stats.memberProjectsCount .~ 1)
    self.vm.inputs.currentUserUpdated()

    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()

    self.viewControllerNames.assertValueCount(4)
    self.filterDiscovery.assertValues([params])
  }
}

private func extractRootNames(_ vcs: [RootViewControllerData]) -> [String] {
  return vcs
    .map { $0.viewController }
    .compact()
    .map(UINavigationController.init(rootViewController:))
    .compactMap(extractRootName)
}

private func extractRootName(_ vc: UIViewController) -> String? {
  return (vc as? UINavigationController)?
    .viewControllers
    .first
    .map(extractName)
}

private func extractName(_ vc: UIViewController) -> String {
  return "\(type(of: vc))".replacingOccurrences(of: "ViewController", with: "")
}
