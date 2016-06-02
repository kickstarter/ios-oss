import XCTest
import ReactiveCocoa
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Library

final class FacebookConfirmationViewModelTests: TestCase {
  let vm: FacebookConfirmationViewModelType = FacebookConfirmationViewModel()
  let displayEmail = TestObserver<String, NoError>()
  let sendNewsletters = TestObserver<Bool, NoError>()
  let showLogin = TestObserver<(), NoError>()
  let logIntoEnvironment = TestObserver<AccessTokenEnvelope, NoError>()
  let postNotification = TestObserver<String, NoError>()
  let showSignupError = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.displayEmail.observe(displayEmail.observer)
    vm.outputs.sendNewsletters.observe(sendNewsletters.observer)
    vm.outputs.showLogin.observe(showLogin.observer)
    vm.outputs.logIntoEnvironment.observe(logIntoEnvironment.observer)
    vm.outputs.postNotification.map { note in note.name }.observe(postNotification.observer)
    vm.errors.showSignupError.observe(showSignupError.observer)
  }

  func testDisplayEmail_whenViewDidLoad() {
    vm.inputs.email("kittens@kickstarter.com")

    displayEmail.assertDidNotEmitValue("Email does not display")

    vm.inputs.viewDidLoad()

    displayEmail.assertValues(["kittens@kickstarter.com"], "Display email")

    XCTAssertEqual(["Facebook Confirm"], trackingClient.events)
  }

  func testNewsletterSwitch_whenViewDidLoad() {
    sendNewsletters.assertDidNotEmitValue("Newsletter toggle does not emit")

    vm.inputs.viewDidLoad()

    sendNewsletters.assertValues([true], "Newsletter toggle emits true")
    XCTAssertEqual(["Facebook Confirm"], trackingClient.events,
                   "Newsletter toggle is not tracked on intital state")

  }

  func testNewsletterSwitch_whenViewDidLoad_German() {
    withEnvironment(countryCode: "DE") {
      sendNewsletters.assertDidNotEmitValue("Newsletter toggle does not emit")

      vm.inputs.viewDidLoad()

      sendNewsletters.assertValues([false], "Newsletter toggle emits false")
      XCTAssertEqual(["Facebook Confirm"], trackingClient.events,
                     "Newsletter toggle is not tracked on intital state")
    }
  }

  func testNewsletterToggle() {
    vm.inputs.viewDidLoad()
    vm.inputs.sendNewslettersToggled(false)

    sendNewsletters.assertValues([true, false], "Newsletter toggle is on")
    XCTAssertEqual(["Facebook Confirm", "Signup Newsletter Toggle"], trackingClient.events,
                   "Newsletter toggle is tracked")
    XCTAssertEqual(false, trackingClient.properties.last!["send_newsletters"] as? Bool)

    vm.inputs.sendNewslettersToggled(true)

    sendNewsletters.assertValues([true, false, true], "Newsletter toggle is off")
    XCTAssertEqual(["Facebook Confirm", "Signup Newsletter Toggle", "Signup Newsletter Toggle"],
                   trackingClient.events,
                   "Newsletter toggle is tracked")
    XCTAssertEqual(true, trackingClient.properties.last!["send_newsletters"] as? Bool)
  }

  func testCreateNewAccount_withoutNewsletterToggle() {
    vm.inputs.viewDidLoad()
    vm.inputs.facebookToken("PuRrrrrrr3848")
    vm.inputs.createAccountButtonPressed()

    scheduler.advance()

    logIntoEnvironment.assertValueCount(1, "Account successfully created")
    XCTAssertEqual(["Facebook Confirm", "Facebook Login"], trackingClient.events, "Koala login is tracked")

    vm.inputs.environmentLoggedIn()

    postNotification.assertValues([CurrentUserNotifications.sessionStarted],
                                  "Login notification posted.")

    XCTAssertEqual(["Facebook Confirm", "Facebook Login"], trackingClient.events)
  }

  func testCreateNewAccount_withNewsletterToggle() {
    vm.inputs.viewDidLoad()
    vm.inputs.facebookToken("PuRrrrrrr3848")
    vm.inputs.sendNewslettersToggled(true)
    vm.inputs.createAccountButtonPressed()

    scheduler.advance()

    logIntoEnvironment.assertValueCount(1, "Account successfully created")
    XCTAssertEqual(["Facebook Confirm", "Signup Newsletter Toggle", "Facebook Login"],
                   trackingClient.events, "Koala login is tracked")

    vm.inputs.environmentLoggedIn()

    postNotification.assertValues([CurrentUserNotifications.sessionStarted],
                                  "Login notification posted.")
  }

  func testCreateNewAccount_withError() {
    let error = ErrorEnvelope(
      errorMessages: ["Email address has an issue. If you are not sure why, please contact us."],
      ksrCode: nil,
      httpCode: 422,
      exception: nil
    )

    withEnvironment(apiService: MockService(signupError: error)) {
      vm.inputs.viewDidLoad()
      vm.inputs.facebookToken("Meowwwww4484848")
      vm.inputs.createAccountButtonPressed()

      scheduler.advance()

      logIntoEnvironment.assertValueCount(0, "Did not emit log into environment")
      showSignupError.assertValues(
        ["Email address has an issue. If you are not sure why, please contact us."]
      )
      XCTAssertEqual(["Facebook Confirm", "Errored Facebook Login"], trackingClient.events)
    }
  }

  func testCreateNewAccount_withDefaultError() {
    let error = ErrorEnvelope(
      errorMessages: [],
      ksrCode: nil,
      httpCode: 422,
      exception: nil
    )

    withEnvironment(apiService: MockService(signupError: error)) {
      vm.inputs.viewDidLoad()
      vm.inputs.facebookToken("Meowwwww4484848")
      vm.inputs.createAccountButtonPressed()

      scheduler.advance()

      logIntoEnvironment.assertValueCount(0, "Did not emit log into environment")
      showSignupError.assertValues(
        ["Couldn't log in with Facebook."]
      )
      XCTAssertEqual(["Facebook Confirm", "Errored Facebook Login"], trackingClient.events)
    }
  }

  func testShowLogin() {
    vm.inputs.viewDidLoad()
    vm.inputs.loginButtonPressed()

    showLogin.assertValueCount(1, "Show login")
  }
}
