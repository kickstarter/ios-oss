import Library
import ReactiveCocoa
import Result
import Library

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

internal final class LoginToutViewModel: LoginToutViewModelType, LoginToutViewModelInputs,
LoginToutViewModelOutputs {

  // MARK: LoginToutViewModelType
  internal var inputs: LoginToutViewModelInputs { return self }
  internal var outputs: LoginToutViewModelOutputs { return self }

  // MARK: Inputs
  private var viewDidAppearProperty = MutableProperty()
  func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }
  private let loginIntentProperty = MutableProperty<LoginIntent?>(nil)
  internal func loginIntent(intent: LoginIntent) {
    self.loginIntentProperty.value = intent
  }
  private let facebookButtonPressedProperty = MutableProperty()
  internal func facebookButtonPressed() {
    self.facebookButtonPressedProperty.value = ()
  }
  private let loginButtonPressedProperty = MutableProperty()
  internal func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }
  private let signupButtonPressedProperty = MutableProperty()
  internal func signupButtonPressed() {
    self.signupButtonPressedProperty.value = ()
  }
  private let helpButtonPressedProperty = MutableProperty()
  internal func helpButtonPressed() {
    self.helpButtonPressedProperty.value = ()
  }
  private let helpTypeButtonPressedProperty = MutableProperty<HelpType?>(nil)
  internal func helpTypeButtonPressed(helpType: HelpType) {
    self.helpTypeButtonPressedProperty.value = helpType
  }

  // MARK: Outputs
  internal let startLogin: Signal<(), NoError>
  internal let startSignup: Signal<(), NoError>
  internal let showHelpActionSheet: Signal<[HelpType], NoError>
  internal let showHelp: Signal<HelpType, NoError>

  internal init() {

    self.startLogin = self.loginButtonPressedProperty.signal
    self.startSignup = self.signupButtonPressedProperty.signal
    self.showHelpActionSheet = self.helpButtonPressedProperty.signal.mapConst(HelpType.allValues)
    self.showHelp = self.helpTypeButtonPressedProperty.signal.ignoreNil()

    loginIntentProperty.signal
      .ignoreNil()
      .combineLatestWith(viewDidAppearProperty.signal)
      .take(1)
      .map { intent, _ in intent.trackingString }
      .observeNext { i in AppEnvironment.current.koala.trackLoginTout(i) }
  }
}
