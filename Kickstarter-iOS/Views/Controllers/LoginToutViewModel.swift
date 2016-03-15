import protocol Library.ViewModelType
import struct ReactiveCocoa.SignalProducer
import class ReactiveCocoa.Signal
import enum Result.NoError
import struct Library.Environment
import struct Library.AppEnvironment
import enum Library.LoginIntent

internal protocol LoginToutViewModelInputs {
  func loginIntent(intent: String)
  func facebookButtonPressed()
  func loginButtonPressed()
  func signupButtonPressed()
}

internal protocol LoginToutViewModelOutputs {
  var startLogin: Signal<(), NoError> { get }
  var startSignup: Signal<(), NoError> { get }
}

internal protocol LoginToutViewModelType {
  var inputs: LoginToutViewModelInputs { get }
  var outputs: LoginToutViewModelOutputs { get }
}

internal final class LoginToutViewModel: LoginToutViewModelType, LoginToutViewModelInputs, LoginToutViewModelOutputs {

  // MARK: LoginToutViewModelType
  internal var inputs: LoginToutViewModelInputs { return self }
  internal var outputs: LoginToutViewModelOutputs { return self }

  // MARK: Inputs
  private let (loginIntentSignal, loginIntentObserver) = Signal<(String), NoError>.pipe()
  internal func loginIntent(intent: String) {
    loginIntentObserver.sendNext(intent)
  }
  private let (facebookButtonPressedSignal, facebookButtonPressedObserver) = Signal<(), NoError>.pipe()
  internal func facebookButtonPressed() {
    facebookButtonPressedObserver.sendNext(())
  }
  private let (loginButtonPressedSignal, loginButtonPressedObserver) = Signal<(), NoError>.pipe()
  internal func loginButtonPressed() {
    loginButtonPressedObserver.sendNext(())
  }
  private let (signupButtonPressedSignal, signupButtonPressedObserver) = Signal<(), NoError>.pipe()
  internal func signupButtonPressed() {
    signupButtonPressedObserver.sendNext(())
  }

  // MARK: Outputs
  internal var startLogin: Signal<(), NoError>
  internal var startSignup: Signal<(), NoError>

  internal init(env: Environment = AppEnvironment.current) {
    startLogin = loginButtonPressedSignal
    startSignup = signupButtonPressedSignal

    let koala = env.koala
    loginIntentSignal.observeNext { intent in
      koala.trackLoginTout(intent)
    }
  }
}
