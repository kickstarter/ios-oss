import ReactiveCocoa
import Result
import KsApi
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

internal final class FacebookConfirmationViewModel: FacebookConfirmationViewModelType, FacebookConfirmationViewModelInputs, FacebookConfirmationViewModelOutputs, FacebookConfirmationViewModelErrors {

  // MARK: FacebookConfirmationViewModelType
  internal var inputs: FacebookConfirmationViewModelInputs { return self }
  internal var outputs: FacebookConfirmationViewModelOutputs { return self }
  internal var errors: FacebookConfirmationViewModelErrors { return self }

  // MARK: FacebookConfirmationViewModelInputs
  private let (viewWillAppearSignal, viewWillAppearObserver) = Signal<(), NoError>.pipe()
  internal func viewWillAppear() {
    viewWillAppearObserver.sendNext()
  }

  private let (emailSignal, emailObserver) = Signal<String, NoError>.pipe()
  internal func email(email: String) {
    emailObserver.sendNext(email)
  }

  private let (sendNewslettersToggledSignal, sendNewslettersToggledObserver) = Signal<Bool, NoError>.pipe()
  func sendNewslettersToggled(newsletters: Bool) {
    sendNewslettersToggledObserver.sendNext(newsletters)
  }

  private let (facebookTokenSignal, facebookTokenObserver) = Signal<String, NoError>.pipe()
  func facebookToken(token: String) {
    facebookTokenObserver.sendNext(token)
  }

  private let (createAccountButtonSignal, createAccountButtonObserver) = Signal<(), NoError>.pipe()
  internal func createAccountButtonPressed() {
    createAccountButtonObserver.sendNext()
  }

  private let (loginButtonPressedSignal, loginButtonPressedObserver) = Signal<(), NoError>.pipe()
  internal func loginButtonPressed() {
    loginButtonPressedObserver.sendNext()
  }

  // MARK: FacebookConfirmationViewModelOutputs
  internal let displayEmail: Signal<String, NoError>
  internal let sendNewsletters: Signal<Bool, NoError>
  internal let newAccountSuccess: Signal<(), NoError>
  internal let showLogin: Signal<(), NoError>

  // MARK: FacebookConfirmationViewModelErrors
  internal let accountCreationFail: Signal<String, NoError>

  internal init(env: Environment = AppEnvironment.current) {
    let apiService = env.apiService
    let koala = env.koala
    let initialNewsletterState = false

    displayEmail = emailSignal.takeWhen(viewWillAppearSignal)

    sendNewsletters = sendNewslettersToggledSignal
      .mergeWith(viewWillAppearSignal.mapConst(initialNewsletterState))

    newAccountSuccess = combineLatest(facebookTokenSignal, sendNewslettersToggledSignal)
      .takeWhen(createAccountButtonSignal)
      .switchMap { token, newsletter in
        apiService.signup(facebookAccessToken: token, sendNewsletters: newsletter).demoteErrors() }
      .ignoreValues()

    showLogin = loginButtonPressedSignal

    accountCreationFail = .empty

    viewWillAppearSignal.observeNext { _ in koala.trackFacebookConfirmation() }

    newAccountSuccess.observeNext { _ in koala.trackSignupSuccess() }

    sendNewslettersToggledSignal
      .skip(1)
      .observeNext { send in
      koala.trackSignupNewsletterToggle(send) }

    sendNewslettersToggledObserver.sendNext(initialNewsletterState)
  }
}
