import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Library

internal protocol FacebookConfirmationViewModelInputs {
  func viewWillAppear()
  func email(email: String)
  func facebookToken(token: String)
  func sendNewslettersToggled(newsletters: Bool)
  func createAccountButtonPressed()
  func loginButtonPressed()
}

internal protocol FacebookConfirmationViewModelOutputs {
  var displayEmail: Signal<String, NoError> { get }
  var sendNewsletters: Signal<Bool, NoError> { get }
  var newAccountSuccess: Signal<(), NoError> { get }
  var showLogin: Signal<(), NoError> { get }

  // todo: help inputs same as logintout
}

internal protocol FacebookConfirmationViewModelErrors {
  var accountCreationFail: Signal<String, NoError> { get }
}

internal protocol FacebookConfirmationViewModelType {
  var inputs: FacebookConfirmationViewModelInputs { get }
  var outputs: FacebookConfirmationViewModelOutputs { get }
  var errors: FacebookConfirmationViewModelErrors { get }
}

internal final class FacebookConfirmationViewModel: FacebookConfirmationViewModelType,
FacebookConfirmationViewModelInputs, FacebookConfirmationViewModelOutputs,
FacebookConfirmationViewModelErrors {

  // MARK: FacebookConfirmationViewModelType
  internal var inputs: FacebookConfirmationViewModelInputs { return self }
  internal var outputs: FacebookConfirmationViewModelOutputs { return self }
  internal var errors: FacebookConfirmationViewModelErrors { return self }

  // MARK: FacebookConfirmationViewModelInputs
  private let viewWillAppearProperty = MutableProperty()
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  private let emailProperty = MutableProperty("")
  internal func email(email: String) {
    self.emailProperty.value = email
  }

  private let sendNewslettersToggledProperty = MutableProperty(false)
  func sendNewslettersToggled(newsletters: Bool) {
    self.sendNewslettersToggledProperty.value = newsletters
  }

  private let facebookTokenProperty = MutableProperty("")
  func facebookToken(token: String) {
    self.facebookTokenProperty.value = token
  }

  private let createAccountButtonProperty = MutableProperty()
  internal func createAccountButtonPressed() {
    self.createAccountButtonProperty.value = ()
  }

  private let loginButtonPressedProperty = MutableProperty()
  internal func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }

  // MARK: FacebookConfirmationViewModelOutputs
  internal let displayEmail: Signal<String, NoError>
  internal let sendNewsletters: Signal<Bool, NoError>
  internal let newAccountSuccess: Signal<(), NoError>
  internal let showLogin: Signal<(), NoError>

  // MARK: FacebookConfirmationViewModelErrors
  internal let accountCreationFail: Signal<String, NoError>

  internal init() {


    displayEmail = self.emailProperty.signal
      .takeWhen(self.viewWillAppearProperty.signal)

    sendNewsletters = self.sendNewslettersToggledProperty.signal
      .mergeWith(self.viewWillAppearProperty.signal.mapConst(true))

    let signupEvent = combineLatest(self.facebookTokenProperty.signal, sendNewsletters)
      .takeWhen(self.createAccountButtonProperty.signal)
      .switchMap { token, newsletter in
        AppEnvironment.current.apiService.signup(facebookAccessToken: token, sendNewsletters: newsletter)
          .materialize()
    }

    self.newAccountSuccess = signupEvent.values().ignoreValues()

    self.accountCreationFail = signupEvent.errors()
      .map { envelope in envelope.errorMessages.first ??
        localizedString(key: "signup.error.something_wrong", defaultValue: "Something went wrong.")
    }

    showLogin = self.loginButtonPressedProperty.signal

    self.viewWillAppearProperty.signal
      .observeNext { _ in AppEnvironment.current.koala.trackFacebookConfirmation() }

    newAccountSuccess.observeNext { _ in AppEnvironment.current.koala.trackSignupSuccess() }

    self.sendNewslettersToggledProperty.signal
      .observeNext { b in AppEnvironment.current.koala.trackSignupNewsletterToggle(b) }
  }
}
