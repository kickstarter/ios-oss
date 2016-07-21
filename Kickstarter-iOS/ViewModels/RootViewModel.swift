import Library
import Prelude
import ReactiveCocoa
import Result
import UIKit

internal protocol RootViewModelInputs {
  /// Call from the controller's `viewDidLoad` method.
  func viewDidLoad()

  /// Call when the controller has received a user session started notification.
  func userSessionStarted()

  /// Call when the controller has received a user session ended notification.
  func userSessionEnded()

  /// Call when the controller has received a user updated notification.
  func currentUserUpdated()

  /// Call when selected tab bar index changes.
  func didSelectIndex(index: Int)

  /// Call when it's wanted to switch to the discovery tab.
  func switchToDiscovery()
}

internal protocol RootViewModelOutputs {
  /// Emits the array of view controllers that should be set on the tab bar.
  var setViewControllers: Signal<[UIViewController], NoError> { get }

  /// Emits an index that the tab bar should be switched to.
  var selectedIndex: Signal<Int, NoError> { get }

  /// Emits a controller that should be scrolled to the top. This requires figuring out what kind of
  // controller it is, and setting its `contentOffset`.
  var scrollToTop: Signal<UIViewController, NoError> { get }
}

internal protocol RootViewModelType {
  var inputs: RootViewModelInputs { get }
  var outputs: RootViewModelOutputs { get }
}

internal final class RootViewModel: RootViewModelType, RootViewModelInputs, RootViewModelOutputs {

  private let viewDidLoadProperty = MutableProperty<()>()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  private let userSessionStartedProperty = MutableProperty<()>()
  internal func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  private let userSessionEndedProperty = MutableProperty<()>()
  internal func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }
  private let currentUserUpdatedProperty = MutableProperty(())
  internal func currentUserUpdated() {
    self.currentUserUpdatedProperty.value = ()
  }
  private let didSelectIndexProperty = MutableProperty(0)
  internal func didSelectIndex(index: Int) {
    self.didSelectIndexProperty.value = index
  }
  private let switchToDiscoveryProperty = MutableProperty()
  internal func switchToDiscovery() {
    self.switchToDiscoveryProperty.value = ()
  }

  internal let setViewControllers: Signal<[UIViewController], NoError>
  internal let selectedIndex: Signal<Int, NoError>
  internal let scrollToTop: Signal<UIViewController, NoError>

  internal var inputs: RootViewModelInputs { return self }
  internal var outputs: RootViewModelOutputs { return self }

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
          initialViewController(storyboardName: "Search"),
          initialViewController(storyboardName: "Activity")
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
  }
}

private func initialViewController(storyboardName storyboardName: String) -> UIViewController? {
  return UIStoryboard(name: storyboardName, bundle: .framework).instantiateInitialViewController()
}
