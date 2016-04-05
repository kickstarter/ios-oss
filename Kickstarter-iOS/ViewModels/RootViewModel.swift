import ReactiveCocoa
import UIKit
import Result
import Library

internal protocol RootViewModelInputs {
  func viewDidLoad()
  func userSessionStarted()
  func userSessionEnded()
  func currentUserUpdated()
}

internal protocol RootViewModelOutputs {
  var setViewControllers: Signal<[UIViewController], NoError> { get }
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

  internal let setViewControllers: Signal<[UIViewController], NoError>

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
      .map {
        [UIViewController?](arrayLiteral:
          $0.isCreator   ? UIStoryboard(name: "Dashboard", bundle: nil).instantiateInitialViewController() : nil,
          !$0.isLoggedIn ? UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() : nil,
          $0.isLoggedIn  ? UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() : nil
        )
      }
      .map { $0.compact() }

    self.setViewControllers = combineLatest([standardTabs, personalizedTabs])
      .map { Array($0.flatten()) }
  }
}
