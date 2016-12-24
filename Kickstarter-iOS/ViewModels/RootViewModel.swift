import Library
import KsApi
import Prelude
import ReactiveSwift
import Result
import UIKit

internal struct TabBarItemsData {
  internal let items: [TabBarItem]
  internal let isLoggedIn: Bool
  internal let isMember: Bool
}

internal enum TabBarItem {
  case activity(index: Int)
  case dashboard(index: Int)
  case home(index: Int)
  case profile(avatarUrl: URL?, index: Int)
  case search(index: Int)
}

internal protocol RootViewModelInputs {
  /// Call when the controller has received a user updated notification.
  func currentUserUpdated()

  /// Call when selected tab bar index changes.
  func didSelectIndex(_ index: Int)

  /// Call when we should switch to the activities tab.
  func switchToActivities()

  /// Call when we should switch to the creator dashboard tab.
  func switchToDashboard(project param: Param?)

  /// Call when we should switch to the discovery tab.
  func switchToDiscovery(params: DiscoveryParams?)

  /// Call when we should switch to the login tab.
  func switchToLogin()

  /// Call when we should switch to the profile tab.
  func switchToProfile()

  /// Call when we should switch to the search tab.
  func switchToSearch()

  /// Call when the controller has received a user session ended notification.
  func userSessionEnded()

  /// Call when the controller has received a user session started notification.
  func userSessionStarted()

  /// Call from the controller's `viewDidLoad` method.
  func viewDidLoad()
}

internal protocol RootViewModelOutputs {
  /// Emits when the discovery VC should filter with specific params.
  var filterDiscovery: Signal<(DiscoveryViewController, DiscoveryParams), NoError> { get }

  /// Emits a controller that should be scrolled to the top. This requires figuring out what kind of
  /// controller it is, and setting its `contentOffset`.
  var scrollToTop: Signal<UIViewController, NoError> { get }

  /// Emits an index that the tab bar should be switched to.
  var selectedIndex: Signal<Int, NoError> { get }

  /// Emits the array of view controllers that should be set on the tab bar.
  var setViewControllers: Signal<[UIViewController], NoError> { get }

  /// Emits when the dashboard should switch projects.
  var switchDashboardProject: Signal<(DashboardViewController, Param), NoError> { get }

  /// Emits data for setting tab bar item styles.
  var tabBarItemsData: Signal<TabBarItemsData, NoError> { get }
}

internal protocol RootViewModelType {
  var inputs: RootViewModelInputs { get }
  var outputs: RootViewModelOutputs { get }
}

internal final class RootViewModel: RootViewModelType, RootViewModelInputs, RootViewModelOutputs {

  // swiftlint:disable function_body_length
  internal init() {
    let currentUser = Signal.merge(
      self.viewDidLoadProperty.signal,
      self.userSessionStartedProperty.signal,
      self.userSessionEndedProperty.signal,
      self.currentUserUpdatedProperty.signal
      )
      .map { AppEnvironment.current.currentUser }

    let userState: Signal<(isLoggedIn: Bool, isMember: Bool), NoError> = currentUser
      .map { ($0 != nil, ($0?.stats.memberProjectsCount ?? 0) > 0) }
      .skipRepeats(==)

    let standardViewControllers = self.viewDidLoadProperty.signal
      .map { _ in
        [
          DiscoveryViewController.instantiate(),
          ActivitiesViewController.instantiate(),
          SearchViewController.instantiate()
        ]
      }

    let personalizedViewControllers = userState
      .map { user in
        [
          user.isMember    ? DashboardViewController.instantiate() as UIViewController? : nil,
          !user.isLoggedIn
            ? LoginToutViewController.configuredWith(loginIntent: .generic) as UIViewController? : nil,
          user.isLoggedIn  ? ProfileViewController.instantiate() as UIViewController? : nil
        ]
      }
      .map { $0.compact() }

    let viewControllers = combineLatest(standardViewControllers, personalizedViewControllers).map(+)

    self.setViewControllers = viewControllers
      .map { $0.map(UINavigationController.init(rootViewController:)) }

    let loginState = userState.map { $0.isLoggedIn }
    let vcCount = self.setViewControllers.map { $0.count }

    let switchToLogin = combineLatest(vcCount, loginState)
      .takeWhen(self.switchToLoginProperty.signal)
      .filter { isFalse($1) }
      .map(first)

    let switchToProfile = combineLatest(vcCount, loginState)
      .takeWhen(self.switchToProfileProperty.signal)
      .filter { isTrue($1) }
      .map(first)

    let discovery = viewControllers
      .map(first(DiscoveryViewController))
      .skipNil()

    self.filterDiscovery =
      combineLatest(discovery, self.switchToDiscoveryProperty.signal.skipNil())

    let dashboard = viewControllers
      .map(first(DashboardViewController))
      .skipNil()

    self.switchDashboardProject =
      combineLatest(dashboard, self.switchToDashboardProperty.signal.skipNil(),
        loginState)
        .filter { _, _, loginState in
          isTrue(loginState)
        }
        .map { dashboard, param, _ in
          (dashboard, param)
    }

    self.selectedIndex =
      combineLatest(
        .merge(
          self.didSelectIndexProperty.signal,
          self.switchToActivitiesProperty.signal.mapConst(1),
          self.switchToDiscoveryProperty.signal.mapConst(0),
          self.switchToSearchProperty.signal.mapConst(2),
          switchToLogin,
          switchToProfile,
          self.switchToDashboardProperty.signal.mapConst(3)
        ),
        self.setViewControllers,
        self.viewDidLoadProperty.signal)
        .map { idx, vcs, _ in clamp(0, vcs.count - 1)(idx) }

    let selectedTabAgain = self.selectedIndex.combinePrevious()
      .map { prev, next -> Int? in prev == next ? next : nil }
      .skipNil()

    self.scrollToTop = self.setViewControllers
      .takePairWhen(selectedTabAgain)
      .map { vcs, idx in vcs[idx] }

    self.tabBarItemsData = combineLatest(currentUser, self.viewDidLoadProperty.signal)
      .map(first)
      .map(tabData(forUser:))
  }
  // swiftlint:enable function_body_length

  fileprivate let currentUserUpdatedProperty = MutableProperty(())
  internal func currentUserUpdated() {
    self.currentUserUpdatedProperty.value = ()
  }
  fileprivate let didSelectIndexProperty = MutableProperty(0)
  internal func didSelectIndex(_ index: Int) {
    self.didSelectIndexProperty.value = index
  }
  fileprivate let switchToActivitiesProperty = MutableProperty()
  internal func switchToActivities() {
    self.switchToActivitiesProperty.value = ()
  }
  fileprivate let switchToDashboardProperty = MutableProperty<Param?>(nil)
  internal func switchToDashboard(project param: Param?) {
    self.switchToDashboardProperty.value = param
  }
  fileprivate let switchToDiscoveryProperty = MutableProperty<DiscoveryParams?>(nil)
  internal func switchToDiscovery(params: DiscoveryParams?) {
    self.switchToDiscoveryProperty.value = params
  }
  fileprivate let switchToLoginProperty = MutableProperty()
  internal func switchToLogin() {
    self.switchToLoginProperty.value = ()
  }
  fileprivate let switchToProfileProperty = MutableProperty()
  internal func switchToProfile() {
    self.switchToProfileProperty.value = ()
  }
  fileprivate let switchToSearchProperty = MutableProperty()
  internal func switchToSearch() {
    self.switchToSearchProperty.value = ()
  }
  fileprivate let userSessionStartedProperty = MutableProperty<()>()
  internal func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  fileprivate let userSessionEndedProperty = MutableProperty<()>()
  internal func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty<()>()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  internal let filterDiscovery: Signal<(DiscoveryViewController, DiscoveryParams), NoError>
  internal let scrollToTop: Signal<UIViewController, NoError>
  internal let selectedIndex: Signal<Int, NoError>
  internal let setViewControllers: Signal<[UIViewController], NoError>
  internal let switchDashboardProject: Signal<(DashboardViewController, Param), NoError>
  internal let tabBarItemsData: Signal<TabBarItemsData, NoError>

  internal var inputs: RootViewModelInputs { return self }
  internal var outputs: RootViewModelOutputs { return self }
}

private func tabData(forUser user: User?) -> TabBarItemsData {
  let isMember = (user?.stats.memberProjectsCount ?? 0) > 0

  let items: [TabBarItem] = isMember
    ? [.home(index: 0), .activity(index: 1), .search(index: 2), .dashboard(index: 3),
       .profile(avatarUrl: (user?.avatar.small).flatMap(URL.init(string:)), index: 4)]
    : [.home(index: 0), .activity(index: 1), .search(index: 2),
       .profile(avatarUrl: (user?.avatar.small).flatMap(URL.init(string:)), index: 3)]

  return TabBarItemsData(items: items,
                         isLoggedIn: user != nil,
                         isMember: isMember)
}

extension TabBarItemsData: Equatable {}
func == (lhs: TabBarItemsData, rhs: TabBarItemsData) -> Bool {
  return lhs.items == rhs.items &&
         lhs.isLoggedIn == rhs.isLoggedIn &&
         lhs.isMember == rhs.isMember
}

// swiftlint:disable cyclomatic_complexity
extension TabBarItem: Equatable {}
func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
  switch (lhs, rhs) {
  case let (.activity(lhs), .activity(rhs)):
    return lhs == rhs
  case let (.dashboard(lhs), .dashboard(rhs)):
    return lhs == rhs
  case let (.home(lhs), .home(rhs)):
    return lhs == rhs
  case let (.profile(lhs), .profile(rhs)):
    return lhs.avatarUrl == rhs.avatarUrl && lhs.index == rhs.index
  case let (.search(lhs), .search(rhs)):
    return lhs == rhs
  default: return false
  }
}
// swiftlint:enable cyclomatic_complexity

private func first<VC: UIViewController>(_ viewController: VC.Type) -> ([UIViewController]) -> VC? {

  return { viewControllers in
    viewControllers
      .index { $0 is VC }
      .flatMap { viewControllers[$0] as? VC }
  }
}
