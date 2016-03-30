import protocol Library.ViewModelType
import struct ReactiveCocoa.SignalProducer
import class ReactiveCocoa.Signal
import enum Result.NoError
import struct Library.Environment
import struct Library.AppEnvironment

internal protocol LoginToutViewModelInputs {
  /// Call when the view controller's viewDidAppear() method is called
  func viewDidAppear()
  /// Call to set the reason the user is attempting to log in
  func loginIntent(intent: LoginIntent)
  /// Call when Facebook login button is pressed
  func facebookButtonPressed()
  /// Call when login button is pressed
  func loginButtonPressed()
  /// Call when sign up button is pressed
  func signupButtonPressed()
  /// Call when the help button is pressed
  func helpButtonPressed()
  /// Call when a help sheet button is pressed
  func helpTypeButtonPressed(helpType: HelpType)
}

internal protocol LoginToutViewModelOutputs {
  /// Emits when Login view should be shown
  var startLogin: Signal<(), NoError> { get }
  /// Emits when Signup view should be shown
  var startSignup: Signal<(), NoError> { get }
  /// Emits when the help actionsheet should be shown with an array of HelpType values
  var showHelpActionSheet: Signal<[HelpType], NoError> { get }
  /// Emits a HelpType value when a button on the help actionsheet is pressed
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
  private var (viewDidAppearSignal, viewDidAppearObserver) = Signal<(), NoError>.pipe()
  func viewDidAppear() {
    viewDidAppearObserver.sendNext()
  }
  private let (loginIntentSignal, loginIntentObserver) = Signal<(LoginIntent), NoError>.pipe()
  internal func loginIntent(intent: LoginIntent) {
    loginIntentObserver.sendNext(intent)
  }
  private let (facebookButtonPressedSignal, facebookButtonPressedObserver) = Signal<(), NoError>.pipe()
  internal func facebookButtonPressed() {
    facebookButtonPressedObserver.sendNext()
  }
  private let (loginButtonPressedSignal, loginButtonPressedObserver) = Signal<(), NoError>.pipe()
  internal func loginButtonPressed() {
    loginButtonPressedObserver.sendNext()
  }
  private let (signupButtonPressedSignal, signupButtonPressedObserver) = Signal<(), NoError>.pipe()
  internal func signupButtonPressed() {
    signupButtonPressedObserver.sendNext()
  }
  private let (helpButtonPressedSignal, helpButtonPressedObserver) = Signal<(), NoError>.pipe()
  internal func helpButtonPressed() {
    helpButtonPressedObserver.sendNext()
  }
  private let (helpTypeButtonPressedSignal, helpTypeButtonPressedObserver) = Signal<HelpType, NoError>.pipe()
  internal func helpTypeButtonPressed(helpType: HelpType) {
    helpTypeButtonPressedObserver.sendNext(helpType)
  }

  // MARK: Outputs
  internal let startLogin: Signal<(), NoError>
  internal let startSignup: Signal<(), NoError>
  internal let showHelpActionSheet: Signal<[HelpType], NoError>
  internal let showHelp: Signal<HelpType, NoError>

  internal init(env: Environment = AppEnvironment.current) {
    let koala = env.koala

    self.startLogin = self.loginButtonPressedSignal
    self.startSignup = self.signupButtonPressedSignal
    self.showHelpActionSheet = self.helpButtonPressedSignal.map { _ in
      return HelpType.allValues
    }
    self.showHelp = self.helpTypeButtonPressedSignal

    loginIntentSignal
      .combineLatestWith(viewDidAppearSignal)
      .take(1)
      .map { intent, _ in intent.trackingString }
      .observeNext(koala.trackLoginTout)
  }
}
