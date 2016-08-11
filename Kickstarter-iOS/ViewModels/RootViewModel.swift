import Library
import Prelude
import ReactiveCocoa
import Result
import UIKit

internal struct ProfileTabBarItemData {
  internal let avatarUrl: NSURL?
  internal let isMember: Bool
  internal let item: TabBarItem
}

internal struct TabBarItemsData {
  internal let items: [TabBarItem]
  internal let isLoggedIn: Bool
  internal let isMember: Bool
}

internal enum TabBarItem {
  case activity(index: Int)
  case dashboard(index: Int)
  case home(index: Int)
  case profile(index: Int)
  case search(index: Int)
}

internal protocol RootViewModelInputs {
  /// Call when the controller has received a user updated notification.
  func currentUserUpdated()

  /// Call when selected tab bar index changes.
  func didSelectIndex(index: Int)

  /// Call when should switch to the activities tab.
  func switchToActivities()

  /// Call when it's wanted to switch to the discovery tab.
  func switchToDiscovery()

  /// Call when the controller has received a user session ended notification.
  func userSessionEnded()

  /// Call when the controller has received a user session started notification.
  func userSessionStarted()

  /// Call from the controller's `viewDidLoad` method.
  func viewDidLoad()
}

internal protocol RootViewModelOutputs {
  /// Emits profile tab bar item data to style it when a user logs in.
  var profileTabBarItemData: Signal<ProfileTabBarItemData, NoError> { get }

  /// Emits a controller that should be scrolled to the top. This requires figuring out what kind of
  // controller it is, and setting its `contentOffset`.
  var scrollToTop: Signal<UIViewController, NoError> { get }

  /// Emits an index that the tab bar should be switched to.
  var selectedIndex: Signal<Int, NoError> { get }

  /// Emits the array of view controllers that should be set on the tab bar.
  var setViewControllers: Signal<[UIViewController], NoError> { get }

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

    let standardTabs = self.viewDidLoadProperty.signal
      .take(1)
      .map { _ in
        [
          initialViewController(storyboardName: "Discovery"),
          initialViewController(storyboardName: "Activity"),
          initialViewController(storyboardName: "Search")
        ]
      }
      .map { $0.compact() }

    let personalizedTabs = userState
      .map { user -> [UIViewController?] in
        [
          user.isMember   ? initialViewController(storyboardName: "Dashboard") : nil,
          !user.isLoggedIn ? initialViewController(storyboardName: "Login") : nil,
          user.isLoggedIn  ? initialViewController(storyboardName: "Profile") : nil
        ]
      }
      .map { $0.compact() }

    self.setViewControllers = combineLatest(standardTabs, personalizedTabs).map(+)

    self.selectedIndex = Signal.merge([
      self.viewDidLoadProperty.signal.mapConst(0),
      self.didSelectIndexProperty.signal,
      self.switchToActivitiesProperty.signal.mapConst(1),
      self.switchToDiscoveryProperty.signal.mapConst(0)
      ])
      .withLatestFrom(self.setViewControllers)
      .map { idx, vcs in clamp(0, vcs.count-1)(idx) }

    let selectedTabAgain = self.selectedIndex.combinePrevious()
      .map { (prev, next) -> Int? in prev == next ? next : nil }
      .ignoreNil()

    self.scrollToTop = self.setViewControllers
      .takePairWhen(selectedTabAgain)
      .map { (vcs, idx) in vcs[idx] }

    self.tabBarItemsData = combineLatest(userState, self.viewDidLoadProperty.signal)
      .map(first)
      .map(tabData(isLoggedIn:isMember:))

    self.profileTabBarItemData = currentUser.ignoreNil()
      .map { (user: $0, isMember: ($0.stats.memberProjectsCount ?? 0) > 0) }
      .map { ProfileTabBarItemData(avatarUrl: NSURL(string: $0.user.avatar.small),
                                   isMember: $0.isMember,
                                   item: $0.isMember ? .profile(index: 4) : .profile(index: 3))
    }
  }
  // swiftlint:enable function_body_length

  private let currentUserUpdatedProperty = MutableProperty(())
  internal func currentUserUpdated() {
    self.currentUserUpdatedProperty.value = ()
  }
  private let didSelectIndexProperty = MutableProperty(0)
  internal func didSelectIndex(index: Int) {
    self.didSelectIndexProperty.value = index
  }
  private let switchToActivitiesProperty = MutableProperty()
  internal func switchToActivities() {
    self.switchToActivitiesProperty.value = ()
  }
  private let switchToDiscoveryProperty = MutableProperty()
  internal func switchToDiscovery() {
    self.switchToDiscoveryProperty.value = ()
  }
  private let userSessionStartedProperty = MutableProperty<()>()
  internal func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  private let userSessionEndedProperty = MutableProperty<()>()
  internal func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty<()>()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  internal let profileTabBarItemData: Signal<ProfileTabBarItemData, NoError>
  internal let scrollToTop: Signal<UIViewController, NoError>
  internal let selectedIndex: Signal<Int, NoError>
  internal let setViewControllers: Signal<[UIViewController], NoError>
  internal let tabBarItemsData: Signal<TabBarItemsData, NoError>

  internal var inputs: RootViewModelInputs { return self }
  internal var outputs: RootViewModelOutputs { return self }
}

private func initialViewController(storyboardName storyboardName: String) -> UIViewController? {
  return UIStoryboard(name: storyboardName, bundle: .framework).instantiateInitialViewController()
}

private func tabData(isLoggedIn isLoggedIn: Bool, isMember: Bool) -> TabBarItemsData {

  let items: [TabBarItem] = isMember ?
    [.home(index: 0), .activity(index: 1), .search(index: 2), .dashboard(index: 3), .profile(index: 4)] :
    [.home(index: 0), .activity(index: 1), .search(index: 2), .profile(index: 3)]

  return TabBarItemsData(items: items,
                         isLoggedIn: isLoggedIn,
                         isMember: isMember)
}

extension TabBarItemsData: Equatable {}
func == (lhs: TabBarItemsData, rhs: TabBarItemsData) -> Bool {
  return lhs.items == rhs.items &&
         lhs.isLoggedIn == rhs.isLoggedIn &&
         lhs.isMember == rhs.isMember
}

extension ProfileTabBarItemData: Equatable {}
func == (lhs: ProfileTabBarItemData, rhs: ProfileTabBarItemData) -> Bool {
  return lhs.avatarUrl == rhs.avatarUrl &&
         lhs.isMember == rhs.isMember &&
         lhs.item == rhs.item
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
    return lhs == rhs
  case let (.search(lhs), .search(rhs)):
    return lhs == rhs
  default: return false
  }
}
// swiftlint:enable cyclomatic_complexity
