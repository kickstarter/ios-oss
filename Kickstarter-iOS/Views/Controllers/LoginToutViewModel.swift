import protocol Library.ViewModelType
import struct ReactiveCocoa.SignalProducer
import class ReactiveCocoa.Signal
import enum Result.NoError
import struct Library.Environment
import struct Library.AppEnvironment

internal protocol LoginToutViewModelInputs {
  func loginIntent(intent: String)
  func facebookButtonPressed()
  func loginButtonPressed()
  func signupButtonPressed()
  func helpButtonPressed()
  func helpTypeButtonPressed(helpType: HelpType)
}

internal protocol LoginToutViewModelOutputs {
  var startLogin: Signal<(), NoError> { get }
  var startSignup: Signal<(), NoError> { get }
  var showHelpActionSheet: Signal<[(title: String, data: HelpType)], NoError> { get }
  var showHelp: Signal<HelpType, NoError> { get }
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
  private let (helpButtonPressedSignal, helpButtonPressedObserver) = Signal<(), NoError>.pipe()
  internal func helpButtonPressed() {
    helpButtonPressedObserver.sendNext(())
  }
  private let (helpTypeButtonPressedSignal, helpTypeButtonPressedObserver) = Signal<HelpType, NoError>.pipe()
  internal func helpTypeButtonPressed(helpType: HelpType) {
    helpTypeButtonPressedObserver.sendNext(helpType)
  }

  // MARK: Outputs
  internal let startLogin: Signal<(), NoError>
  internal let startSignup: Signal<(), NoError>
  internal let showHelpActionSheet: Signal<[(title: String, data: HelpType)], NoError>
  internal let showHelp: Signal<HelpType, NoError>

  internal init(env: Environment = AppEnvironment.current) {
    let koala = env.koala

    self.startLogin = self.loginButtonPressedSignal
    self.startSignup = self.signupButtonPressedSignal
    self.showHelpActionSheet = self.helpButtonPressedSignal.map { _ in
      return HelpType.allValues.map { (title: $0.title, $0) }
    }
    self.showHelp = self.helpTypeButtonPressedSignal

    loginIntentSignal.observeNext(koala.trackLoginTout)
  }
}
