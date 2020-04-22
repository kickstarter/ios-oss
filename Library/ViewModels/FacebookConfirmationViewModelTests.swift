@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class FacebookConfirmationViewModelTests: TestCase {
  let vm: FacebookConfirmationViewModelType = FacebookConfirmationViewModel()
  let displayEmail = TestObserver<String, Never>()
  let sendNewsletters = TestObserver<Bool, Never>()
  let showLogin = TestObserver<(), Never>()
  let logIntoEnvironment = TestObserver<AccessTokenEnvelope, Never>()
  let postNotification = TestObserver<Notification.Name, Never>()
  let showSignupError = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.displayEmail.observe(self.displayEmail.observer)
    self.vm.outputs.sendNewsletters.observe(self.sendNewsletters.observer)
    self.vm.outputs.showLogin.observe(self.showLogin.observer)
    self.vm.outputs.logIntoEnvironment.observe(self.logIntoEnvironment.observer)
    self.vm.outputs.postNotification.map { $0.name }.observe(self.postNotification.observer)
    self.vm.errors.showSignupError.observe(self.showSignupError.observer)
  }

  func testDisplayEmail_whenViewDidLoad() {
    self.vm.inputs.email("kittens@kickstarter.com")

    self.displayEmail.assertDidNotEmitValue("Email does not display")

    self.vm.inputs.viewDidLoad()

    self.displayEmail.assertValues(["kittens@kickstarter.com"], "Display email")
  }

  func testNewsletterSwitch_whenViewDidLoad() {
    self.sendNewsletters.assertDidNotEmitValue("Newsletter toggle does not emit")

    self.vm.inputs.viewDidLoad()

    self.sendNewsletters.assertValues([false], "Newsletter toggle emits false")
    XCTAssertEqual(
      [], trackingClient.events,
      "Newsletter toggle is not tracked on intital state"
    )
  }

  func testNewsletterSwitch_whenViewDidLoad_German() {
    withEnvironment(countryCode: "DE") {
      sendNewsletters.assertDidNotEmitValue("Newsletter toggle does not emit")

      vm.inputs.viewDidLoad()

      sendNewsletters.assertValues([false], "Newsletter toggle emits false")
    }
  }

  func testNewsletterSwitch_whenViewDidLoad_UK() {
    withEnvironment(countryCode: "UK") {
      sendNewsletters.assertDidNotEmitValue("Newsletter toggle does not emit")

      vm.inputs.viewDidLoad()

      sendNewsletters.assertValues([false], "Newsletter toggle emits false")
      XCTAssertEqual(
        [], trackingClient.events,
        "Newsletter toggle is not tracked on intital state"
      )
    }
  }

  func testNewsletterToggle() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.sendNewslettersToggled(false)

    self.sendNewsletters.assertValues([false, false], "Newsletter is toggled off")
    XCTAssertEqual(
      [
        "Unsubscribed From Newsletter",
        "Signup Newsletter Toggle"
      ],
      self.trackingClient.events,
      "Newsletter toggle is tracked"
    )
    XCTAssertEqual(false, trackingClient.properties.last!["send_newsletters"] as? Bool)

    self.vm.inputs.sendNewslettersToggled(true)

    self.sendNewsletters.assertValues([false, false, true], "Newsletter is toggled on")
    XCTAssertEqual(
      [
        "Unsubscribed From Newsletter",
        "Signup Newsletter Toggle",
        "Subscribed To Newsletter",
        "Signup Newsletter Toggle"
      ],
      self.trackingClient.events,
      "Newsletter toggle is tracked"
    )
    XCTAssertEqual(true, trackingClient.properties.last!["send_newsletters"] as? Bool)
  }

  func testCreateNewAccount_withoutNewsletterToggle() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.facebookToken("PuRrrrrrr3848")
    self.vm.inputs.createAccountButtonPressed()

    scheduler.advance()

    self.logIntoEnvironment.assertValueCount(1, "Account successfully created")

    self.vm.inputs.environmentLoggedIn()

    self.postNotification.assertValues(
      [.ksr_sessionStarted],
      "Login notification posted."
    )
  }

  func testCreateNewAccount_withNewsletterToggle() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.facebookToken("PuRrrrrrr3848")
    self.vm.inputs.sendNewslettersToggled(true)
    self.vm.inputs.createAccountButtonPressed()

    scheduler.advance()

    self.logIntoEnvironment.assertValueCount(1, "Account successfully created")

    self.vm.inputs.environmentLoggedIn()

    self.postNotification.assertValues(
      [.ksr_sessionStarted],
      "Login notification posted."
    )

    XCTAssertEqual(
      ["Subscribed To Newsletter", "Signup Newsletter Toggle"],
      self.trackingClient.events
    )
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
    }
  }

  func testShowLogin() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.loginButtonPressed()

    self.showLogin.assertValueCount(1, "Show login")
  }
}
