import Foundation
import ReactiveSwift

public protocol LoginSignupUseCaseType {
  var uiInputs: LoginSignupUseCaseUIInputs { get }
  var uiOutputs: LoginSignupUseCaseUIOutputs { get }
  var dataOutputs: LoginSignupUseCaseDataOutputs { get }
}

public protocol LoginSignupUseCaseUIInputs {
  func goToLoginSignupTapped()
  func userSessionDidChange()
}

public protocol LoginSignupUseCaseUIOutputs {
  var goToLoginSignup: Signal<LoginIntent, Never> { get }
}

public protocol LoginSignupUseCaseDataOutputs {
  var userSessionChanged: Signal<Void, Never> { get }
  var isLoggedIn: Signal<Bool, Never> { get }
}

/**
 A use case for logging in and signing up during the pledge flow.

 User Interface Inputs:
 - `goToLoginSignupTapped()` - The user tapped the login button. Triggers `goToLoginSignup`.

 Data Inputs:
  - `initialData` - An empty signal. Triggers an initial `isLoggedIn` event to fire.
  - `loginIntent` - What kind of login intent to use when showing the login page.

 User Interface Outputs:
 - `goToLoginSignup` - The view controller should display a login screen. Can happen never, once, or many times.
 - `userSessionDidChange()` - The user completed login, sign up, or log out. Triggers a new `isLoggedIn` event. Usually hooked up to a notification for .ksr_sessionStarted.

 Data Outputs:
 - `userSessionChanged` - A user has logged in or out. Can happen never, once, or many times.
 - `isLoggedIn` - A user is logged in or out. Happens once on `initialData`, and any time `userSessionDidChange` afterwards.
 */

public final class LoginSignupUseCase: LoginSignupUseCaseType, LoginSignupUseCaseUIInputs,
  LoginSignupUseCaseUIOutputs, LoginSignupUseCaseDataOutputs {
  init(withLoginIntent loginIntent: LoginIntent, initialData: Signal<Void, Never>) {
    self.goToLoginSignup = self.goToLoginSignupSignal
      .mapConst(loginIntent)

    self.isLoggedIn = Signal.merge(initialData, self.userSessionDidChangeSignal)
      .map { _ in AppEnvironment.current.currentUser != nil }
  }

  // MARK: - UI Inputs

  private let (goToLoginSignupSignal, goToLoginSignupObserver) = Signal<Void, Never>.pipe()
  public func goToLoginSignupTapped() {
    self.goToLoginSignupObserver.send(value: ())
  }

  private let (userSessionDidChangeSignal, userSessionDidChangeObserver) = Signal<Void, Never>.pipe()
  public func userSessionDidChange() {
    self.userSessionDidChangeObserver.send(value: ())
  }

  // MARK: - UI Outputs

  public let goToLoginSignup: Signal<LoginIntent, Never>

  // MARK: - Data Outputs

  public var userSessionChanged: Signal<Void, Never> {
    return self.userSessionDidChangeSignal
  }

  public let isLoggedIn: Signal<Bool, Never>

  // MARK: - Type

  public var uiInputs: any LoginSignupUseCaseUIInputs { return self }
  public var uiOutputs: any LoginSignupUseCaseUIOutputs { return self }
  public var dataOutputs: any LoginSignupUseCaseDataOutputs { return self }
}
