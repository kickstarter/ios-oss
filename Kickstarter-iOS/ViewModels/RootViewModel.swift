import ReactiveCocoa
import UIKit
import Result
import Library
import Prelude

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

  internal let setViewControllers: Signal<[UIViewController], NoError>
  internal let selectedIndex: Signal<Int, NoError>
  internal let scrollToTop: Signal<UIViewController, NoError>

  internal var inputs: RootViewModelInputs { return self }
  internal var outputs: RootViewModelOutputs { return self }

  internal init() {
    let currentUser = self.viewDidLoadProperty.signal
      .mergeWith(self.userSessionStartedProperty.signal)
      .mergeWith(self.userSessionEndedProperty.signal)
      .mergeWith(self.currentUserUpdatedProperty.signal)
      .map { AppEnvironment.current.currentUser }

    let standardTabs = self.viewDidLoadProperty.signal
      .take(1)
      .map { _ in
        [
          UIStoryboard(name: "Discovery", bundle: nil).instantiateInitialViewController(),
          UIStoryboard(name: "Search", bundle: nil).instantiateInitialViewController(),
          UIStoryboard(name: "Activity", bundle: nil).instantiateInitialViewController()
        ]
      }
      .map { $0.compact() }

    let personalizedTabs = currentUser
      .map { user in (isLoggedIn: user != nil, isCreator: user?.isCreator ?? false) }
      .map { user -> [UIViewController?] in
        [
          user.isCreator   ? initialViewController(storyboardName: "Dashboard") : nil,
          !user.isLoggedIn ? initialViewController(storyboardName: "Login") : nil,
          user.isLoggedIn  ? initialViewController(storyboardName: "Profile") : nil
        ]
      }
      .map { $0.compact() }

    self.setViewControllers = combineLatest(standardTabs, personalizedTabs).map(+)

    self.selectedIndex = Signal.merge([
      self.viewDidLoadProperty.signal.mapConst(0),
      self.didSelectIndexProperty.signal
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
  return UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController()
}
