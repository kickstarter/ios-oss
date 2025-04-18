import KsApi
import Prelude
import ReactiveSwift
import UIKit

public typealias RootViewControllerIndex = Int
public typealias RootTabBarItemBadgeValueData = (String?, RootViewControllerIndex)

public enum RootViewControllerData: Equatable {
  case discovery
  case activities
  case pledgedProjectsAndActivities
  case search
  case profile(isLoggedIn: Bool)

  public static func == (lhs: RootViewControllerData, rhs: RootViewControllerData) -> Bool {
    switch (lhs, rhs) {
    case (.discovery, .discovery): return true
    case (.activities, .activities): return true
    case (.pledgedProjectsAndActivities, .pledgedProjectsAndActivities): return true
    case (.search, .search): return true
    case let (.profile(lhsIsLoggedIn), .profile(rhsIsLoggedIn)):
      return lhsIsLoggedIn == rhsIsLoggedIn
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

  var isActivity: Bool {
    switch self {
    case .activities, .pledgedProjectsAndActivities:
      return true
    case .discovery, .profile, .search:
      return false
    }
  }
}

public struct TabBarItemsData {
  public let items: [TabBarItem]
  public let isLoggedIn: Bool
}

public enum TabBarItem {
  case activity(index: RootViewControllerIndex)
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

  /// Call when we should switch to the discovery tab.
  func switchToDiscovery(params: DiscoveryParams?)

  /// Call when we should switch to the login tab.
  func switchToLogin()

  /// Call when we should switch to the profile tab.
  func switchToProfile()

  /// Call when we should switch to the search tab.
  func switchToSearch()

  /// Call when the a user locale preference has changed.
  /// Used to blow away and re-generate all the tabs, so the entire app reflects changes in user language or currency.
  /// See PR #576.
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
    .map { _ in AppEnvironment.current.currentUser }

    let loginState: Signal<Bool, Never> = currentUser
      .map {
        $0 != nil
      }
      .skipRepeats(==)

    let lifecycleEvents = Signal.merge(
      self.viewDidLoadProperty.signal,
      self.applicationWillEnterForegroundSignal
    )

    let standardViewControllers = loginState.map { isLoggedIn -> [RootViewControllerData] in
      generateViewControllers(isLoggedIn: isLoggedIn)
    }

    // We could detect when this feature changes in more places - like listening for notifications
    // that the remote config loaded - but that might change the tab bar at a strange time.
    // Updating this just on app foreground keeps the change invisible to the user.
    // Conveniently, the activity badge is also updated on app foreground.
    let featuredFlagChanged =
      Signal.merge(
        self.viewDidLoadProperty.signal,
        self.applicationWillEnterForegroundSignal.signal
      )
      // Currently we have no tabs that reload based on feature flags -
      // but if we need that feature again, this is where you put it.
      //  .map { _ in myFeatureFlagEnabled()}
      .map { _ in false }
      .skipRepeats()
      .skip(first: 1) // Only fire if applicationWillEnterForeground changes the original values in viewDidLoadProperty.

    self.setViewControllers = Signal.merge(
      standardViewControllers,
      // FIXME: Look at moving the userLocalePreferencesChangedProperty signal into the currentUser signal
      // https://kickstarter.atlassian.net/browse/MBL-2053
      loginState.takeWhen(
        Signal.merge(
          self.userLocalePreferencesChangedProperty.signal,
          featuredFlagChanged.ignoreValues()
        )
      )
      .map { isLoggedIn in
        generateViewControllers(isLoggedIn: isLoggedIn)
      }
    )

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

    self.selectedIndex = Signal.combineLatest(
      .merge(
        self.viewDidLoadProperty.signal.mapConst(0),
        self.didSelectIndexProperty.signal,
        self.switchToActivitiesProperty.signal.mapConst(1),
        self.switchToDiscoveryProperty.signal.mapConst(0),
        self.switchToSearchProperty.signal.mapConst(2),
        switchToLogin,
        switchToProfile
      ),
      self.setViewControllers,
      self.viewDidLoadProperty.signal
    )
    .map { idx, vcs, _ in clamp(0, vcs.count - 1)(idx) }

    let activityViewControllerIndex = self.setViewControllers
      .map { $0.firstIndex(where: \.isActivity) }
      .skipNil()
      .map { $0 as RootViewControllerIndex }

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
    .map { value, index in
      let hasPPOAction = AppEnvironment.current.currentUserPPOSettings?.hasAction ?? false
      return (activitiesBadgeValue(with: value, hasPPOAction: hasPPOAction), index)
    }

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

    // FIXME: This signal always needs to happen when setViewControllers happens.
    // Should they be combined into one signal with a tuple? Explicitly made dependent on one another?
    // See https://kickstarter.atlassian.net/browse/MBL-2053
    self.tabBarItemsData = Signal.combineLatest(
      currentUser, .merge(
        self.viewDidLoadProperty.signal,
        self.userLocalePreferencesChangedProperty.signal,
        featuredFlagChanged.ignoreValues()
      )
    )
    .map(first)
    .map(tabData(forUser:))

    // Tracks

    let prevSelectedIndex = self.didSelectIndexProperty
      .signal
      .combinePrevious(0)
      .map(first)

    let prevSelectedTabBarItem = Signal
      .combineLatest(prevSelectedIndex, self.tabBarItemsData)
      .map { index, data -> KSRAnalytics.TabBarItemLabel in
        guard index < data.items.count else { return tabBarItemLabel(for: data.items[0]) }

        return tabBarItemLabel(for: data.items[index])
      }

    let searchTabBarSelected = Signal
      .combineLatest(self.didSelectIndexProperty.signal, self.tabBarItemsData)
      .filter { index, data in index < data.items.count }
      .map { index, data in
        tabBarItemLabel(for: data.items[index])
      }
      .filter { $0 == .search }

    prevSelectedTabBarItem
      .takeWhen(searchTabBarSelected)
      .skipRepeats(==)
      .observeValues { tabBarLabel in
        AppEnvironment.current.ksrAnalytics
          .trackSearchTabBarClicked(prevTabBarItemLabel: tabBarLabel)
      }

    self.tabBarItemsData
      .combineLatest(with: prevSelectedTabBarItem.signal)
      .takePairWhen(self.didSelectIndexProperty.signal)
      .compactMap { dataAndPrevSelectedTabBarItem, index in
        let (data, prevSelectedTabBarItem) = dataAndPrevSelectedTabBarItem
        guard index < data.items.count else { return nil }

        return (tabBarItemLabel(for: data.items[index]), prevSelectedTabBarItem)
      }
      .observeValues { tabBarItemLabel, prevTabBarItemLabel in
        AppEnvironment.current.ksrAnalytics
          .trackTabBarClicked(
            tabBarItemLabel: tabBarItemLabel,
            previousTabBarItemLabel: prevTabBarItemLabel
          )
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
  public let tabBarItemsData: Signal<TabBarItemsData, Never>
  public let updateUserInEnvironment: Signal<User, Never>

  public var inputs: RootViewModelInputs { return self }
  public var outputs: RootViewModelOutputs { return self }
}

private func currentUserActivitiesAndErroredPledgeCount() -> Int {
  return (AppEnvironment.current.currentUser?.unseenActivityCount ?? 0)
}

private func generateViewControllers(isLoggedIn: Bool) -> [RootViewControllerData] {
  var controllers: [RootViewControllerData] = []
  controllers.append(.discovery)

  if isLoggedIn {
    controllers.append(.pledgedProjectsAndActivities)
  } else {
    controllers.append(.activities)
  }

  controllers.append(.search)
  controllers.append(.profile(isLoggedIn: isLoggedIn))

  return controllers
}

private func tabData(forUser user: User?) -> TabBarItemsData {
  let items: [TabBarItem] = [
    .home(index: 0), .activity(index: 1), .search(index: 2),
    .profile(avatarUrl: (user?.avatar.small).flatMap(URL.init(string:)), index: 3)
  ]

  return TabBarItemsData(
    items: items,
    isLoggedIn: user != nil
  )
}

extension TabBarItemsData: Equatable {}
extension TabBarItem: Equatable {}

private func activitiesBadgeValue(with value: Int?, hasPPOAction: Bool) -> String? {
  guard !hasPPOAction else {
    // an empty string will show a dot as badge
    return ""
  }

  let isVoiceOverRunning = AppEnvironment.current.isVoiceOverRunning()
  let badgeValue = value ?? 0
  let maxBadgeValue = !isVoiceOverRunning ? 99 : badgeValue
  let clampedBadgeValue = min(badgeValue, maxBadgeValue)

  guard clampedBadgeValue > 0 else { return nil }

  return (badgeValue > maxBadgeValue) && !isVoiceOverRunning
    ? Strings.activities_badge_value_plus(activities_badge_value: "\(clampedBadgeValue)")
    : "\(clampedBadgeValue)"
}

private func tabBarItemLabel(for tabBarItem: TabBarItem) -> KSRAnalytics.TabBarItemLabel {
  switch tabBarItem {
  case .activity:
    return .activity
  case .home:
    return .discovery
  case .profile:
    return .profile
  case .search:
    return .search
  }
}
