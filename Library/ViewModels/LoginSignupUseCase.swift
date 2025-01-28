import Foundation
import ReactiveSwift

public protocol LoginSignupUseCaseInputs {
  func goToLoginSignupTapped()
  func userSessionDidChange()
}

public protocol LoginSignupUseCaseType {
  var inputs: LoginSignupUseCaseInputs { get }
  var outputs: LoginSignupUseCaseOutputs { get }
  var inbetween: LoginSignupUseCaseInbetween { get }
}

public protocol LoginSignupUseCaseOutputs {
  var goToLoginSignup: Signal<LoginIntent, Never> { get }
}

public protocol LoginSignupUseCaseInbetween {
  var userSessionChanged: Signal<Void, Never> { get }
  var isLoggedIn: Signal<Bool, Never> { get }
}

/**
 A use case for logging in and signing up during the pledge flow.

 Inputs:
  - `initialData` - An empty signal. Triggers an initial `isLoggedIn` event to fire.
  - `goToLoginSignupTapped()` - The user tapped the login button. Triggers `goToLoginSignup`.
  - `userSessionDidChange()` - The user completed login, sign up, or log out. Triggers a new `isLoggedIn` event.

 Inbetween:
 - `userSessionChanged` - A user has logged in or out. Can happen never, once, or many times.
 - `isLoggedIn` - A user is logged in or out. Happens once on `initialData`, and any time `userSessionDidChange` afterwards.

 Outputs:
  - `goToLoginSignup` - The view controller should display a login screen. Can happen never, once, or many times.
 */
public final class LoginSignupUseCase: LoginSignupUseCaseType, LoginSignupUseCaseInputs,
  LoginSignupUseCaseOutputs, LoginSignupUseCaseInbetween {
  init(withLoginIntent loginIntent: LoginIntent, initialData: Signal<Void, Never>) {
    self.goToLoginSignup = self.goToLoginSignupSignal
      .mapConst(loginIntent)

    self.isLoggedIn = Signal.merge(initialData, self.userSessionDidChangeSignal)
      .map { _ in AppEnvironment.current.currentUser != nil }
  }

  // MARK: - Inputs

  private let (goToLoginSignupSignal, goToLoginSignupObserver) = Signal<Void, Never>.pipe()
  public func goToLoginSignupTapped() {
    self.goToLoginSignupObserver.send(value: ())
  }

  private let (userSessionDidChangeSignal, userSessionDidChangeObserver) = Signal<Void, Never>.pipe()
  public func userSessionDidChange() {
    self.userSessionDidChangeObserver.send(value: ())
  }

  // MARK: - Outputs

  public let goToLoginSignup: Signal<LoginIntent, Never>

  // MARK: - Inbetween

  public var userSessionChanged: Signal<Void, Never> {
    return self.userSessionDidChangeSignal
  }

  public let isLoggedIn: Signal<Bool, Never>

  // MARK: - Type

  public var inputs: any LoginSignupUseCaseInputs { return self }
  public var outputs: any LoginSignupUseCaseOutputs { return self }
  public var inbetween: any LoginSignupUseCaseInbetween { return self }
}
