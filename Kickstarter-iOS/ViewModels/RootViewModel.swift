import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

typealias RootViewControllerIndex = Int

internal enum RootViewControllerData: Equatable {
  case discovery
  case activities
  case search
  case dashboard(isMember: Bool)
  case profile(isLoggedIn: Bool)

  var viewController: UIViewController? {
    switch self {
    case .discovery:
      return DiscoveryViewController.instantiate()
    case .activities:
      return ActivitiesViewController.instantiate()
    case .search:
      return SearchViewController.instantiate()
    case let .dashboard(isMember):
      return isMember ? DashboardViewController.instantiate() : nil
    case let .profile(isLoggedIn):
      return isLoggedIn
        ? BackerDashboardViewController.instantiate()
        : LoginToutViewController.configuredWith(loginIntent: .generic)
    }
  }

  var isNil: Bool {
    switch self {
    case let .dashboard(isMember):
      return !isMember
    default:
      return false
    }
  }

  var isDashboard: Bool {
    switch self {
    case .dashboard:
      return true
    default:
      return false
    }
  }

  var isProfile: Bool {
    switch self {
    case .profile:
      return true
    default:
      return false
    }
  }
}

internal struct TabBarItemsData: Equatable {
  internal let items: [TabBarItem]
  internal let isLoggedIn: Bool
  internal let isMember: Bool
}

internal enum TabBarItem: Equatable {
  case activity(index: RootViewControllerIndex)
  case dashboard(index: RootViewControllerIndex)
  case home(index: RootViewControllerIndex)
  case profile(avatarUrl: URL?, index: RootViewControllerIndex)
  case search(index: RootViewControllerIndex)
}

internal protocol RootViewModelInputs {
  /// Call when the controller has received a user updated notification.
  func currentUserUpdated()

  /// Call before selected tab bar index changes.
  func shouldSelect(index: RootViewControllerIndex?)

  /// Call when selected tab bar index changes.
  func didSelect(index: RootViewControllerIndex)

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

  /// Call when the a user locale preference has changed
  func userLocalePreferencesChanged()

  /// Call when the controller has received a user session ended notification.
  func userSessionEnded()

  /// Call when the controller has received a user session started notification.
  func userSessionStarted()

  /// Call from the controller's `viewDidLoad` method.
  func viewDidLoad()
}

internal protocol RootViewModelOutputs {
  /// Emits when the discovery VC should filter with specific params.
  var filterDiscovery: Signal<(RootViewControllerIndex, DiscoveryParams), Never> { get }

  /// Emits a controller index that should be scrolled to the top. This requires figuring out what kind of
  /// controller it is, and setting its `contentOffset`.
  var scrollToTop: Signal<RootViewControllerIndex, Never> { get }

  /// Emits an index that the tab bar should be switched to.
  var selectedIndex: Signal<RootViewControllerIndex, Never> { get }

  /// Emits the array of view controllers that should be set on the tab bar.
  var setViewControllers: Signal<[RootViewControllerData], Never> { get }

  /// Emits when the dashboard should switch projects.
  var switchDashboardProject: Signal<(RootViewControllerIndex, Param), Never> { get }

  /// Emits data for setting tab bar item styles.
  var tabBarItemsData: Signal<TabBarItemsData, Never> { get }
}

internal protocol RootViewModelType {
  var inputs: RootViewModelInputs { get }
  var outputs: RootViewModelOutputs { get }
}

internal final class RootViewModel: RootViewModelType, RootViewModelInputs, RootViewModelOutputs {
  internal init() {
    let currentUser = Signal.merge(
      self.viewDidLoadProperty.signal,
      self.userSessionStartedProperty.signal,
      self.userSessionEndedProperty.signal,
      self.currentUserUpdatedProperty.signal
    )
    .map { AppEnvironment.current.currentUser }

    let userState: Signal<(isLoggedIn: Bool, isMember: Bool), Never> = currentUser
      .map { ($0 != nil, ($0?.stats.memberProjectsCount ?? 0) > 0) }
      .skipRepeats(==)

    let standardViewControllers = self.viewDidLoadProperty.signal.map { generateStandardViewControllers() }
    let personalizedViewControllers = userState.map { generatePersonalizedViewControllers(userState: $0) }

    let viewControllers = Signal.combineLatest(standardViewControllers, personalizedViewControllers).map(+)

    let refreshedViewControllers = userState.takeWhen(self.userLocalePreferencesChangedProperty.signal)
      .map { userState -> [RootViewControllerData] in
        let standard = generateStandardViewControllers()
        let personalized = generatePersonalizedViewControllers(userState: userState)

        return standard + personalized
      }

    self.setViewControllers = Signal.merge(
      viewControllers,
      refreshedViewControllers
    )
    .map { $0.filter { !$0.isNil } }

    let loginState = userState.map { $0.isLoggedIn }
    let vcCount = self.setViewControllers.map { $0.count }

    let switchToLogin = Signal.combineLatest(vcCount, loginState)
      .takeWhen(self.switchToLoginProperty.signal)
      .filter(second >>> isFalse)
      .map(first)

    let switchToProfile = Signal.combineLatest(vcCount, loginState)
      .takeWhen(self.switchToProfileProperty.signal)
      .filter { isTrue($1) }
      .map(first)

    let discoveryControllerIndex = self.setViewControllers
      .map { $0.firstIndex(of: .discovery) }
      .skipNil()

    self.filterDiscovery = discoveryControllerIndex
      .takePairWhen(self.switchToDiscoveryProperty.signal.skipNil())

    let dashboardControllerIndex = self.setViewControllers
      .map { $0.firstIndex(where: { $0.isDashboard }) }
      .skipNil()

    self.switchDashboardProject = Signal
      .combineLatest(dashboardControllerIndex, self.switchToDashboardProperty.signal.skipNil(), loginState)
      .filter { _, _, loginState in
        isTrue(loginState)
      }
      .map { dashboard, param, _ in
        (dashboard, param)
      }

    self.selectedIndex = Signal.combineLatest(
      .merge(
        self.viewDidLoadProperty.signal.mapConst(0),
        self.didSelectIndexProperty.signal,
        self.switchToActivitiesProperty.signal.mapConst(1),
        self.switchToDiscoveryProperty.signal.mapConst(0),
        self.switchToSearchProperty.signal.mapConst(2),
        switchToLogin,
        switchToProfile,
        self.switchToDashboardProperty.signal.mapConst(3)
      ),
      self.setViewControllers,
      self.viewDidLoadProperty.signal
    )
    .map { idx, vcs, _ in clamp(0, vcs.count - 1)(idx) }

    let shouldSelectIndex = self.shouldSelectIndexProperty.signal
      .skipNil()

    self.scrollToTop = self.selectedIndex
      .takePairWhen(shouldSelectIndex)
      .filter { prev, next in prev == next }
      .map { $1 }

    self.tabBarItemsData = Signal.combineLatest(
      currentUser, .merge(
        self.viewDidLoadProperty.signal,
        self.userLocalePreferencesChangedProperty.signal.ignoreValues()
      )
    )
    .map(first)
    .map(tabData(forUser:))
  }

  fileprivate let currentUserUpdatedProperty = MutableProperty(())
  internal func currentUserUpdated() {
    self.currentUserUpdatedProperty.value = ()
  }

  fileprivate let shouldSelectIndexProperty = MutableProperty<Int?>(nil)
  internal func shouldSelect(index: Int?) {
    self.shouldSelectIndexProperty.value = index
  }

  fileprivate let didSelectIndexProperty = MutableProperty(0)
  internal func didSelect(index: Int) {
    self.didSelectIndexProperty.value = index
  }

  fileprivate let switchToActivitiesProperty = MutableProperty(())
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

  fileprivate let switchToLoginProperty = MutableProperty(())
  internal func switchToLogin() {
    self.switchToLoginProperty.value = ()
  }

  fileprivate let switchToProfileProperty = MutableProperty(())
  internal func switchToProfile() {
    self.switchToProfileProperty.value = ()
  }

  fileprivate let switchToSearchProperty = MutableProperty(())
  internal func switchToSearch() {
    self.switchToSearchProperty.value = ()
  }

  fileprivate let userLocalePreferencesChangedProperty = MutableProperty(())
  internal func userLocalePreferencesChanged() {
    self.userLocalePreferencesChangedProperty.value = ()
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  internal func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let userSessionEndedProperty = MutableProperty(())
  internal func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  internal let filterDiscovery: Signal<(RootViewControllerIndex, DiscoveryParams), Never>
  internal let scrollToTop: Signal<RootViewControllerIndex, Never>
  internal let selectedIndex: Signal<RootViewControllerIndex, Never>
  internal let setViewControllers: Signal<[RootViewControllerData], Never>
  internal let switchDashboardProject: Signal<(Int, Param), Never>
  internal let tabBarItemsData: Signal<TabBarItemsData, Never>

  internal var inputs: RootViewModelInputs { return self }
  internal var outputs: RootViewModelOutputs { return self }
}

private func generateStandardViewControllers() -> [RootViewControllerData] {
  return [.discovery, .activities, .search]
}

private func generatePersonalizedViewControllers(userState: (isMember: Bool, isLoggedIn: Bool))
  -> [RootViewControllerData] {
  return [.dashboard(isMember: userState.isMember), .profile(isLoggedIn: userState.isLoggedIn)]
}

private func tabData(forUser user: User?) -> TabBarItemsData {
  let isMember = (user?.stats.memberProjectsCount ?? 0) > 0

  let items: [TabBarItem] = isMember
    ? [
      .home(index: 0), .activity(index: 1), .search(index: 2), .dashboard(index: 3),
      .profile(avatarUrl: (user?.avatar.small).flatMap(URL.init(string:)), index: 4)
    ]
    : [
      .home(index: 0), .activity(index: 1), .search(index: 2),
      .profile(avatarUrl: (user?.avatar.small).flatMap(URL.init(string:)), index: 3)
    ]

  return TabBarItemsData(
    items: items,
    isLoggedIn: user != nil,
    isMember: isMember
  )
}
