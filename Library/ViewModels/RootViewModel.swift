import KsApi
import Prelude
import ReactiveSwift
import UIKit

public typealias RootViewControllerIndex = Int
public typealias RootTabBarItemBadgeValueData = (String?, RootViewControllerIndex)

public enum RootViewControllerData: Equatable {
  case discovery
  case activities
  case search
  case dashboard(isMember: Bool)
  case profile(isLoggedIn: Bool)

  public static func == (lhs: RootViewControllerData, rhs: RootViewControllerData) -> Bool {
    switch (lhs, rhs) {
    case (.discovery, .discovery): return true
    case (.activities, .activities): return true
    case (.search, .search): return true
    case let (.dashboard(lhsIsMember), .dashboard(rhsIsMember)):
      return lhsIsMember == rhsIsMember
    case let (.profile(lhsIsLoggedIn), .profile(rhsIsLoggedIn)):
      return lhsIsLoggedIn == rhsIsLoggedIn
    default:
      return false
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

public struct TabBarItemsData {
  public let items: [TabBarItem]
  public let isLoggedIn: Bool
  public let isMember: Bool
}

public enum TabBarItem {
  case activity(index: RootViewControllerIndex)
  case dashboard(index: RootViewControllerIndex)
  case home(index: RootViewControllerIndex)
  case profile(avatarUrl: URL?, index: RootViewControllerIndex)
  case search(index: RootViewControllerIndex)
}

public protocol RootViewModelInputs {
  /// Call when the application will enter foreground.
  func applicationWillEnterForeground()

  /// Call when the controller has received a user updated notification.
  func currentUserUpdated()

  /// Call when a badge value was received via push notification.
  func didReceiveBadgeValue(_ value: Int?)

  /// Call when selected tab bar index changes.
  func didSelect(index: RootViewControllerIndex)

  /// Call before selected tab bar index changes.
  func shouldSelect(index: RootViewControllerIndex?)

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

  /// Call when VoiceOver is enabled or disabled
  func voiceOverStatusDidChange()
}

public protocol RootViewModelOutputs {
  /// Emits when the discovery VC should filter with specific params.
  var filterDiscovery: Signal<(RootViewControllerIndex, DiscoveryParams), Never> { get }

  /// Emits a controller index that should be scrolled to the top. This requires figuring out what kind of
  /// controller it is, and setting its `contentOffset`.
  var scrollToTop: Signal<RootViewControllerIndex, Never> { get }

  /// Emits an index that the tab bar should be switched to.
  var selectedIndex: Signal<RootViewControllerIndex, Never> { get }

  /// Emits the badge value to be set at a particular tab index
  var setBadgeValueAtIndex: Signal<RootTabBarItemBadgeValueData, Never> { get }

  /// Emits the array of view controllers that should be set on the tab bar.
  var setViewControllers: Signal<[RootViewControllerData], Never> { get }

  /// Emits when the dashboard should switch projects.
  var switchDashboardProject: Signal<(RootViewControllerIndex, Param), Never> { get }

  /// Emits data for setting tab bar item styles.
  var tabBarItemsData: Signal<TabBarItemsData, Never> { get }

  /// Emits a User that can be used to replace the current user in the environment.
  var updateUserInEnvironment: Signal<User, Never> { get }
}

public protocol RootViewModelType {
  var inputs: RootViewModelInputs { get }
  var outputs: RootViewModelOutputs { get }
}

public final class RootViewModel: RootViewModelType, RootViewModelInputs, RootViewModelOutputs {
  public init() {
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

    let activityViewControllerIndex = self.setViewControllers
      .map { $0.firstIndex(where: { $0 == .activities }) }
      .skipNil()
      .map { $0 as RootViewControllerIndex }

    let lifecycleEvents = Signal.merge(
      self.viewDidLoadProperty.signal,
      self.applicationWillEnterForegroundSignal
    )

    let updateBadgeValueOnLifecycleEvents = activityViewControllerIndex
      .takeWhen(lifecycleEvents)
      .map { index -> (Int?, RootViewControllerIndex) in
        (AppEnvironment.current.application.applicationIconBadgeNumber, index)
      }

    let selectedIndexAndActivityViewControllerIndex = Signal.combineLatest(
      self.selectedIndex,
      activityViewControllerIndex
    )

    let badgeValueOnUserUpdated = self.currentUserUpdatedProperty.signal
      .map { _ in currentUserActivitiesAndErroredPledgeCount() }
      .wrapInOptional()

    let updateBadgeValueFromNotification = selectedIndexAndActivityViewControllerIndex
      .takePairWhen(self.didReceiveBadgeValueSignal)

    let updateBadgeValueOnUserUpdated = selectedIndexAndActivityViewControllerIndex
      .takePairWhen(badgeValueOnUserUpdated)

    let updateBadgeValueOnUserUpdatedOrFromNotification = Signal.merge(
      updateBadgeValueOnUserUpdated,
      updateBadgeValueFromNotification
    )
    .map(unpack)
    .map { _, index, value in (value, index) }

    let clearBadgeValueOnUserSessionEnded = activityViewControllerIndex
      .takePairWhen(self.userSessionEndedProperty.signal)
      .map { index, _ -> (Int?, RootViewControllerIndex) in (nil, index) }

    let currentBadgeValue = MutableProperty<String?>(nil)

    let clearBadgeValueOnActivitiesTabSelected = selectedIndexAndActivityViewControllerIndex.filter(==)
      .flatMap { _, index in currentBadgeValue.producer.map { ($0, index) }.take(first: 1) }
      .filter { value, _ in value != nil }
      .map { _, index -> (Int?, RootViewControllerIndex) in
        (AppEnvironment.current.currentUser?.erroredBackingsCount, index)
      }

    let integerBadgeValueAndIndex = Signal.merge(
      updateBadgeValueOnLifecycleEvents,
      updateBadgeValueOnUserUpdatedOrFromNotification,
      clearBadgeValueOnUserSessionEnded,
      clearBadgeValueOnActivitiesTabSelected
    )

    self.setBadgeValueAtIndex = Signal.merge(
      integerBadgeValueAndIndex,
      integerBadgeValueAndIndex.takeWhen(self.voiceOverStatusDidChangeProperty.signal)
    )
    .map { value, index in (activitiesBadgeValue(with: value), index) }

    currentBadgeValue <~ self.setBadgeValueAtIndex.map { $0.0 }

    self.updateUserInEnvironment = clearBadgeValueOnActivitiesTabSelected
      .filter { _ in AppEnvironment.current.currentUser != nil }
      .switchMap { _ in
        updatedUserWithClearedActivityCountProducer()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
      }

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

    // MARK: - Koala

    self.tabBarItemsData
      .takePairWhen(self.didSelectIndexProperty.signal)
      .filterMap { data, index in
        guard index < data.items.count else { return nil }

        return tabBarItemLabel(for: data.items[index])
      }.observeValues { tabBarItemLabel in
        AppEnvironment.current.koala.trackTabBarClicked(tabBarItemLabel)
      }
  }

  private let (applicationWillEnterForegroundSignal, applicationWillEnterForegroundObserver)
    = Signal<(), Never>.pipe()
  public func applicationWillEnterForeground() {
    self.applicationWillEnterForegroundObserver.send(value: ())
  }

  fileprivate let currentUserUpdatedProperty = MutableProperty(())
  public func currentUserUpdated() {
    self.currentUserUpdatedProperty.value = ()
  }

  private let (didReceiveBadgeValueSignal, didReceiveBadgeValueObserver) = Signal<Int?, Never>.pipe()
  public func didReceiveBadgeValue(_ value: Int?) {
    self.didReceiveBadgeValueObserver.send(value: value)
  }

  fileprivate let didSelectIndexProperty = MutableProperty(0)
  public func didSelect(index: Int) {
    self.didSelectIndexProperty.value = index
  }

  fileprivate let shouldSelectIndexProperty = MutableProperty<Int?>(nil)
  public func shouldSelect(index: Int?) {
    self.shouldSelectIndexProperty.value = index
  }

  fileprivate let switchToActivitiesProperty = MutableProperty(())
  public func switchToActivities() {
    self.switchToActivitiesProperty.value = ()
  }

  fileprivate let switchToDashboardProperty = MutableProperty<Param?>(nil)
  public func switchToDashboard(project param: Param?) {
    self.switchToDashboardProperty.value = param
  }

  fileprivate let switchToDiscoveryProperty = MutableProperty<DiscoveryParams?>(nil)
  public func switchToDiscovery(params: DiscoveryParams?) {
    self.switchToDiscoveryProperty.value = params
  }

  fileprivate let switchToLoginProperty = MutableProperty(())
  public func switchToLogin() {
    self.switchToLoginProperty.value = ()
  }

  fileprivate let switchToProfileProperty = MutableProperty(())
  public func switchToProfile() {
    self.switchToProfileProperty.value = ()
  }

  fileprivate let switchToSearchProperty = MutableProperty(())
  public func switchToSearch() {
    self.switchToSearchProperty.value = ()
  }

  fileprivate let userLocalePreferencesChangedProperty = MutableProperty(())
  public func userLocalePreferencesChanged() {
    self.userLocalePreferencesChangedProperty.value = ()
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let userSessionEndedProperty = MutableProperty(())
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let voiceOverStatusDidChangeProperty = MutableProperty(())
  public func voiceOverStatusDidChange() {
    self.voiceOverStatusDidChangeProperty.value = ()
  }

  public let filterDiscovery: Signal<(RootViewControllerIndex, DiscoveryParams), Never>
  public let scrollToTop: Signal<RootViewControllerIndex, Never>
  public let selectedIndex: Signal<RootViewControllerIndex, Never>
  public let setBadgeValueAtIndex: Signal<RootTabBarItemBadgeValueData, Never>
  public let setViewControllers: Signal<[RootViewControllerData], Never>
  public let switchDashboardProject: Signal<(Int, Param), Never>
  public let tabBarItemsData: Signal<TabBarItemsData, Never>
  public let updateUserInEnvironment: Signal<User, Never>

  public var inputs: RootViewModelInputs { return self }
  public var outputs: RootViewModelOutputs { return self }
}

private func currentUserActivitiesAndErroredPledgeCount() -> Int {
  (AppEnvironment.current.currentUser?.unseenActivityCount ?? 0) +
    (AppEnvironment.current.currentUser?.erroredBackingsCount ?? 0)
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

extension TabBarItemsData: Equatable {}
extension TabBarItem: Equatable {}

private func activitiesBadgeValue(with value: Int?) -> String? {
  let isVoiceOverRunning = AppEnvironment.current.isVoiceOverRunning()
  let badgeValue = value ?? 0
  let maxBadgeValue = !isVoiceOverRunning ? 99 : badgeValue
  let clampedBadgeValue = min(badgeValue, maxBadgeValue)

  guard clampedBadgeValue > 0 else { return nil }

  return (badgeValue > maxBadgeValue) && !isVoiceOverRunning
    ? Strings.activities_badge_value_plus(activities_badge_value: "\(clampedBadgeValue)")
    : "\(clampedBadgeValue)"
}

private func tabBarItemLabel(for tabBarItem: TabBarItem) -> Koala.TabBarItemLabel {
  switch tabBarItem {
  case .activity:
    return .activity
  case .dashboard:
    return .dashboard
  case .home:
    return .discovery
  case .profile:
    return .profile
  case .search:
    return .search
  }
}
